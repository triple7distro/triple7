local repo = 'https://raw.githubusercontent.com/triple7distro/triple7/main/'

local Library = loadstring(game:HttpGet(repo .. 'libraries/UI_library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'libraries/UI_theme.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'libraries/UI_save.lua'))()

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
    Callback = function(Value)
        ZoomFOV = Value
    end
})

CameraGroup:AddLabel('zoom bind'):AddKeyPicker('CameraZoomKeybind', {
    Default = 'C',
    Mode = 'Hold',
    Text = 'camera zoom (hold)',
    NoUI = false
})

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