local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/libraries/UI_library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/libraries/UI_theme.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/libraries/UI_save.lua"))()

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local _CFramenew = CFrame.new
local _Vector2new = Vector2.new
local _Vector3new = Vector3.new
local _IsDescendantOf = game.IsDescendantOf
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _Raycast = Workspace.Raycast
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local mathfloor = math.floor

local Window = Library:CreateWindow({
    Title = "triple7 project delta / 1.2.2 / 19.04.2026",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0
})

local CombatTab = Window:AddTab("combat")
local VisualsTab = Window:AddTab("visual")
local UISettingsTab = Window:AddTab("settings")

local WeaponModsGroup = CombatTab:AddRightGroupbox("weapon mods")

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

WeaponModsGroup:AddToggle("NoRecoil", {
    Text = "no recoil",
    Default = false,
    Tooltip = "sets RecoilStrength to 0",
    Callback = function(value)
        applyWeaponMods()
    end
})

WeaponModsGroup:AddToggle("NoSpread", {
    Text = "no spread",
    Default = false,
    Tooltip = "sets AccuracyDeviation and ProjectileDrop to 0",
    Callback = function(value)
        applyWeaponMods()
    end
})

if ammoTypesFolder then
    ammoTypesFolder.ChildAdded:Connect(function(child)
        task.wait()
        applyWeaponMods()
    end)
end

local SilentAimGroup = CombatTab:AddLeftGroupbox("silent aim")

