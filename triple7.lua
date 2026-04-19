local repo = 'https://raw.githubusercontent.com/triple7distro/triple7/main/'

local Library = loadstring(game:HttpGet(repo .. 'libraries/UI_library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'libraries/UI_theme.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'libraries/UI_save.lua'))()
local EspLibraryCode = game:HttpGet(repo .. 'libraries/ESP_library.lua')
local EspLibraryFunc, loadError = loadstring(EspLibraryCode)
if not EspLibraryFunc then
    error("Failed to load ESP library: " .. tostring(loadError))
end
local EspLibrary = EspLibraryFunc()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local CFrameNew = CFrame.new
local Vector2New = Vector2.new
local Vector3New = Vector3.new
local IsDescendantOf = game.IsDescendantOf
local FindFirstChild = game.FindFirstChild
local FindFirstChildOfClass = game.FindFirstChildOfClass
local Raycast = Workspace.Raycast
local WorldToViewportPoint = Camera.WorldToViewportPoint
local MathFloor = math.floor

local Window = Library:CreateWindow({
    Title = 'triple7 project delta / 1.2.3 / 19.04.2026',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0
})

local Tabs = {
    Combat = Window:AddTab('combat'),
    Visuals = Window:AddTab('visuals'),
    Settings = Window:AddTab('settings'),
}

-- weapon mods
local WeaponModsGroup = Tabs.Combat:AddRightGroupbox('weapon mods')

local originalValues = {}
local ammoTypesFolder = ReplicatedStorage:FindFirstChild("AmmoTypes")

local function applyWeaponMods()
    if not ammoTypesFolder then return end

    for _, ammoType in ipairs(ammoTypesFolder:GetChildren()) do
        if not ammoType:IsA("Instance") then continue end

        local name = ammoType:GetFullName()
        if not originalValues[name] then
            originalValues[name] = {
                RecoilStrength = ammoType:GetAttribute("RecoilStrength"),
                ProjectileDrop = ammoType:GetAttribute("ProjectileDrop"),
                AccuracyDeviation = ammoType:GetAttribute("AccuracyDeviation"),
            }
        end

        if Toggles.NoRecoil and Toggles.NoRecoil.Value then
            ammoType:SetAttribute("RecoilStrength", 0)
        else
            local orig = originalValues[name].RecoilStrength
            if orig ~= nil then
                ammoType:SetAttribute("RecoilStrength", orig)
            end
        end

        if Toggles.NoSpread and Toggles.NoSpread.Value then
            ammoType:SetAttribute("ProjectileDrop", 0)
            ammoType:SetAttribute("AccuracyDeviation", 0)
        else
            local origDrop = originalValues[name].ProjectileDrop
            local origAcc = originalValues[name].AccuracyDeviation
            if origDrop ~= nil then
                ammoType:SetAttribute("ProjectileDrop", origDrop)
            end
            if origAcc ~= nil then
                ammoType:SetAttribute("AccuracyDeviation", origAcc)
            end
        end
    end
end

WeaponModsGroup:AddToggle('NoRecoil', {
    Text = 'no recoil',
    Default = false,
    Tooltip = 'sets RecoilStrength to 0',
    Callback = function(Value)
        applyWeaponMods()
    end
})

WeaponModsGroup:AddToggle('NoSpread', {
    Text = 'no spread',
    Default = false,
    Tooltip = 'sets AccuracyDeviation and ProjectileDrop to 0',
    Callback = function(Value)
        applyWeaponMods()
    end
})

if ammoTypesFolder then
    ammoTypesFolder.ChildAdded:Connect(function(child)
        task.wait()
        applyWeaponMods()
    end)
end

-- silent aim
local SilentAimGroup = Tabs.Combat:AddLeftGroupbox('silent aim')

local SilentAim = {
    enabled = false,
    visible_check = true,
    target_ai = false,
    part = "Head",
    fov_enabled = false,
    fov_size = 150,
    fov_show = false,
    fov_color = Color3.new(1, 1, 1),
    fov_outline = false,
    hit_chance = 85,
    tracer = false,
    tracer_color = Color3.new(1, 1, 1),
    target_part = nil,
    is_visible = false,
    last_shot_time = 0,
    shot_delay = 0.08,
    friendly_list = {}
}

local function updateFriendlyDropdown()
    local playerNames = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerNames, plr.Name)
        end
    end
    table.sort(playerNames)
    if Options.FriendlyPlayers then
        Options.FriendlyPlayers:SetValues(playerNames)
    end
end

local VisCheckParams = RaycastParams.new()
VisCheckParams.FilterType = Enum.RaycastFilterType.Exclude
VisCheckParams.CollisionGroup = "WeaponRay"
VisCheckParams.IgnoreWater = true

