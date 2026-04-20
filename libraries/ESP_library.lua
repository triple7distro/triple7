local Esp = {}
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- settings
Esp.Settings = {
    Enabled = false,
    Box = false,
    BoxFill = false,
    BoxOutline = false,
    Name = false,
    Health = false,
    Distance = false,
    Skeleton = false,
    Chams = false,
    ChamsFill = false,
    ChamsOutline = false,
    ChamsVisibleOnly = false,
    MaxDistance = 1000,

    BoxColor = Color3.new(1, 1, 1),
    BoxFillColor = Color3.new(1, 0, 0),
    BoxOutlineColor = Color3.new(),
    NameColor = Color3.new(1, 1, 1),
    HealthColor = Color3.new(0, 1, 0),
    DistanceColor = Color3.new(1, 1, 1),
    SkeletonColor = Color3.new(1, 1, 1),
    ChamsFillColor = Color3.new(1, 1, 1),
    ChamsOutlineColor = Color3.new(1, 1, 1),

    TextSize = 13,
    TextFont = Drawing.Fonts.Monospace,
}

-- internal vars
local PlayerObjects = {}
local Connections = {}
local Container = Instance.new("Folder")
Container.Name = "ESPHolder"
Container.Parent = game:GetService("CoreGui")

-- skeleton parts (child -> parent)
local SkeletonParts = {
    Head = "UpperTorso",
    LowerTorso = "UpperTorso",
    LeftUpperLeg = "LowerTorso",
    LeftLowerLeg = "LeftUpperLeg",
    LeftFoot = "LeftLowerLeg",
    RightUpperLeg = "LowerTorso",
    RightLowerLeg = "RightUpperLeg",
    RightFoot = "RightLowerLeg",
    LeftUpperArm = "UpperTorso",
    LeftLowerArm = "LeftUpperArm",
    LeftHand = "LeftLowerArm",
    RightUpperArm = "UpperTorso",
    RightLowerArm = "RightUpperArm",
    RightHand = "RightLowerArm",
}

local function NewDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function WorldToScreen(pos)
    local screen, onscreen = Camera.WorldToViewportPoint(Camera, pos)
    return Vector2.new(screen.X, screen.Y), onscreen, screen.Z
end

local function GetBoundingBox(character)
    local min, max
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local cframe, size = part.CFrame, part.Size
            min = Vector3.zero.Min(min or cframe.Position, (cframe - size * 0.5).Position)
            max = Vector3.zero.Max(max or cframe.Position, (cframe + size * 0.5).Position)
        end
    end
    if not min or not max then return nil end
    return min, max
end

local function IsTeammate(player)
    if not player or not LocalPlayer then return false end
    return player.Team == LocalPlayer.Team
end

local function GetHealth(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)
    end
    return 0, 100
end


local function CreatePlayerEsp(player)
    if player == LocalPlayer then return end
    if PlayerObjects[player] then return end

    local objects = {
        Box = NewDrawing("Square", { Thickness = 1, Filled = false, Visible = false }),
        BoxOutline = NewDrawing("Square", { Thickness = 3, Filled = false, Visible = false }),
        BoxFill = NewDrawing("Square", { Thickness = 1, Filled = true, Visible = false }),
        Name = NewDrawing("Text", { Size = Esp.Settings.TextSize, Font = Esp.Settings.TextFont, Center = true, Outline = true, Visible = false }),
        Health = NewDrawing("Text", { Size = Esp.Settings.TextSize, Font = Esp.Settings.TextFont, Center = true, Outline = true, Visible = false }),
        Distance = NewDrawing("Text", { Size = Esp.Settings.TextSize, Font = Esp.Settings.TextFont, Center = true, Outline = true, Visible = false }),
        Chams = Instance.new("Highlight"),
    }

    -- skeleton lines
    for partName, _ in pairs(SkeletonParts) do
        objects["Skeleton_" .. partName] = NewDrawing("Line", { Thickness = 1, Visible = false })
    end

    objects.Chams.Parent = Container
    objects.Chams.Name = player.Name .. "_Chams"

    PlayerObjects[player] = objects
end

local function RemovePlayerEsp(player)
    local objects = PlayerObjects[player]
    if not objects then return end

    for _, obj in pairs(objects) do
        if typeof(obj) == "Instance" then
            obj:Destroy()
        else
            obj:Remove()
        end
    end

    PlayerObjects[player] = nil
end

