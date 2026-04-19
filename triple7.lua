local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/libraries/UI_library.lua"
))()

local ThemeManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/libraries/UI_theme.lua"
))()

local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/libraries/UI_save.lua"
))()

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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

local OriginalValues = {}
local AmmoTypesFolder = ReplicatedStorage:FindFirstChild("AmmoTypes")

local function ApplyWeaponMods()
    if not AmmoTypesFolder then return end

    for _, ammoType in ipairs(AmmoTypesFolder:GetChildren()) do
        if not ammoType:IsA("Instance") then continue end

        local name = ammoType:GetFullName()
        if not OriginalValues[name] then
            OriginalValues[name] = {
                RecoilStrength = ammoType:GetAttribute("RecoilStrength"),
                ProjectileDrop = ammoType:GetAttribute("ProjectileDrop"),
                AccuracyDeviation = ammoType:GetAttribute("AccuracyDeviation"),
            }
        end

        if Toggles.NoRecoil and Toggles.NoRecoil.Value then
            ammoType:SetAttribute("RecoilStrength", 0)
        else
            local original = OriginalValues[name].RecoilStrength
            if original ~= nil then
                ammoType:SetAttribute("RecoilStrength", original)
            end
        end

        if Toggles.NoSpread and Toggles.NoSpread.Value then
            ammoType:SetAttribute("ProjectileDrop", 0)
            ammoType:SetAttribute("AccuracyDeviation", 0)
        else
            local originalDrop = OriginalValues[name].ProjectileDrop
            local originalAcc = OriginalValues[name].AccuracyDeviation
            if originalDrop ~= nil then
                ammoType:SetAttribute("ProjectileDrop", originalDrop)
            end
            if originalAcc ~= nil then
                ammoType:SetAttribute("AccuracyDeviation", originalAcc)
            end
        end
    end
end

WeaponModsGroup:AddToggle("NoRecoil", {
    Text = "no recoil",
    Default = false,
    Tooltip = "sets RecoilStrength to 0",
    Callback = function() ApplyWeaponMods() end
})

WeaponModsGroup:AddToggle("NoSpread", {
    Text = "no spread",
    Default = false,
    Tooltip = "sets AccuracyDeviation and ProjectileDrop to 0",
    Callback = function() ApplyWeaponMods() end
})

if AmmoTypesFolder then
    AmmoTypesFolder.ChildAdded:Connect(function()
        task.wait()
        ApplyWeaponMods()
    end)
end

local SilentAimGroup = CombatTab:AddLeftGroupbox("silent aim")

local SilentAim = {
    Enabled = false,
    VisibleCheck = true,
    TargetAI = false,
    Part = "Head",
    FovEnabled = false,
    FovSize = 150,
    FovShow = false,
    FovColor = Color3.new(1, 1, 1),
    FovOutline = false,
    HitChance = 85,
    Tracer = false,
    TracerColor = Color3.new(1, 1, 1),
    TargetPart = nil,
    IsVisible = false,
    LastShotTime = 0,
    ShotDelay = 0.08,
    FriendlyList = {}
}

local function UpdateFriendlyDropdown()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    table.sort(playerNames)
    if Options.FriendlyPlayers then
        Options.FriendlyPlayers:SetValues(playerNames)
    end
end

SilentAimGroup:AddDropdown("FriendlyPlayers", {
    Text = "friendly players",
    Values = {},
    Default = {},
    Multi = true,
    AllowNull = true,
    Tooltip = "Select players to ignore",
    Callback = function(value)
        SilentAim.FriendlyList = value or {}
    end
})

UpdateFriendlyDropdown()
Players.PlayerAdded:Connect(UpdateFriendlyDropdown)

Players.PlayerRemoving:Connect(function(player)
    UpdateFriendlyDropdown()
    if SilentAim.FriendlyList[player.Name] then
        SilentAim.FriendlyList[player.Name] = nil
    end
end)

local VisCheckParams = RaycastParams.new()
VisCheckParams.FilterType = Enum.RaycastFilterType.Exclude
VisCheckParams.CollisionGroup = "WeaponRay"
VisCheckParams.IgnoreWater = true

local function IsVisible(target, targetPart)
    if not (target and targetPart) then return false end
    
    VisCheckParams.FilterDescendantsInstances = { 
        Workspace.NoCollision, 
        Camera, 
        LocalPlayer.Character 
    }
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = Raycast(Workspace, origin, direction, VisCheckParams)
    
    return result and result.Instance and IsDescendantOf(result.Instance, target)