local function is_visible(target, target_part)
    if not (target and target_part) then return false end
    VisCheckParams.FilterDescendantsInstances = { Workspace.NoCollision, Camera, LocalPlayer.Character }
    local origin = Camera.CFrame.Position
    local castresults = Raycast(Workspace, origin, target_part.Position - origin, VisCheckParams)
    return castresults and castresults.Instance and IsDescendantOf(castresults.Instance, target)
end

local function predict_velocity(Origin, Destination, DestinationVelocity, ProjectileSpeed)
    local Distance = (Destination - Origin).Magnitude
    if ProjectileSpeed <= 0 then return Destination end
    local TimeToHit = Distance / ProjectileSpeed
    local Predicted = Destination + DestinationVelocity * TimeToHit
    local Delta = (Predicted - Origin).Magnitude / ProjectileSpeed
    TimeToHit = TimeToHit + (Delta / ProjectileSpeed)
    return Destination + DestinationVelocity * TimeToHit
end

local function get_closest_target(usefov, fov_size, aimpart, npc, friendly_list)
    local best_part, best_isnpc = nil, false
    local min_dist = usefov and fov_size or math.huge
    local mousepos = Vector2New(Mouse.X, Mouse.Y)
    local GuiInset = game:GetService("GuiService"):GetGuiInset()
    
    if npc then
        for _, zone in pairs(Workspace.AiZones:GetChildren()) do
            for _, npcs in pairs(zone:GetChildren()) do
                local part = FindFirstChild(npcs, aimpart)
                local humanoid = FindFirstChildOfClass(npcs, "Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local position, onscreen = WorldToViewportPoint(Camera, part.Position)
                    local distance = (Vector2New(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
                    if (not usefov or onscreen) and distance < min_dist then
                        best_part = part
                        min_dist = distance
                        best_isnpc = true
                    end
                end
            end
        end
    end
    
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        if friendly_list[plr.Name] then continue end
        
        local character = plr.Character
        if character then
            local part = FindFirstChild(character, aimpart)
            local humanoid = FindFirstChildOfClass(character, "Humanoid")
            if part and humanoid and humanoid.Health > 0 then
                local position, onscreen = WorldToViewportPoint(Camera, part.Position)
                local distance = (Vector2New(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
                if (not usefov or onscreen) and distance <= min_dist then
                    best_part = part
                    min_dist = distance
                    best_isnpc = false
                end
            end
        end
    end
    
    return best_part, best_isnpc
end

local function make_tracer(Origin, Position, Color)
    local part1, part2 = Instance.new("Part", Workspace.NoCollision), Instance.new("Part", Workspace.NoCollision)
    part1.Position = Origin; part2.Position = Position
    part1.Transparency = 1; part2.Transparency = 1
    part1.CanCollide = false; part2.CanCollide = false
    part1.Size = Vector3.zero; part2.Size = Vector3.zero
    part1.Anchored = true; part2.Anchored = true
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local Tracer = Instance.new("Beam", Workspace.NoCollision)
    Tracer.Name = "Tracer"
    Tracer.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color),
        ColorSequenceKeypoint.new(1, Color)
    }
    Tracer.LightEmission = 1
    Tracer.LightInfluence = 0
    Tracer.Transparency = NumberSequence.new(0.5)
    Tracer.Attachment0 = OriginAttachment
    Tracer.Attachment1 = PositionAttachment
    Tracer.FaceCamera = false
    Tracer.Segments = 1
    Tracer.Width0 = 0.15
    Tracer.Width1 = 0.15
    return Tracer, part1, part2
end

local ReplicatedPlayers = ReplicatedStorage.Players

local function get_local_weapon()
    local Player = ReplicatedPlayers:FindFirstChild(LocalPlayer.Name)
    if Player and Player:FindFirstChild("Status") and Player.Status:FindFirstChild("GameplayVariables") and Player.Status.GameplayVariables:FindFirstChild("EquippedTool") and Player.Status.GameplayVariables.EquippedTool.Value then
        return Player.Status.GameplayVariables.EquippedTool.Value
    end
    return nil
end

local function is_holding_weapon()
    local weapon = get_local_weapon()
    return weapon ~= nil and weapon.Name ~= "Fists"
end

-- bullet hook
local GotHook = false
task.spawn(function()
    repeat
        for i, gc in next, getgc(true) do
            if type(gc) == "table" then
                if rawget(gc, "CreateBullet") and not GotHook then
                    local old_bullet = gc.CreateBullet
                    gc.CreateBullet = function(self, ...)
                        local args = { ... }
                        if SilentAim.enabled and is_holding_weapon() then
                            if math.random(1, 100) > SilentAim.hit_chance then
                                return old_bullet(self, unpack(args))
                            end
                            
                            local loadedammo, aimpart_index
                            for i, v in args do
                                if typeof(v) == "Instance" and v.Name == "AimPart" then
                                    aimpart_index = i
                                end
                                if type(v) == "string" then
                                    local tmp = FindFirstChild(ReplicatedStorage.AmmoTypes, v)
                                    if tmp then loadedammo = tmp end
                                end
                            end
                            
                            if not (loadedammo and aimpart_index) then
                                return old_bullet(self, unpack(args))
                            end
                            
                            if SilentAim.visible_check and not SilentAim.is_visible then
                                return old_bullet(self, unpack(args))
                            end
                            
                            local now = tick()
                            if now - SilentAim.last_shot_time < SilentAim.shot_delay then
                                return old_bullet(self, unpack(args))
                            end
                            SilentAim.last_shot_time = now
                            
                            if SilentAim.tracer and SilentAim.target_part then
                                local tracer, p1, p2 = make_tracer(args[aimpart_index].Position, SilentAim.target_part.Position, SilentAim.tracer_color)
                                local fade = 0.5
                                local conn
                                conn = RunService.RenderStepped:Connect(function(delta)
                                    fade = fade + delta
                                    tracer.Transparency = NumberSequence.new(math.clamp(fade, 0.5, 1))
                                    if fade >= 1 then
                                        tracer:Destroy()
                                        p1:Destroy()
                                        p2:Destroy()
                                        conn:Disconnect()
                                    end
                                end)
                            end
                            
                            if not SilentAim.target_part then
                                return old_bullet(self, unpack(args))
                            end
                            
                            local origin = Camera.CFrame.Position
                            local target_pos = SilentAim.target_part.Position
                            local target_vel = SilentAim.target_part.Velocity
                            local muzzle_vel = loadedammo:GetAttribute("MuzzleVelocity") or 300
                            local predicted = predict_velocity(origin, target_pos, target_vel, muzzle_vel)
                            
                            args[aimpart_index] = { CFrame = CFrameNew(origin, predicted) }
                        end
                        return old_bullet(self, unpack(args))
                    end
                    GotHook = true
                    break
                end
            end
        end
        if not GotHook then task.wait(0.5) end
    until GotHook
end)

-- attribute hook
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() then
        if method == "GetAttribute" and SilentAim.enabled then
            local attr = args[1]
            if attr == "ProjectileDrop" or attr == "Drag" then
                return 0
            end
        end
    end
    return __namecall(self, ...)
end)

-- silent aim ui
SilentAimGroup:AddToggle('SilentAimEnabled', {
    Text = 'silent aim',
    Default = false,
    Callback = function(Value)
        SilentAim.enabled = Value
    end
})

SilentAimGroup:AddToggle('SilentAimVisibleCheck', {
    Text = 'visible check only',
    Default = true,
    Tooltip = 'Only shoot visible targets (safer)',
    Callback = function(Value)
        SilentAim.visible_check = Value
    end
})

SilentAimGroup:AddToggle('SilentAimTargetAI', {
    Text = 'target AI',
    Default = false,
    Callback = function(Value)
        SilentAim.target_ai = Value
    end
})

SilentAimGroup:AddDropdown('SilentAimPart', {
    Values = {'Head','FaceHitBox','HeadTopHitbox','UpperTorso','LowerTorso','HumanoidRootPart','LeftFoot','LeftLowerLeg','LeftUpperLeg','LeftHand','LeftLowerArm','LeftUpperArm','RightFoot','RightLowerLeg','RightUpperLeg','RightHand','RightLowerArm','RightUpperArm'},
    Default = 1,
    Multi = false,
    Text = 'aim part',
    Callback = function(Value)
        SilentAim.part = Value
    end
})

SilentAimGroup:AddSlider('SilentAimHitChance', {
    Text = 'hit chance %',
    Default = 85,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(Value)
        SilentAim.hit_chance = Value
    end
})

SilentAimGroup:AddToggle('SilentAimTracer', {
    Text = 'bullet tracer',
    Default = false,
    Callback = function(Value)
        SilentAim.tracer = Value
    end
}):AddColorPicker('SilentAimTracerColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'tracer color',
    Transparency = 0,
    Callback = function(Value)
        SilentAim.tracer_color = Value
    end
})

SilentAimGroup:AddToggle('SilentAimFOV', {
    Text = 'use fov',
    Default = false,
    Callback = function(Value)
        SilentAim.fov_enabled = Value
    end
})

local FOVDependencyBox = SilentAimGroup:AddDependencyBox()
FOVDependencyBox:AddToggle('SilentAimFOVShow', {
    Text = 'show fov',
    Default = false,
    Callback = function(Value)
        SilentAim.fov_show = Value
    end
}):AddColorPicker('SilentAimFOVColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'fov color',
    Transparency = 0,
    Callback = function(Value)
        SilentAim.fov_color = Value
    end
})

