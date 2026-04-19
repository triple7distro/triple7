return function(utility)
    local EspTable = {}
    local Workspace = cloneref(game:GetService("Workspace"))
    local RunService = cloneref(game:GetService("RunService"))
    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer
    local Container = Instance.new("Folder", game:GetService("CoreGui").RobloxGui)
    if not utility then
        utility = {
            connections = {
                heartbeats = {},
                renderstepped = {}
            }
        } do
            utility.new_heartbeat = function(func)
                local obj = {}
                utility.connections.heartbeats[func] = func
                function obj:Disconnect()
                    utility.connections.heartbeats[func] = nil
                end
                return obj
            end
            utility.new_renderstepped = function(func)
                local obj = {}
                utility.connections.renderstepped[func] = func
                function obj:Disconnect()
                    utility.connections.renderstepped[func] = nil
                end
                return obj
            end
            local Connection; Connection = RunService.Heartbeat:Connect(function(delta)
                for _, func in utility.connections.heartbeats do
                    func(delta)
                end
            end)
            local Connection1; Connection1 = RunService.RenderStepped:Connect(function(delta)
                for _, func in utility.connections.renderstepped do
                    func(delta)
                end
            end)
        
            utility.unload = function()
                Connection:Disconnect()
                Connection1:Disconnect()
                for key, _ in utility.connections.heartbeats do
                    utility.connections.heartbeats[key] = nil
                end
                for key, _ in utility.connections.renderstepped do
                    utility.connections.heartbeats[key] = nil
                end
            end
        end
    end
    EspTable = {
        Loaded = false,
        MainSettings = {
            TextSize = 15,
            TextFont = Drawing.Fonts.Monospace,
            DistanceLimit = false,
            MaxDistance = 200,
            UseTeamColor = false,
            TeamCheck = false,
            FadeTime = 1
        },
        Settings = {
            Enemy = {
                Enabled = false,

                Box = false,
                BoxFill = false,
                RealName = false,
                DisplayName = false,
                Health = false,
                Distance = false,
                Weapon = false,
                Skeleton = false,

                BoxOutline = false,
                RealNameOutline = false,
                DisplayNameOutline = false,
                HealthOutline = false,
                DistanceOutline = false,
                WeaponOutline = false,

                BoxColor = { Color3.new(1, 1, 1), 1 },
                BoxFillColor = { Color3.new(1, 0, 0), 0.5 },
                RealNameColor = { Color3.new(1, 1, 1), 1 },
                DisplayNameColor = { Color3.new(1, 1, 1), 1 },
                HealthColor = { Color3.new(1, 1, 1), 1 },
                DistanceColor = { Color3.new(1, 1, 1), 1 },
                WeaponColor = { Color3.new(1, 1, 1), 1 },
                SkeletonColor = { Color3.new(1, 1, 1), 1 },

                BoxOutlineColor = { Color3.new(), 1 },
                RealNameOutlineColor = Color3.new(),
                DisplayNameOutlineColor = Color3.new(),
                HealthOutlineColor = Color3.new(),
                DistanceOutlineColor = Color3.new(),
                WeaponOutlineColor = Color3.new(),

                Chams = false,
                ChamsVisibleOnly = false,
                ChamsFillColor = { Color3.new(1, 1, 1), 0.5 },
                ChamsOutlineColor = { Color3.new(1, 1, 1), 0 }
            }
        }
    }
    local LoadedPlayers = {}
    -- vars that need updating
    local Camera = Workspace.CurrentCamera
    local ViewportSize = Camera.ViewportSize

    -- constants
    local Vertices = {
        Vector3.new(-1, -1, -1),
        Vector3.new(-1, 1, -1),
        Vector3.new(-1, 1, 1),
        Vector3.new(-1, -1, 1),
        Vector3.new(1, -1, -1),
        Vector3.new(1, 1, -1),
        Vector3.new(1, 1, 1),
        Vector3.new(1, -1, 1)
    }
    local SkeletonOrder = {
        ["LeftFoot"] = "LeftLowerLeg",
        ["LeftLowerLeg"] = "LeftUpperLeg",
        ["LeftUpperLeg"] = "LowerTorso",

        ["RightFoot"] = "RightLowerLeg",
        ["RightLowerLeg"] = "RightUpperLeg",
        ["RightUpperLeg"] = "LowerTorso",

        ["LeftHand"] = "LeftLowerArm",
        ["LeftLowerArm"] = "LeftUpperArm",
        ["LeftUpperArm"] = "UpperTorso",

        ["RightHand"] = "RightLowerArm",
        ["RightLowerArm"] = "RightUpperArm",
        ["RightUpperArm"] = "UpperTorso",

        ["LowerTorso"] = "UpperTorso",
        ["UpperTorso"] = "Head"
    }
    -- game specific function
    local function GetCurrentWeapon(character)
        --return "None"
        local gun = "None"
        for _, v in character:GetChildren() do
            if v and v.ClassName == "Model" and not v.Name:find("Holster") and v:FindFirstChild("FlashPart") then
                gun = v.Name
            end
        end

        return gun
    end
    -- functions
    local Esp = {}
    Esp.CreateObj = function(type, args)
        local obj = Drawing.new(type)
        for i, v in args do
            obj[i] = v
        end
        return obj
    end



    local function IsBodyPart(name)
        return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm")
    end
    local function GetBoundingBox(parts)
        local min, max
        for i = 1, #parts do
            local part = parts[i]
            local cframe, size = part.CFrame, part.Size

            min = Vector3.zero.Min(min or cframe.Position, (cframe - size * 0.5).Position)
            max = Vector3.zero.Max(max or cframe.Position, (cframe + size * 0.5).Position)
        end

        local center = (min + max) * 0.5
        local front = Vector3.new(center.X, center.Y, max.Z)
        return CFrame.new(center, front), max - min
    end

    local function WorldToScreen(world)
        local screen, inBounds = Camera.WorldToViewportPoint(Camera, world)
        return Vector2.new(screen.X, screen.Y), inBounds, screen.Z
    end

    local function CalculateCorners(cframe, size)
        local corners = table.create(#Vertices)
        for i = 1, #Vertices do
            corners[i] = WorldToScreen((cframe + size * 0.5 * Vertices[i]).Position)
        end

        local min = Vector2.zero.Min(Camera.ViewportSize, unpack(corners))
        local max = Vector2.zero.Max(Vector2.zero, unpack(corners))
        return {
            corners = corners,
            topLeft = Vector2.new(math.floor(min.X), math.floor(min.Y)),
            topRight = Vector2.new(math.floor(max.X), math.floor(min.Y)),
            bottomLeft = Vector2.new(math.floor(min.X), math.floor(max.Y)),
            bottomRight = Vector2.new(math.floor(max.X), math.floor(max.Y))
        }
    end

    -- main esp function

    local function CreateEsp(player)
        if not player then return end
        local settings = EspTable.Settings.Enemy
        LoadedPlayers[player] = {
            Obj = {
                BoxFill = Esp.CreateObj("Square", { Filled = true, Visible = false }),
                BoxOutline = Esp.CreateObj("Square", { Filled = false, Thickness = 3, Visible = false, ZIndex = -1 }),
                Box = Esp.CreateObj("Square", { Filled = false, Thickness = 1, Visible = false }),
                RealName = Esp.CreateObj("Text", { Center = true, Visible = false }),
                DisplayName = Esp.CreateObj("Text", { Center = true, Visible = false }),
                Health = Esp.CreateObj("Text", { Center = false, Visible = false }),
                Distance = Esp.CreateObj("Text", { Center = false, Visible = false }),
                Weapon = Esp.CreateObj("Text", { Center = true, Visible = false }),
            },
            EspData = {
                Visible = false,
                OnScreen = false,
                Distance = 0,
                Alive = false,
                CurrentGun = "",
                Health = 0,
                MaxHealth = 0,
                Corners = nil,
                Head = nil,
                Cache = {},
                CacheChildren = 0,
                Character = nil
            },
            ChamsObject = Instance.new("Highlight", Container),
            PlayerInstance = player
        }
        for required, _ in next, SkeletonOrder do
            LoadedPlayers[player].Obj["skeleton_" .. required] = Esp.CreateObj("Line", { Visible = false })
        end
        local plr = LoadedPlayers[player]
        plr.Connection = utility.new_renderstepped(function(delta)
            local plr = LoadedPlayers[player]
            -- setup
            Camera = Workspace.CurrentCamera
            if not Camera then return end
            local obj = plr.Obj
            local espData = plr.EspData
            local mainSettings = EspTable.MainSettings
            if settings.Enabled and
                (mainSettings.TeamCheck and LocalPlayer.Team ~= player.Team or not mainSettings.TeamCheck) and
                (player.Character and player.Character:FindFirstChild("Head")) then
                espData.Character = player.Character
                local humanoid = espData.Character:FindFirstChildOfClass("Humanoid")
                espData.Head = espData.Character:FindFirstChild("Head")
                local _, onScreen = WorldToScreen(espData.Head.Position)
                espData.OnScreen = onScreen
                if espData.OnScreen then
                    espData.Distance = (Camera.CFrame.p - espData.Head.Position).Magnitude
                    espData.Health = humanoid and humanoid.Health or 0
                    espData.MaxHealth = humanoid and humanoid.MaxHealth or 1
                    espData.Alive = humanoid and humanoid.Health > 0 or false
                    do
                        local cache = {}
                        for i = 1, #espData.Character:GetChildren() do
                            local part = espData.Character:GetChildren()[i]
                            if part:IsA("BasePart") and IsBodyPart(part.Name) then
                                cache[#cache + 1] = part
                            end
                        end
                        espData.Corners = CalculateCorners(GetBoundingBox(cache))
                    end
                    if espData.Corners then
                        local box = obj.Box
                        local boxOutline = obj.BoxOutline
                        local boxFill = obj.BoxFill
                        local health = obj.Health
                        local realname = obj.RealName
                        local displayname = obj.DisplayName
                        local dist = obj.Distance
                        local weapon = obj.Weapon
                        local cham = plr.ChamsObject
                        local corners = espData.Corners

                        cham.Enabled = settings.Chams
                        if cham.Enabled then
                            cham.DepthMode = settings.ChamsVisibleOnly and 1 or 0
                            cham.Adornee = espData.Character
                            cham.FillColor = settings.ChamsFillColor[1]
                            cham.FillTransparency = settings.ChamsFillColor[2]
                            cham.OutlineColor = settings.ChamsOutlineColor[1]
                            cham.OutlineTransparency = settings.ChamsOutlineColor[2]
                        end

                        box.Visible = settings.Box
                        boxOutline.Visible = box.Visible and settings.BoxOutline
                        if box.Visible then
                            box.Position = corners.topLeft
                            box.Size = corners.bottomRight - corners.topLeft
                            box.Color = settings.BoxColor[1]


                            boxOutline.Position = box.Position + Vector2.new(2, 2)
                            boxOutline.Size = box.Size - Vector2.new(2, 2)
                            boxOutline.Color = settings.BoxOutlineColor[1]

                            boxFill.Position = box.Position
                            boxFill.Size = box.Size
                            boxFill.Color = settings.BoxFillColor[1]
                        end

                        realname.Visible = settings.RealName
                        if realname.Visible then
                            realname.Size = mainSettings.TextSize
                            realname.Font = mainSettings.TextFont
                            realname.Text = player.Name
                            realname.Color = settings.RealNameColor[1]

                            realname.Outline = settings.RealNameOutline
                            realname.OutlineColor = settings.RealNameOutlineColor
                            realname.Position = (corners.topLeft + corners.topRight) * 0.5 -
                                Vector2.yAxis * realname.TextBounds.Y - Vector2.new(0, 2)
                        end

                        displayname.Visible = settings.DisplayName and settings.RealName and
                        not player.Name == player.DisplayName
                        if displayname.Visible then
                            displayname.Size = mainSettings.TextSize
                            displayname.Font = mainSettings.TextFont
                            displayname.Text = player.DisplayName
                            displayname.Color = settings.DisplayNameColor[1]

                            displayname.Outline = settings.DisplayNameOutline
                            displayname.OutlineColor = settings.DisplayNameOutlineColor
                            displayname.Position = (corners.topLeft + corners.topRight) * 0.5 -
                                Vector2.yAxis * displayname.TextBounds.Y -
                                (realname.Visible and Vector2.yAxis * realname.TextBounds.Y or Vector2.zero)
                        end

                        dist.Visible = settings.Distance
                        if dist.Visible then
                            dist.Size = mainSettings.TextSize
                            dist.Font = mainSettings.TextFont
                            dist.Text = math.round(espData.Distance) .. "s"
                            dist.Color = settings.DistanceColor[1]

                            dist.Outline = settings.DistanceOutline
                            dist.OutlineColor = settings.DistanceOutlineColor
                            dist.Position = corners.topRight + Vector2.new(2, 0) -
                                Vector2.yAxis * (dist.TextBounds.Y * 0.25)
                        end

                        health.Visible = settings.Health
                        if health.Visible then
                            health.Size = mainSettings.TextSize
                            health.Font = mainSettings.TextFont
                            health.Text = espData.Health
                            health.Color = settings.HealthColor[1]

                            health.Outline = settings.HealthOutline
                            health.OutlineColor = settings.HealthOutlineColor
                            health.Position = corners.topLeft - Vector2.new(2, 0) -
                                Vector2.yAxis * (health.TextBounds.Y * 0.25) - 
                                Vector2.xAxis * health.TextBounds.X
                        end

                        weapon.Visible = settings.Weapon
                        if weapon.Visible then
                            weapon.Size = mainSettings.TextSize
                            weapon.Font = mainSettings.TextFont
                            weapon.Text = EspTable.GetGun(player)
                            weapon.Color = settings.WeaponColor[1]

                            weapon.Outline = settings.WeaponOutline
                            weapon.OutlineColor = settings.WeaponOutlineColor
                            weapon.Position = (corners.bottomLeft + corners.bottomRight) * 0.5
                        end
                        task.spawn(function()
                            if (settings.Skeleton and espData.Character) then
                                for _, part in next, espData.Character:GetChildren() do
                                    if SkeletonOrder[part.Name] and espData.Character[part.Name] then
                                        local parentPart = SkeletonOrder[part.Name]
                                        local partPosition, _ = Camera:WorldToViewportPoint(part.Position)
                                        local parentPartPosition, _ = Camera:WorldToViewportPoint(
                                            (
                                                espData.Character[parentPart].CFrame
                                            ).Position
                                        )
                                        obj["skeleton_" .. part.Name].From = Vector2.new(partPosition.X, partPosition
                                        .Y)
                                        obj["skeleton_" .. part.Name].To = Vector2.new(parentPartPosition.X,
                                            parentPartPosition.Y)
                                        obj["skeleton_" .. part.Name].Color = settings.SkeletonColor[1]
                                        obj["skeleton_" .. part.Name].Transparency = settings.SkeletonColor[2]
                                        obj["skeleton_" .. part.Name].Visible = true
                                    end
                                end
                            else
                                for required, _ in next, SkeletonOrder do
                                    if (obj["skeleton_" .. required]) then
                                        obj["skeleton_" .. required].Visible = settings.Skeleton
                                    end
                                end
                            end
                        end)
                        if not espData.Alive then -- not alive
                            local fadeTime = mainSettings.FadeTime
                            for _, v in obj do
                                v.Transparency = v.Transparency - (delta / fadeTime)
                                if v.Transparency <= 0 then
                                    v.Visible = false
                                end
                            end
                            cham.FillTransparency = cham.FillTransparency - (delta / fadeTime)
                            cham.OutlineTransparency = cham.OutlineTransparency - (delta / fadeTime)
                            if cham.FillTransparency <= 0 or cham.OutlineTransparency <= 0 then
                                cham.Enabled = false
                            end
                        else
                            box.Transparency = settings.BoxColor[2]
                            boxOutline.Transparency = settings.BoxOutlineColor[2]
                            boxFill.Transparency = settings.BoxFillColor[2]
                            realname.Transparency = settings.RealNameColor[2]
                            displayname.Transparency = settings.DisplayNameColor[2]
                            health.Transparency = settings.HealthColor[2]
                            dist.Transparency = settings.DistanceColor[2]
                            weapon.Transparency = settings.WeaponColor[2]
                        end
                    else -- disabled, no corners
                        for _, v in obj do v.Visible = false end
                        plr.ChamsObject.Enabled = false
                    end
                else -- not on screen
                    for _, v in obj do v.Visible = false end
                    plr.ChamsObject.Enabled = false
                end
            else -- not here
                for _, v in obj do v.Visible = false end
                plr.ChamsObject.Enabled = false
            end
        end)
    end
    local function DestroyEsp(player)
        if not LoadedPlayers[player] then return end
        LoadedPlayers[player].Connection:Disconnect()
        table.foreach(LoadedPlayers[player].Obj, function(i, v)
            v:Remove()
        end)
        LoadedPlayers[player].ChamsObject:Destroy()
        LoadedPlayers[player] = nil
    end

    function EspTable.Load()
        assert(not EspTable.Loaded, "[ESP] already loaded");

        for i, v in next, Players:GetPlayers() do
            task.spawn(function() if v ~= LocalPlayer then CreateEsp(v) end end)
        end

        EspTable.PlayerAdded = Players.PlayerAdded:Connect(CreateEsp);
        EspTable.PlayerRemoving = Players.PlayerRemoving:Connect(DestroyEsp);
        EspTable.Loaded = true;
    end

    function EspTable.Unload()
        assert(EspTable.Loaded, "[ESP] not loaded yet");

        for i, v in next, Players:GetPlayers() do
            task.spawn(function() DestroyEsp(v) end)
        end

        EspTable.PlayerAdded:Disconnect();
        EspTable.PlayerRemoving:Disconnect();
        EspTable.Loaded = false;
    end

    function EspTable.GetGun(player)
        return "unknown"
    end

    return EspTable
end