end

local function PredictVelocity(origin, destination, destinationVelocity, projectileSpeed)
    local distance = (destination - origin).Magnitude
    if projectileSpeed <= 0 then return destination end
    
    local timeToHit = distance / projectileSpeed
    local predicted = destination + destinationVelocity * timeToHit
    local delta = (predicted - origin).Magnitude / projectileSpeed
    timeToHit = timeToHit + (delta / projectileSpeed)
    
    return destination + destinationVelocity * timeToHit
end

local function GetClosestTarget(useFov, fovSize, aimPart, targetNPC, friendlyList)
    local bestPart, bestIsNPC = nil, false
    local minDistance = useFov and fovSize or math.huge
    local mousePos = Vector2New(Mouse.X, Mouse.Y)
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    
    if targetNPC then
        for _, zone in pairs(Workspace.AiZones:GetChildren()) do
            for _, npc in pairs(zone:GetChildren()) do
                local part = FindFirstChild(npc, aimPart)
                local humanoid = FindFirstChildOfClass(npc, "Humanoid")
                
                if part and humanoid and humanoid.Health > 0 then
                    local position, onScreen = WorldToViewportPoint(Camera, part.Position)
                    local distance = (Vector2New(position.X, position.Y - guiInset.Y) - mousePos).Magnitude
                    
                    if (not useFov or onScreen) and distance < minDistance then
                        bestPart = part
                        minDistance = distance
                        bestIsNPC = true
                    end
                end
            end
        end
    end
    
    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then continue end
        if friendlyList[player.Name] then continue end
        
        local character = player.Character
        if character then
            local part = FindFirstChild(character, aimPart)
            local humanoid = FindFirstChildOfClass(character, "Humanoid")
            
            if part and humanoid and humanoid.Health > 0 then
                local position, onScreen = WorldToViewportPoint(Camera, part.Position)
                local distance = (Vector2New(position.X, position.Y - guiInset.Y) - mousePos).Magnitude
                
                if (not useFov or onScreen) and distance <= minDistance then
                    bestPart = part
                    minDistance = distance
                    bestIsNPC = false
                end
            end
        end
    end
    
    return bestPart, bestIsNPC
end

local function MakeBeam(origin, position, color)
    local part1 = Instance.new("Part", Workspace.NoCollision)
    local part2 = Instance.new("Part", Workspace.NoCollision)
    
    part1.Position = origin
    part2.Position = position
    part1.Transparency = 1
    part2.Transparency = 1
    part1.CanCollide = false
    part2.CanCollide = false
    part1.Size = Vector3.zero
    part2.Size = Vector3.zero
    part1.Anchored = true
    part2.Anchored = true
    
    local originAttachment = Instance.new("Attachment", part1)
    local positionAttachment = Instance.new("Attachment", part2)
    
    local beam = Instance.new("Beam", Workspace.NoCollision)
    beam.Name = "Beam"
    beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color)
    }
    beam.LightEmission = 1
    beam.LightInfluence = 1
    beam.TextureMode = Enum.TextureMode.Static
    beam.TextureSpeed = 0
    beam.Texture = "http://www.roblox.com/asset/?id=446111271"
    beam.Transparency = NumberSequence.new(0)
    beam.Attachment0 = originAttachment
    beam.Attachment1 = positionAttachment
    beam.FaceCamera = true
    beam.Segments = 1
    beam.Width0 = 0.25
    beam.Width1 = 0.25
    
    return beam, part1, part2
end

local ReplicatedPlayers = ReplicatedStorage.Players
local BulletModule = require(ReplicatedStorage.Modules.FPS.Bullet)

local function GetLocalWeapon()
    local player = ReplicatedPlayers:FindFirstChild(LocalPlayer.Name)
    if not player then return nil end
    
    local status = player:FindFirstChild("Status")
    if not status then return nil end
    
    local gameplayVars = status:FindFirstChild("GameplayVariables")
    if not gameplayVars then return nil end
    
    local equippedTool = gameplayVars:FindFirstChild("EquippedTool")
    if equippedTool and equippedTool.Value then
        return equippedTool.Value
    end
    
    return nil
end

local function IsHoldingWeapon()
    local weapon = GetLocalWeapon()
    return weapon ~= nil and weapon.Name ~= "Fists"
end

local GotHook = false