FOVDependencyBox:AddToggle('SilentAimFOVOutline', {
    Text = 'fov outline',
    Default = false,
    Callback = function(Value)
        SilentAim.fov_outline = Value
    end
})

FOVDependencyBox:AddSlider('SilentAimFOVSize', {
    Text = 'target fov',
    Default = 150,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        SilentAim.fov_size = Value
    end
})

FOVDependencyBox:SetupDependencies({
    { Toggles.SilentAimFOV, true }
})

SilentAimGroup:AddDropdown('FriendlyPlayers', {
    Text = 'friendly players',
    Values = {},
    Default = {},
    Multi = true,
    AllowNull = true,
    Tooltip = 'Select players to ignore',
    Callback = function(Value)
        SilentAim.friendly_list = Value or {}
    end
})

updateFriendlyDropdown()
Players.PlayerAdded:Connect(updateFriendlyDropdown)
Players.PlayerRemoving:Connect(function(plr)
    updateFriendlyDropdown()
    if SilentAim.friendly_list[plr.Name] then
        SilentAim.friendly_list[plr.Name] = nil
    end
end)

-- fov circle drawing
local CircleOutline = Drawing.new("Circle")
local CircleInline = Drawing.new("Circle")
CircleInline.Transparency = 1
CircleInline.Thickness = 1
CircleInline.ZIndex = 2
CircleOutline.Thickness = 3
CircleOutline.Color = Color3.new()
CircleOutline.ZIndex = 1