local silent_aim = {
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

local vischeck_params = RaycastParams.new()
vischeck_params.FilterType = Enum.RaycastFilterType.Exclude
vischeck_params.CollisionGroup = "WeaponRay"
vischeck_params.IgnoreWater = true

local function is_visible(target, target_part)
    if not (target and target_part) then return false end
    vischeck_params.FilterDescendantsInstances = { Workspace.NoCollision, Camera, LocalPlayer.Character }
    local origin = Camera.CFrame.Position
    local castresults = _Raycast(Workspace, origin, target_part.Position - origin, vischeck_params)
    return castresults and castresults.Instance and _IsDescendantOf(castresults.Instance, target)
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
    local mousepos = _Vector2new(Mouse.X, Mouse.Y)
    local GuiInset = game:GetService("GuiService"):GetGuiInset()
    
    if npc then
        for _, zone in pairs(Workspace.AiZones:GetChildren()) do
            for _, npcs in pairs(zone:GetChildren()) do
                local part = _FindFirstChild(npcs, aimpart)
                local humanoid = _FindFirstChildOfClass(npcs, "Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
                    local distance = (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
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
            local part = _FindFirstChild(character, aimpart)
            local humanoid = _FindFirstChildOfClass(character, "Humanoid")
            if part and humanoid and humanoid.Health > 0 then
                local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
                local distance = (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
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

local function make_beam(Origin, Position, Color)
    local part1, part2 = Instance.new("Part", Workspace.NoCollision), Instance.new("Part", Workspace.NoCollision)
    part1.Position = Origin; part2.Position = Position
    part1.Transparency = 1; part2.Transparency = 1
    part1.CanCollide = false; part2.CanCollide = false
    part1.Size = Vector3.zero; part2.Size = Vector3.zero
    part1.Anchored = true; part2.Anchored = true
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local Beam = Instance.new("Beam", Workspace.NoCollision)
    Beam.Name = "Beam"
    Beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color),
        ColorSequenceKeypoint.new(1, Color)
    }
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Texture = "http://www.roblox.com/asset/?id=446111271"
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = 0.25
    Beam.Width1 = 0.25
    return Beam, part1, part2
end

local rpplrs = ReplicatedStorage.Players
local bulletmodule = require(ReplicatedStorage.Modules.FPS.Bullet)
local CreateBullet = bulletmodule.CreateBullet

local function get_local_weapon()
    local Player = rpplrs:FindFirstChild(LocalPlayer.Name)
    if Player and Player:FindFirstChild("Status") and Player.Status:FindFirstChild("GameplayVariables") and Player.Status.GameplayVariables:FindFirstChild("EquippedTool") and Player.Status.GameplayVariables.EquippedTool.Value then
        return Player.Status.GameplayVariables.EquippedTool.Value
    end
    return nil
end

local function is_holding_weapon()
    local weapon = get_local_weapon()
    return weapon ~= nil and weapon.Name ~= "Fists"
end

local got_hook = false
repeat
    for i, gc in next, getgc(true) do
        if type(gc) == "table" then
            if rawget(gc, "CreateBullet") and not got_hook then
                local old_bullet = gc.CreateBullet
                gc.CreateBullet = function(self, ...)
                    local args = { ... }
                    if silent_aim.enabled and is_holding_weapon() then
                        if math.random(1, 100) > silent_aim.hit_chance then
                            return old_bullet(self, unpack(args))
                        end
                        
                        local loadedammo, aimpart_index
                        for i, v in args do
                            if typeof(v) == "Instance" and v.Name == "AimPart" then
                                aimpart_index = i
                            end
                            if type(v) == "string" then
                                local tmp = _FindFirstChild(ReplicatedStorage.AmmoTypes, v)
                                if tmp then loadedammo = tmp end
                            end
                        end
                        
                        if not (loadedammo and aimpart_index) then
                            return old_bullet(self, unpack(args))
                        end
                        
                        if silent_aim.visible_check and not silent_aim.is_visible then
                            return old_bullet(self, unpack(args))
                        end
                        
                        local now = tick()
                        if now - silent_aim.last_shot_time < silent_aim.shot_delay then
                            return old_bullet(self, unpack(args))
                        end
                        silent_aim.last_shot_time = now
                        
                        if silent_aim.tracer and silent_aim.target_part then
                            local beam, p1, p2 = make_beam(args[aimpart_index].Position, silent_aim.target_part.Position, silent_aim.tracer_color)
                            local fade = -1
                            local conn
                            conn = RunService.RenderStepped:Connect(function(delta)
                                fade = fade + delta
                                beam.Transparency = NumberSequence.new(math.clamp(fade, 0, 1))
                                if fade >= 1 then
                                    beam:Destroy()
                                    p1:Destroy()
                                    p2:Destroy()
                                    conn:Disconnect()
                                end
                            end)
                        end
                        
                        if not silent_aim.target_part then
                            return old_bullet(self, unpack(args))
                        end
                        
                        local origin = Camera.CFrame.Position
                        local target_pos = silent_aim.target_part.Position
                        local target_vel = silent_aim.target_part.Velocity
                        local muzzle_vel = loadedammo:GetAttribute("MuzzleVelocity") or 300
                        local predicted = predict_velocity(origin, target_pos, target_vel, muzzle_vel)
                        
                        args[aimpart_index] = { CFrame = _CFramenew(origin, predicted) }
                    end
                    return old_bullet(self, unpack(args))
                end
                got_hook = true
                break
            end
        end
    end
    if not got_hook then task.wait(0.5) end
until got_hook

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() then
        if method == "GetAttribute" and silent_aim.enabled then
            local attr = args[1]
            if attr == "ProjectileDrop" or attr == "Drag" then
                return 0
            end
        end
    end
    return __namecall(self, ...)
end)

SilentAimGroup:AddToggle("SilentAimEnabled", {
    Text = "silent aim",
    Default = false,
    Callback = function(v) silent_aim.enabled = v end
})

SilentAimGroup:AddToggle("SilentAimVisibleCheck", {
    Text = "visible check only",
    Default = true,
    Tooltip = "Only shoot visible targets (safer)",
    Callback = function(v) silent_aim.visible_check = v end
})

SilentAimGroup:AddToggle("SilentAimTargetAI", {
    Text = "target AI",
    Default = false,
    Callback = function(v) silent_aim.target_ai = v end
})

SilentAimGroup:AddDropdown("SilentAimPart", {
    Values = {'Head','FaceHitBox','HeadTopHitbox','UpperTorso','LowerTorso','HumanoidRootPart','LeftFoot','LeftLowerLeg','LeftUpperLeg','LeftHand','LeftLowerArm','LeftUpperArm','RightFoot','RightLowerLeg','RightUpperLeg','RightHand','RightLowerArm','RightUpperArm'},
    Default = 1,
    Multi = false,
    Text = "aim part",
    Callback = function(v) silent_aim.part = v end
})

SilentAimGroup:AddSlider("SilentAimHitChance", {
    Text = "hit chance %",
    Default = 85,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Callback = function(v) silent_aim.hit_chance = v end
})

SilentAimGroup:AddToggle("SilentAimTracer", {
    Text = "bullet tracer",
    Default = false,
    Callback = function(v) silent_aim.tracer = v end
}):AddColorPicker("SilentAimTracerColor", {
    Default = Color3.new(1, 1, 1),
    Title = "tracer color",
    Transparency = 0,
    Callback = function(v) silent_aim.tracer_color = v end
})

SilentAimGroup:AddToggle("SilentAimFOV", {
    Text = "use fov",
    Default = false,
    Callback = function(v) silent_aim.fov_enabled = v end
})

local FOVDepBox = SilentAimGroup:AddDependencyBox()
FOVDepBox:AddToggle("SilentAimFOVShow", {
    Text = "show fov",
    Default = false,
    Callback = function(v) silent_aim.fov_show = v end
}):AddColorPicker("SilentAimFOVColor", {
    Default = Color3.new(1, 1, 1),
    Title = "fov color",
    Transparency = 0,
    Callback = function(v) silent_aim.fov_color = v end
})
FOVDepBox:AddToggle("SilentAimFOVOutline", {
    Text = "fov outline",
    Default = false,
    Callback = function(v) silent_aim.fov_outline = v end
})
FOVDepBox:AddSlider("SilentAimFOVSize", {
    Text = "target fov",
    Default = 150,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(v) silent_aim.fov_size = v end
})
FOVDepBox:SetupDependencies({
    { Toggles.SilentAimFOV, true }
})

SilentAimGroup:AddDropdown("FriendlyPlayers", {
    Text = "friendly players",
    Values = {},
    Default = {},
    Multi = true,
    AllowNull = true,
    Tooltip = "Select players to ignore",
    Callback = function(value)
        silent_aim.friendly_list = value or {}
    end
})

updateFriendlyDropdown()
Players.PlayerAdded:Connect(updateFriendlyDropdown)
Players.PlayerRemoving:Connect(function(plr)
    updateFriendlyDropdown()
    if silent_aim.friendly_list[plr.Name] then
        silent_aim.friendly_list[plr.Name] = nil
    end
end)

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
    CircleOutline.Position = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
    CircleInline.Position = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
    CircleInline.Radius = silent_aim.fov_size
    CircleInline.Color = silent_aim.fov_color
    CircleInline.Visible = silent_aim.fov_enabled and silent_aim.fov_show
    CircleOutline.Radius = silent_aim.fov_size
    CircleOutline.Visible = (silent_aim.fov_enabled and silent_aim.fov_show and silent_aim.fov_outline)
end)