repeat
    for _, gc in next, getgc(true) do
        if type(gc) ~= "table" then continue end
        if not rawget(gc, "CreateBullet") or GotHook then continue end
        
        local OldCreateBullet = gc.CreateBullet
        
        gc.CreateBullet = function(self, ...)
            local args = { ... }
            
            if not SilentAim.Enabled or not IsHoldingWeapon() then
                return OldCreateBullet(self, unpack(args))
            end
            
            if math.random(1, 100) > SilentAim.HitChance then
                return OldCreateBullet(self, unpack(args))
            end
            
            local loadedAmmo, aimPartIndex
            for i, v in args do
                if typeof(v) == "Instance" and v.Name == "AimPart" then
                    aimPartIndex = i
                end
                if type(v) == "string" then
                    local tmp = FindFirstChild(ReplicatedStorage.AmmoTypes, v)
                    if tmp then loadedAmmo = tmp end
                end
            end
            
            if not (loadedAmmo and aimPartIndex) then
                return OldCreateBullet(self, unpack(args))
            end
            
            if SilentAim.VisibleCheck and not SilentAim.IsVisible then
                return OldCreateBullet(self, unpack(args))
            end
            
            local now = tick()
            if now - SilentAim.LastShotTime < SilentAim.ShotDelay then
                return OldCreateBullet(self, unpack(args))
            end
            SilentAim.LastShotTime = now
            
            if SilentAim.Tracer and SilentAim.TargetPart then
                local beam, p1, p2 = MakeBeam(
                    args[aimPartIndex].Position, 
                    SilentAim.TargetPart.Position, 
                    SilentAim.TracerColor
                )
                
                local fade = -1
                local connection
                connection = RunService.RenderStepped:Connect(function(delta)
                    fade = fade + delta
                    beam.Transparency = NumberSequence.new(math.clamp(fade, 0, 1))
                    if fade >= 1 then
                        beam:Destroy()
                        p1:Destroy()
                        p2:Destroy()
                        connection:Disconnect()
                    end
                end)
            end
            
            if not SilentAim.TargetPart then
                return OldCreateBullet(self, unpack(args))
            end
            
            local origin = Camera.CFrame.Position
            local targetPos = SilentAim.TargetPart.Position
            local targetVel = SilentAim.TargetPart.Velocity
            local muzzleVel = loadedAmmo:GetAttribute("MuzzleVelocity") or 300
            local predicted = PredictVelocity(origin, targetPos, targetVel, muzzleVel)
            
            args[aimPartIndex] = { CFrame = CFrameNew(origin, predicted) }
            
            return OldCreateBullet(self, unpack(args))
        end
        
        GotHook = true
        break
    end
    
    if not GotHook then task.wait(0.5) end
until GotHook

local __Namecall
__Namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    
    if not checkcaller() and method == "GetAttribute" and SilentAim.Enabled then
        local attr = args[1]
        if attr == "ProjectileDrop" or attr == "Drag" then
            return 0
        end
    end
    
    return __Namecall(self, ...)
end)

SilentAimGroup:AddToggle("SilentAimEnabled", {
    Text = "silent aim",
    Default = false,
    Callback = function(v) SilentAim.Enabled = v end
})

SilentAimGroup:AddToggle("SilentAimVisibleCheck", {
    Text = "visible check only",
    Default = true,
    Tooltip = "Only shoot visible targets (safer)",
    Callback = function(v) SilentAim.VisibleCheck = v end
})

SilentAimGroup:AddToggle("SilentAimTargetAI", {
    Text = "target AI",
    Default = false,
    Callback = function(v) SilentAim.TargetAI = v end
})

SilentAimGroup:AddDropdown("SilentAimPart", {
    Values = {
        "Head", "FaceHitBox", "HeadTopHitbox", "UpperTorso", "LowerTorso",
        "HumanoidRootPart", "LeftFoot", "LeftLowerLeg", "LeftUpperLeg",
        "LeftHand", "LeftLowerArm", "LeftUpperArm", "RightFoot",
        "RightLowerLeg", "RightUpperLeg", "RightHand", "RightLowerArm", "RightUpperArm"
    },
    Default = 1,
    Multi = false,
    Text = "aim part",
    Callback = function(v) SilentAim.Part = v end
})

SilentAimGroup:AddSlider("SilentAimHitChance", {
    Text = "hit chance %",
    Default = 85,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Callback = function(v) SilentAim.HitChance = v end
})