RunService.RenderStepped:Connect(function()
    local GuiInset = game:GetService("GuiService"):GetGuiInset()
    CircleOutline.Position = Vector2New(Mouse.X, Mouse.Y + GuiInset.Y)
    CircleInline.Position = Vector2New(Mouse.X, Mouse.Y + GuiInset.Y)
    CircleInline.Radius = SilentAim.fov_size
    CircleInline.Color = SilentAim.fov_color
    CircleInline.Visible = SilentAim.fov_enabled and SilentAim.fov_show
    CircleOutline.Radius = SilentAim.fov_size
    CircleOutline.Visible = (SilentAim.fov_enabled and SilentAim.fov_show and SilentAim.fov_outline)
end)

RunService.Heartbeat:Connect(function()
    SilentAim.target_part, SilentAim.is_npc = get_closest_target(
        SilentAim.fov_enabled,
        SilentAim.fov_size,
        SilentAim.part,
        SilentAim.target_ai,
        SilentAim.friendly_list
    )
    SilentAim.is_visible = SilentAim.target_part and is_visible(SilentAim.target_part.Parent, SilentAim.target_part) or false
end)

-- camera fov
local CameraGroup = Tabs.Visuals:AddLeftGroupbox('camera')

local FOVEnabled = false
local NormalFOV = 90
local ZoomFOV = 30
local FOVConnection = nil

local function getTargetFOV()
    if not Options.CameraZoomKeybind then
        return NormalFOV
    end
    local isZoomed = Options.CameraZoomKeybind:GetState()
    return isZoomed and ZoomFOV or NormalFOV
end

local function forceFOV()
    local cam = Workspace.CurrentCamera
    if cam and FOVEnabled then
        local target = getTargetFOV()
        if cam.FieldOfView ~= target then
            cam.FieldOfView = target
        end
    end
end

local function startForcing()
    if FOVConnection then return end
    FOVConnection = RunService.RenderStepped:Connect(forceFOV)
end

local function stopForcing()
    if FOVConnection then
        FOVConnection:Disconnect()
        FOVConnection = nil
    end
    local cam = Workspace.CurrentCamera
    if cam then
        cam.FieldOfView = 90
    end
end

CameraGroup:AddToggle('EnableCameraFOV', {
    Text = 'toggle fov',
    Default = false,
    Callback = function(Value)
        FOVEnabled = Value
        if Value then
            startForcing()
        else
            stopForcing()
        end
    end
})

CameraGroup:AddSlider('CameraFOV', {
    Text = 'fov',
    Default = 90,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Suffix = '°',
    Callback = function(Value)
        NormalFOV = Value
    end
})

CameraGroup:AddSlider('CameraZoomFOV', {
    Text = 'zoom fov',
    Default = 30,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Suffix = '°',
        ZoomFOV = Value
    end
})

CameraGroup:AddLabel('zoom bind'):AddKeyPicker('CameraZoomKeybind', {
    Default = 'C',
    Mode = 'Hold',
    Text = 'camera zoom (hold)',
    NoUI = false
})

-- third person
local ThirdPerson = {
    enabled = false,
    x = 5,
    y = 2,
    z = 10,
    connection = nil
}