RunService.Heartbeat:Connect(function()
    silent_aim.target_part, silent_aim.is_npc = get_closest_target(
        silent_aim.fov_enabled,
        silent_aim.fov_size,
        silent_aim.part,
        silent_aim.target_ai,
        silent_aim.friendly_list
    )
    silent_aim.is_visible = silent_aim.target_part and is_visible(silent_aim.target_part.Parent, silent_aim.target_part) or false
end)

local CameraGroup = VisualsTab:AddLeftGroupbox("camera")

local fovEnabled = false
local normalFOV = 90
local zoomFOV = 30
local fovConnection = nil

local function getTargetFOV()
    if not Options.CameraZoomKeybind then
        return normalFOV
    end
    local isZoomed = Options.CameraZoomKeybind:GetState()
    return isZoomed and zoomFOV or normalFOV
end

local function forceFOV()
    local cam = Workspace.CurrentCamera
    if cam and fovEnabled then
        local target = getTargetFOV()
        if cam.FieldOfView ~= target then
            cam.FieldOfView = target
        end
    end
end

local function startForcing()
    if fovConnection then return end
    fovConnection = RunService.RenderStepped:Connect(forceFOV)
end

local function stopForcing()
    if fovConnection then
        fovConnection:Disconnect()
        fovConnection = nil
    end
    local cam = Workspace.CurrentCamera
    if cam then
        cam.FieldOfView = 90
    end
end

CameraGroup:AddToggle("EnableCameraFOV", {
    Text = "toggle fov",
    Default = false,
    Callback = function(value)
        fovEnabled = value
        if value then
            startForcing()
        else
            stopForcing()
        end
    end
})

CameraGroup:AddSlider("CameraFOV", {
    Text = "fov",
    Default = 90,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Suffix = "°",
    Callback = function(value) normalFOV = value end
})

CameraGroup:AddSlider("CameraZoomFOV", {
    Text = "zoom fov",
    Default = 30,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Suffix = "°",
    Callback = function(value) zoomFOV = value end
})

CameraGroup:AddLabel("zoom bind"):AddKeyPicker("CameraZoomKeybind", {
    Default = "C",
    Mode = "Hold",
    Text = "camera zoom (hold)",
    NoUI = false
})

local MenuGroup = UISettingsTab:AddLeftGroupbox("menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "Insert",
    NoUI = true,
    Text = "UI keybind"
})
Library.ToggleKeybind = Options.MenuKeybind

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("triple7pd")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:BuildConfigSection(UISettingsTab)

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("triple7pd")
ThemeManager:ApplyToTab(UISettingsTab)

Library:SetWatermark("triple7 project delta | fps: 60 | ping: 0")
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
    local Ping = mathfloor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    Library:SetWatermark(string.format("triple7 project delta | fps: %d | ping: %d", FPS, Ping))
    if Library.Watermark then
        Library.Watermark.AnchorPoint = Vector2.new(0.5, 0)
        Library.Watermark.Position = UDim2.new(0.5, 0, 0, 10)
    end
end)

Library:Notify("triple7 loaded", 3)

loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/fun/notification.lua"))()