SilentAimGroup:AddToggle("SilentAimTracer", {
    Text = "bullet tracer",
    Default = false,
    Callback = function(v) SilentAim.Tracer = v end
}):AddColorPicker("SilentAimTracerColor", {
    Default = Color3.new(1, 1, 1),
    Title = "tracer color",
    Transparency = 0,
    Callback = function(v) SilentAim.TracerColor = v end
})

SilentAimGroup:AddToggle("SilentAimFOV", {
    Text = "use fov",
    Default = false,
    Callback = function(v) SilentAim.FovEnabled = v end
})

local FOVDepBox = SilentAimGroup:AddDependencyBox()

FOVDepBox:AddToggle("SilentAimFOVShow", {
    Text = "show fov",
    Default = false,
    Callback = function(v) SilentAim.FovShow = v end
}):AddColorPicker("SilentAimFOVColor", {
    Default = Color3.new(1, 1, 1),
    Title = "fov color",
    Transparency = 0,
    Callback = function(v) SilentAim.FovColor = v end
})

FOVDepBox:AddToggle("SilentAimFOVOutline", {
    Text = "fov outline",
    Default = false,
    Callback = function(v) SilentAim.FovOutline = v end
})

FOVDepBox:AddSlider("SilentAimFOVSize", {
    Text = "target fov",
    Default = 150,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(v) SilentAim.FovSize = v end
})

FOVDepBox:SetupDependencies({
    { Toggles.SilentAimFOV, true }
})

local CircleOutline = Drawing.new("Circle")
local CircleInline = Drawing.new("Circle")

CircleInline.Transparency = 1
CircleInline.Thickness = 1
CircleInline.ZIndex = 2

CircleOutline.Thickness = 3
CircleOutline.Color = Color3.new()
CircleOutline.ZIndex = 1

RunService.RenderStepped:Connect(function()
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    local position = Vector2New(Mouse.X, Mouse.Y + guiInset.Y)
    
    CircleOutline.Position = position
    CircleInline.Position = position
    CircleInline.Radius = SilentAim.FovSize
    CircleInline.Color = SilentAim.FovColor
    CircleInline.Visible = SilentAim.FovEnabled and SilentAim.FovShow
    
    CircleOutline.Radius = SilentAim.FovSize
    CircleOutline.Visible = SilentAim.FovEnabled and SilentAim.FovShow and SilentAim.FovOutline
end)

RunService.Heartbeat:Connect(function()
    SilentAim.TargetPart = GetClosestTarget(
        SilentAim.FovEnabled,
        SilentAim.FovSize,
        SilentAim.Part,
        SilentAim.TargetAI,
        SilentAim.FriendlyList
    )
    
    SilentAim.IsVisible = SilentAim.TargetPart 
        and IsVisible(SilentAim.TargetPart.Parent, SilentAim.TargetPart) 
        or false
end)

local CameraGroup = VisualsTab:AddLeftGroupbox("camera")

local FOVEnabled = false
local NormalFOV = 90
local ZoomFOV = 30
local FOVConnection = nil

local function GetTargetFOV()
    if not Options.CameraZoomKeybind then
        return NormalFOV
    end
    local isZoomed = Options.CameraZoomKeybind:GetState()
    return isZoomed and ZoomFOV or NormalFOV
end

local function ForceFOV()
    local cam = Workspace.CurrentCamera
    if not cam or not FOVEnabled then return end
    
    local target = GetTargetFOV()
    if cam.FieldOfView ~= target then
        cam.FieldOfView = target
    end
end

local function StartForcing()
    if FOVConnection then return end
    FOVConnection = RunService.RenderStepped:Connect(ForceFOV)
end

local function StopForcing()
    if FOVConnection then
        FOVConnection:Disconnect()
        FOVConnection = nil
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
        FOVEnabled = value
        if value then
            StartForcing()
        else
            StopForcing()
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
    Callback = function(value) NormalFOV = value end
})

CameraGroup:AddSlider("CameraZoomFOV", {
    Text = "zoom fov",
    Default = 30,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Suffix = "°",
    Callback = function(value) ZoomFOV = value end
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
    
    local ping = MathFloor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    Library:SetWatermark(string.format("triple7 project delta | fps: %d | ping: %d", FPS, ping))
    
    if Library.Watermark then
        Library.Watermark.AnchorPoint = Vector2.new(0.5, 0)
        Library.Watermark.Position = UDim2.new(0.5, 0, 0, 10)
    end
end)

Library:Notify("triple7 loaded", 3)

loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/fun/pd.lua"
))()