CameraGroup:AddToggle('ThirdPerson', {
    Text = 'third person',
    Default = false,
    Callback = function(Value)
        ThirdPerson.enabled = Value
        if Value then
            if not ThirdPerson.connection then
                ThirdPerson.connection = RunService.RenderStepped:Connect(function()
                    if not ThirdPerson.enabled then return end
                    local cam = Workspace.CurrentCamera
                    local character = LocalPlayer.Character
                    if not cam or not character then return end
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local offset = CFrame.new(ThirdPerson.x, ThirdPerson.y, ThirdPerson.z)
                    cam.CameraType = Enum.CameraType.Scriptable
                    cam.CFrame = hrp.CFrame * offset
                end)
            end
        else
            if ThirdPerson.connection then
                ThirdPerson.connection:Disconnect()
                ThirdPerson.connection = nil
            end
            local cam = Workspace.CurrentCamera
            if cam then
                cam.CameraType = Enum.CameraType.Custom
            end
        end
    end
}):AddKeyPicker('ThirdPersonKeybind', {
    Default = 'V',
    Mode = 'Toggle',
    Text = 'third person toggle',
    NoUI = false
})

CameraGroup:AddSlider('ThirdPersonX', {
    Text = 'offset X',
    Default = 5,
    Min = -20,
    Max = 20,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        ThirdPerson.x = Value
    end
})

CameraGroup:AddSlider('ThirdPersonY', {
    Text = 'offset Y',
    Default = 2,
    Min = -20,
    Max = 20,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        ThirdPerson.y = Value
    end
})

CameraGroup:AddSlider('ThirdPersonZ', {
    Text = 'offset Z',
    Default = 10,
    Min = -20,
    Max = 20,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        ThirdPerson.z = Value
    end
})

-- esp
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('esp')

local ESPSettings = EspLibrary.Settings

ESPGroup:AddToggle('ESPEnabled', {
    Text = 'enable esp',
    Default = false,
    Callback = function(Value)
        ESPSettings.Enabled = Value
        if Value then
            EspLibrary.Load()
        else
            EspLibrary.Unload()
        end
    end
})

ESPGroup:AddToggle('ESPBox', {
    Text = 'box',
    Default = false,
    Callback = function(Value)
        ESPSettings.Box = Value
    end
}):AddColorPicker('ESPBoxColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'box color',
    Callback = function(Value)
        ESPSettings.BoxColor = Value
    end
})

ESPGroup:AddToggle('ESPBoxFill', {
    Text = 'box fill',
    Default = false,
    Callback = function(Value)
        ESPSettings.BoxFill = Value
    end
}):AddColorPicker('ESPBoxFillColor', {
    Default = Color3.new(1, 0, 0),
    Title = 'fill color',
    Callback = function(Value)
        ESPSettings.BoxFillColor = Value
    end
})

ESPGroup:AddToggle('ESPBoxOutline', {
    Text = 'box outline',
    Default = false,
    Callback = function(Value)
        ESPSettings.BoxOutline = Value
    end
}):AddColorPicker('ESPBoxOutlineColor', {
    Default = Color3.new(),
    Title = 'outline color',
    Callback = function(Value)
        ESPSettings.BoxOutlineColor = Value
    end
})

ESPGroup:AddToggle('ESPName', {
    Text = 'name',
    Default = false,
    Callback = function(Value)
        ESPSettings.Name = Value
    end
}):AddColorPicker('ESPNameColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'name color',
    Callback = function(Value)
        ESPSettings.NameColor = Value
    end
})

ESPGroup:AddToggle('ESPHealth', {
    Text = 'health',
    Default = false,
    Callback = function(Value)
        ESPSettings.Health = Value
    end
}):AddColorPicker('ESPHealthColor', {
    Default = Color3.new(0, 1, 0),
    Title = 'health color',
    Callback = function(Value)
        ESPSettings.HealthColor = Value
    end
})

ESPGroup:AddToggle('ESPDistance', {
    Text = 'distance',
    Default = false,
    Callback = function(Value)
        ESPSettings.Distance = Value
    end
}):AddColorPicker('ESPDistanceColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'distance color',
    Callback = function(Value)
        ESPSettings.DistanceColor = Value
    end
})

ESPGroup:AddToggle('ESPSkeleton', {
    Text = 'skeleton',
    Default = false,
    Callback = function(Value)
        ESPSettings.Skeleton = Value
    end
}):AddColorPicker('ESPSkeletonColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'skeleton color',
    Callback = function(Value)
        ESPSettings.SkeletonColor = Value
    end
})

ESPGroup:AddToggle('ESPChams', {
    Text = 'chams',
    Default = false,
    Callback = function(Value)
        ESPSettings.Chams = Value
    end
})

ESPGroup:AddToggle('ESPChamsFill', {
    Text = 'chams fill',
    Default = false,
    Callback = function(Value)
        ESPSettings.ChamsFill = Value
    end
}):AddColorPicker('ESPChamsFillColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'fill color',
    Callback = function(Value)
        ESPSettings.ChamsFillColor = Value
    end
})