local function UpdatePlayerEsp(player, delta)
    local objects = PlayerObjects[player]
    if not objects then return end

    local settings = Esp.Settings
    if not settings.Enabled then
        for _, obj in pairs(objects) do
            if typeof(obj) ~= "Instance" then
                obj.Visible = false
            else
                obj.Enabled = false
            end
        end
        return
    end

    if settings.TeamCheck and IsTeammate(player) then
        for _, obj in pairs(objects) do
            if typeof(obj) ~= "Instance" then
                obj.Visible = false
            else
                obj.Enabled = false
            end
        end
        return
    end

    local character = player.Character
    if not character then
        for _, obj in pairs(objects) do
            if typeof(obj) ~= "Instance" then
                obj.Visible = false
            else
                obj.Enabled = false
            end
        end
        return
    end

    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid or humanoid.Health <= 0 then
        for _, obj in pairs(objects) do
            if typeof(obj) ~= "Instance" then
                obj.Visible = false
            else
                obj.Enabled = false
            end
        end
        return
    end

    local headPos, onscreen = WorldToScreen(head.Position)
    if not onscreen then
        for _, obj in pairs(objects) do
            if typeof(obj) ~= "Instance" then
                obj.Visible = false
            else
                obj.Enabled = false
            end
        end
        return
    end

    local min, max = GetBoundingBox(character)
    if not min or not max then return end

    -- Get all 8 corners of the bounding box and project to screen
    local corners = {
        Vector3.new(min.X, min.Y, min.Z),
        Vector3.new(min.X, min.Y, max.Z),
        Vector3.new(min.X, max.Y, min.Z),
        Vector3.new(min.X, max.Y, max.Z),
        Vector3.new(max.X, min.Y, min.Z),
        Vector3.new(max.X, min.Y, max.Z),
        Vector3.new(max.X, max.Y, min.Z),
        Vector3.new(max.X, max.Y, max.Z),
    }

    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge

    for _, corner in ipairs(corners) do
        local screenPos, onscreen = WorldToScreen(corner)
        if onscreen then
            minX = math.min(minX, screenPos.X)
            minY = math.min(minY, screenPos.Y)
            maxX = math.max(maxX, screenPos.X)
            maxY = math.max(maxY, screenPos.Y)
        end
    end

    if minX == math.huge then return end

    local boxPos = Vector2.new(minX, minY)
    local boxSize = Vector2.new(maxX - minX, maxY - minY)

    local distance = (Camera.CFrame.Position - head.Position).Magnitude
    if settings.MaxDistance > 0 and distance > settings.MaxDistance then
        for _, obj in pairs(objects) do
            if typeof(obj) ~= "Instance" then
                obj.Visible = false
            else
                obj.Enabled = false
            end
        end
        return
    end

    -- box
    if settings.Box then
        objects.Box.Visible = true
        objects.Box.Position = boxPos
        objects.Box.Size = boxSize
        objects.Box.Color = settings.BoxColor

        objects.BoxOutline.Visible = settings.BoxOutline
        objects.BoxOutline.Position = boxPos
        objects.BoxOutline.Size = boxSize
        objects.BoxOutline.Color = settings.BoxOutlineColor

        objects.BoxFill.Visible = settings.BoxFill
        objects.BoxFill.Position = boxPos
        objects.BoxFill.Size = boxSize
        objects.BoxFill.Color = settings.BoxFillColor
        objects.BoxFill.Transparency = 0.5
    else
        objects.Box.Visible = false
        objects.BoxOutline.Visible = false
        objects.BoxFill.Visible = false
    end

    local boxCenterX = boxPos.X + boxSize.X / 2

    -- name
    if settings.Name then
        objects.Name.Visible = true
        objects.Name.Text = player.Name
        objects.Name.Position = boxPos - Vector2.new(0, objects.Name.TextBounds.Y + 2)
        objects.Name.Color = settings.NameColor
    else
        objects.Name.Visible = false
    end

    -- health
    if settings.Health then
        local hp, maxhp = GetHealth(character)
        objects.Health.Visible = true
        objects.Health.Text = tostring(hp)
        objects.Health.Position = boxPos - Vector2.new(objects.Health.TextBounds.X + 4, 0)
        objects.Health.Color = settings.HealthColor
    else
        objects.Health.Visible = false
    end

    -- distance
    if settings.Distance then
        objects.Distance.Visible = true
        objects.Distance.Text = math.floor(distance) .. "m"
        objects.Distance.Position = Vector2.new(boxCenterX, boxPos.Y + boxSize.Y + 2)
        objects.Distance.Color = settings.DistanceColor
    else
        objects.Distance.Visible = false
    end

    -- chams
    if settings.Chams then
        objects.Chams.Enabled = true
        objects.Chams.Adornee = character
        objects.Chams.FillColor = settings.ChamsFillColor
        objects.Chams.OutlineColor = settings.ChamsOutlineColor
        objects.Chams.FillTransparency = settings.ChamsFill and 0.5 or 1
        objects.Chams.OutlineTransparency = settings.ChamsOutline and 0 or 1
        objects.Chams.DepthMode = settings.ChamsVisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
    else
        objects.Chams.Enabled = false
    end

    -- skeleton
    if settings.Skeleton then
        for partName, parentName in pairs(SkeletonParts) do
            local part = character:FindFirstChild(partName)
            local parent = character:FindFirstChild(parentName)
            local line = objects["Skeleton_" .. partName]

            if part and parent and line then
                local pos1 = WorldToScreen(part.Position)
                local pos2 = WorldToScreen(parent.Position)
                line.From = pos1
                line.To = pos2
                line.Color = settings.SkeletonColor
                line.Visible = true
            elseif line then
                line.Visible = false
            end
        end
    else
        for partName, _ in pairs(SkeletonParts) do
            local line = objects["Skeleton_" .. partName]
            if line then line.Visible = false end
        end
    end
end

function Esp.Load()
    if Esp.Loaded then return end
    Esp.Loaded = true

    -- create esp for existing players
    for _, player in pairs(Players:GetPlayers()) do
        CreatePlayerEsp(player)
    end

    -- connections
    Connections.PlayerAdded = Players.PlayerAdded:Connect(CreatePlayerEsp)
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(RemovePlayerEsp)
    Connections.RenderStepped = RunService.RenderStepped:Connect(function(delta)
        if not Esp.Settings.Enabled then return end
        for player, _ in pairs(PlayerObjects) do
            UpdatePlayerEsp(player, delta)
        end
    end)
end

function Esp.Unload()
    if not Esp.Loaded then return end
    Esp.Loaded = false

    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    table.clear(Connections)

    for player, _ in pairs(PlayerObjects) do
        RemovePlayerEsp(player)
    end
end

return Esp