ESPGroup:AddToggle('ESPChamsOutline', {
    Text = 'chams outline',
    Default = false,
    Callback = function(Value)
        ESPSettings.ChamsOutline = Value
    end
}):AddColorPicker('ESPChamsOutlineColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'outline color',
    Callback = function(Value)
        ESPSettings.ChamsOutlineColor = Value
    end
})

ESPGroup:AddToggle('ESPChamsVisibleOnly', {
    Text = 'chams visible only',
    Default = false,
    Callback = function(Value)
        ESPSettings.ChamsVisibleOnly = Value
    end
})

-- world effects
local WorldGroup = Tabs.Visuals:AddRightGroupbox('world')

local Lighting = game:GetService("Lighting")
local OldAmbient1 = Lighting.Ambient
local OldAmbient2 = Lighting.OutdoorAmbient
local OldTime = MathFloor(Lighting.ClockTime)

local WorldEffects = {
    time_enabled = false,
    time = OldTime,
    ambient_enabled = false,
    ambient_color1 = Color3.new(1, 1, 1),
    ambient_color2 = Color3.fromRGB(150, 150, 150),
    no_fog = false,
    no_grass = false,
    no_shadows = false
}

WorldGroup:AddToggle('TimeChanger', {
    Text = 'time changer',
    Default = false,
    Callback = function(Value)
        WorldEffects.time_enabled = Value
    end
})

WorldGroup:AddSlider('TimeValue', {
    Text = 'time',
    Default = OldTime,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Callback = function(Value)
        WorldEffects.time = Value
    end
})

WorldGroup:AddToggle('Ambient', {
    Text = 'ambient',
    Default = false,
    Callback = function(Value)
        WorldEffects.ambient_enabled = Value
        if not Value then
            Lighting.Ambient = OldAmbient1
            Lighting.OutdoorAmbient = OldAmbient2
        end
    end
}):AddColorPicker('AmbientColor1', {
    Default = Color3.new(1, 1, 1),
    Title = 'color 1',
    Callback = function(Value)
        WorldEffects.ambient_color1 = Value
    end
}):AddColorPicker('AmbientColor2', {
    Default = Color3.fromRGB(150, 150, 150),
    Title = 'color 2',
    Callback = function(Value)
        WorldEffects.ambient_color2 = Value
    end
})

WorldGroup:AddToggle('NoFog', {
    Text = 'no fog',
    Default = false,
    Callback = function(Value)
        WorldEffects.no_fog = Value
        if Value then
            Lighting.FogStart = math.huge
            Lighting.FogEnd = math.huge
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 1000
        end
    end
})

WorldGroup:AddToggle('NoGrass', {
    Text = 'no grass',
    Default = false,
    Callback = function(Value)
        WorldEffects.no_grass = Value
        local terrain = FindFirstChildOfClass(Workspace, "Terrain")
        if terrain then
            terrain.Decoration = not Value
        end
    end
})

WorldGroup:AddToggle('NoShadows', {
    Text = 'no shadows',
    Default = false,
    Callback = function(Value)
        WorldEffects.no_shadows = Value
        Lighting.GlobalShadows = not Value
    end
})

RunService.RenderStepped:Connect(function()
    if WorldEffects.time_enabled then
        Lighting.ClockTime = WorldEffects.time
    end
    if WorldEffects.ambient_enabled then
        Lighting.Ambient = WorldEffects.ambient_color1
        Lighting.OutdoorAmbient = WorldEffects.ambient_color2
    end
    if WorldEffects.no_shadows then
        Lighting.GlobalShadows = false
    end
    if WorldEffects.no_fog then
        Lighting.FogStart = math.huge
        Lighting.FogEnd = math.huge
    end
end)

-- viewmodel
local ViewmodelGroup = Tabs.Visuals:AddRightGroupbox('viewmodel')

local Viewmodel = {
    x = 0,
    y = 0,
    z = 0,
    gun_chams = false,
    gun_color = Color3.new(1, 1, 1),
    gun_material = "SmoothPlastic",
    arm_chams = false,
    arm_color = Color3.new(1, 1, 1),
    arm_material = "SmoothPlastic"
}

ViewmodelGroup:AddLabel('offset')

ViewmodelGroup:AddSlider('ViewmodelX', {
    Text = 'X',
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        Viewmodel.x = Value
    end
})

ViewmodelGroup:AddSlider('ViewmodelY', {
    Text = 'Y',
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        Viewmodel.y = Value
    end
})

ViewmodelGroup:AddSlider('ViewmodelZ', {
    Text = 'Z',
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        Viewmodel.z = Value
    end
})

ViewmodelGroup:AddToggle('GunChams', {
    Text = 'gun chams',
    Default = false,
    Callback = function(Value)
        Viewmodel.gun_chams = Value
    end
}):AddColorPicker('GunChamsColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'gun color',
    Callback = function(Value)
        Viewmodel.gun_color = Value
    end
})

ViewmodelGroup:AddDropdown('GunChamsMaterial', {
    Text = 'gun material',
    Default = 'SmoothPlastic',
    Values = { 'ForceField', 'Neon', 'SmoothPlastic', 'Glass' },
    Callback = function(Value)
        Viewmodel.gun_material = Value
    end
})

ViewmodelGroup:AddToggle('ArmChams', {
    Text = 'arm chams',
    Default = false,
    Callback = function(Value)
        Viewmodel.arm_chams = Value
    end
}):AddColorPicker('ArmChamsColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'arm color',
    Callback = function(Value)
        Viewmodel.arm_color = Value
    end
})

ViewmodelGroup:AddDropdown('ArmChamsMaterial', {
    Text = 'arm material',
    Default = 'SmoothPlastic',
    Values = { 'ForceField', 'Neon', 'SmoothPlastic', 'Glass' },
    Callback = function(Value)
        Viewmodel.arm_material = Value
    end
})

-- no screen effects
local ScreenEffectsGroup = Tabs.Visuals:AddRightGroupbox('screen effects')

local NoScreenEffects = false

ScreenEffectsGroup:AddToggle('NoScreenEffects', {
    Text = 'no screen effects',
    Default = false,
    Callback = function(Value)
        NoScreenEffects = Value
    end
})

local function applyViewmodelOffset(vm)
    if not vm then return end
    local hrp = FindFirstChild(vm, "HumanoidRootPart")
    if not hrp then return end
    local vec = Vector3New(Viewmodel.x, Viewmodel.y, Viewmodel.z)
    local lua = FindFirstChild(hrp, "LeftUpperArm")
    local rua = FindFirstChild(hrp, "RightUpperArm")
    local ir = FindFirstChild(hrp, "ItemRoot")
    local m6 = FindFirstChild(hrp, "Motor6D")
    if lua then lua.C0 = lua.C0 + vec end
    if rua then rua.C0 = rua.C0 + vec end
    if ir then ir.C0 = ir.C0 + vec end
    if m6 then m6.C0 = m6.C0 + vec end
end

local function applyViewmodelChams(vm)
    if not vm then return end
    local itemView = FindFirstChild(vm, "Item")
    if itemView and Viewmodel.gun_chams then
        for _, v in pairs(itemView:GetDescendants()) do
            if v.ClassName == "MeshPart" or v.ClassName == "Part" then
                v.Material = Enum.Material[Viewmodel.gun_material]
                v.Color = Viewmodel.gun_color
            end
            local surface = FindFirstChildOfClass(v, "SurfaceAppearance")
            if surface then surface:Destroy() end
        end
    end
    if Viewmodel.arm_chams then
        for _, vmItem in pairs(vm:GetChildren()) do
            if vmItem.ClassName == "MeshPart" then
                if vmItem.Name:find("Hand") or vmItem.Name:find("Arm") then
                    vmItem.Material = Enum.Material[Viewmodel.arm_material]
                    vmItem.Color = Viewmodel.arm_color
                end
            end
            if vmItem.ClassName == "Model" then
                local ll = FindFirstChild(vmItem, "LL")
                local lh = FindFirstChild(vmItem, "LH")
                if ll or lh then
                    for _, shirtItem in pairs(vmItem:GetChildren()) do
                        local surface = FindFirstChildOfClass(shirtItem, "SurfaceAppearance")
                        if surface then surface:Destroy() end
                        shirtItem.Material = Enum.Material[Viewmodel.arm_material]
                        shirtItem.Color = Viewmodel.arm_color
                    end
                end
            end
        end
    end
end

Camera.ChildAdded:Connect(applyViewmodelOffset)
Camera.DescendantAdded:Connect(applyViewmodelChams)

RunService.RenderStepped:Connect(function()
    if NoScreenEffects then
        local playergui = LocalPlayer.PlayerGui
        local noinsetgui = playergui and FindFirstChild(playergui, "NoInsetGui")
        local mainframe = noinsetgui and FindFirstChild(noinsetgui, "MainFrame")
        local screeneffects = mainframe and FindFirstChild(mainframe, "ScreenEffects")
        if screeneffects then screeneffects.Visible = false end
    end
end)

-- inventory viewer
local InventoryGroup = Tabs.Visuals:AddLeftGroupbox('inventory viewer')

local InventoryViewer = {
    enabled = false,
    x = 200,
    y = 200,
    delay = 0.25,
    objs = {}
}

local InvDrawObjects = {}

local function InvDrawNew(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do
        obj[i] = v
    end
    InvDrawObjects[#InvDrawObjects + 1] = obj
    return obj
end

local function InvDrawRemoveAll()
    for i, v in pairs(InvDrawObjects) do
        v:Remove()
        table.remove(InvDrawObjects, i)
    end
end

local function InvDrawChangeVis(value)
    for _, v in pairs(InvDrawObjects) do
        v.Visible = value
    end
end

local function InventoryAdd(text, size, pos)
    local textObj = InvDrawNew("Text", {
        Text = text,
        Size = size,
        Font = Drawing.Fonts.Monospace,
        Outline = true,
        Center = false,
        Position = pos + Vector2New(0, (size + 1) * #InventoryViewer.objs),
        Transparency = 1,
        Visible = true,
        Color = Color3.new(1, 1, 1),
        ZIndex = 1,
    })
    InventoryViewer.objs[#InventoryViewer.objs + 1] = textObj
end

local function InventoryRefresh()
    for i, v in InventoryViewer.objs do
        if v then v:Remove() end
        InventoryViewer.objs[i] = nil
    end
end

local function InventoryUpdate(name)
    local rplayers = ReplicatedStorage.Players
    local updateon
    for _, rplayer in next, rplayers:GetChildren() do
        if name == rplayer.Name then
            updateon = rplayer
        end
    end
    if not updateon then return InventoryRefresh() end
    local invPos = Vector2New(InventoryViewer.x, InventoryViewer.y)
    InventoryAdd("" .. updateon.Name .. " Inventory", 13, invPos)
    InventoryAdd("[Inventory]", 13, invPos)
    local inv = FindFirstChild(updateon, "Inventory")
    if inv then
        for _, item in next, inv:GetChildren() do
            local amount = item:GetAttribute("Amount")
            local itemText = amount and (item.Name .. " x" .. amount) or item.Name
            InventoryAdd("    " .. itemText, 13, invPos)
            -- check for nested inventory in clothing/armor
            local nestedInv = FindFirstChild(item, "Inventory")
            if nestedInv then
                for _, nestedItem in next, nestedInv:GetChildren() do
                    local nestedAmount = nestedItem:GetAttribute("Amount")
                    local nestedText = nestedAmount and (nestedItem.Name .. " x" .. nestedAmount) or nestedItem.Name
                    InventoryAdd("        " .. nestedText, 13, invPos)
                end
            end
        end
    end
end

InventoryGroup:AddToggle('InventoryViewer', {
    Text = 'inventory viewer',
    Default = false,
    Callback = function(Value)
        InventoryViewer.enabled = Value
        if not Value then
            InventoryRefresh()
            InvDrawRemoveAll()
        end
    end
})

InventoryGroup:AddSlider('InventoryViewerX', {
    Text = 'X',
    Default = 200,
    Min = 0,
    Max = 700,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        InventoryViewer.x = Value
    end
})

InventoryGroup:AddSlider('InventoryViewerY', {
    Text = 'Y',
    Default = 200,
    Min = 0,
    Max = 700,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        InventoryViewer.y = Value
    end
})

InventoryGroup:AddSlider('InventoryViewerDelay', {
    Text = 'delay',
    Default = 0.25,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        InventoryViewer.delay = Value
    end
})

local InvFrameTimer = tick()
RunService.RenderStepped:Connect(function()
    if (tick() - InvFrameTimer) >= InventoryViewer.delay then
        InvFrameTimer = tick()
        InventoryRefresh()
        if InventoryViewer.enabled and SilentAim.target_part then
            local name = SilentAim.target_part.Parent.Name
            InventoryUpdate(name)
        end
    end
end)

-- settings
local MenuGroup = Tabs.Settings:AddLeftGroupbox('menu')

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'Insert',
    NoUI = true,
    Text = 'UI keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

SaveManager:SetLibrary(Library)
SaveManager:SetFolder('triple7')
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
SaveManager:BuildConfigSection(Tabs.Settings)

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('triple7')
ThemeManager:ApplyToTab(Tabs.Settings)

-- watermark
Library:SetWatermark('triple7 project delta | fps: 60 | ping: 0')
Library:SetWatermarkVisibility(true)
if Library.Watermark then
    Library.Watermark.AnchorPoint = Vector2.new(0.5, 0)
    Library.Watermark.Position = UDim2.new(0.5, 0, 0, 10)
end

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
RunService.RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    local Ping = MathFloor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    Library:SetWatermark(string.format('triple7 project delta | fps: %d | ping: %d', FPS, Ping))
    if Library.Watermark then
        Library.Watermark.AnchorPoint = Vector2.new(0.5, 0)
        Library.Watermark.Position = UDim2.new(0.5, 0, 0, 10)
    end
end)

Library:Notify('triple7 loaded', 10)

loadstring(game:HttpGet(repo .. 'fun/notification.lua'))()