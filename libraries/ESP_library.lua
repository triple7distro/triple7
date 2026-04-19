return function(utility)
    local esp_table = {}
    local workspace = cloneref(game:GetService("Workspace"))
    local rservice = cloneref(game:GetService("RunService"))
    local plrs = cloneref(game:GetService("Players"))
    local lplr = plrs.LocalPlayer
    local container = Instance.new("Folder", game:GetService("CoreGui").RobloxGui)
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
            local connection; connection = rservice.Heartbeat:Connect(function(delta)
                for _, func in utility.connections.heartbeats do
                    func(delta)
                end
            end)
            local connection1; connection1 = rservice.RenderStepped:Connect(function(delta)
                for _, func in utility.connections.renderstepped do
                    func(delta)
                end
            end)
        
            utility.unload = function()
                connection:Disconnect()
                connection1:Disconnect()
                for key, _ in utility.connections.heartbeats do
                    utility.connections.heartbeats[key] = nil
                end
                for key, _ in utility.connections.renderstepped do
                    utility.connections.heartbeats[key] = nil
                end
            end
        end
    end
    esp_table = {
        __loaded = false,
        main_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.Monospace,
            distancelimit = false,
            maxdistance = 200,
            useteamcolor = false,
            teamcheck = false,
            fadetime = 1
        },
        settings = {
            enemy = {
                enabled = false,

                box = false,
                box_fill = false,
                realname = false,
                displayname = false,
                health = false,
                dist = false,
                weapon = false,
                skeleton = false,

                box_outline = false,
                realname_outline = false,
                displayname_outline = false,
                health_outline = false,
                dist_outline = false,
                weapon_outline = false,

                box_color = { Color3.new(1, 1, 1), 1 },
                box_fill_color = { Color3.new(1, 0, 0), 0.5 },
                realname_color = { Color3.new(1, 1, 1), 1 },
                displayname_color = { Color3.new(1, 1, 1), 1 },
                health_color = { Color3.new(1, 1, 1), 1 },
                dist_color = { Color3.new(1, 1, 1), 1 },
                weapon_color = { Color3.new(1, 1, 1), 1 },
                skeleton_color = { Color3.new(1, 1, 1), 1 },

                box_outline_color = { Color3.new(), 1 },
                realname_outline_color = Color3.new(),
                displayname_outline_color = Color3.new(),
                health_outline_color = Color3.new(),
                dist_outline_color = Color3.new(),
                weapon_outline_color = Color3.new(),

                chams = false,
                chams_visible_only = false,
                chams_fill_color = { Color3.new(1, 1, 1), 0.5 },
                chamsoutline_color = { Color3.new(1, 1, 1), 0 }
            }
        }
    }
    local loaded_plrs = {}
    -- (please update me) vars
    local camera = workspace.CurrentCamera
    local viewportsize = camera.ViewportSize

    -- constants
    local VERTICES = {
        Vector3.new(-1, -1, -1),
        Vector3.new(-1, 1, -1),
        Vector3.new(-1, 1, 1),
        Vector3.new(-1, -1, 1),
        Vector3.new(1, -1, -1),
        Vector3.new(1, 1, -1),
        Vector3.new(1, 1, 1),
        Vector3.new(1, -1, 1)
    }
    local skeleton_order = {
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
    local function getcurrentweapon(character)
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
    local esp = {}
    esp.create_obj = function(type, args)
        local obj = Drawing.new(type)
        for i, v in args do
            obj[i] = v
        end
        return obj
    end



    local function isBodyPart(name)
        return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm")
    end
    local function getBoundingBox(parts)
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

    local function worldToScreen(world)
        local screen, inBounds = camera.WorldToViewportPoint(camera, world)
        return Vector2.new(screen.X, screen.Y), inBounds, screen.Z
    end

    local function calculateCorners(cframe, size)
        local corners = table.create(#VERTICES)
        for i = 1, #VERTICES do
            corners[i] = worldToScreen((cframe + size * 0.5 * VERTICES[i]).Position)
        end

        local min = Vector2.zero.Min(camera.ViewportSize, unpack(corners))
        local max = Vector2.zero.Max(Vector2.zero, unpack(corners))
        return {
            corners = corners,
            topLeft = Vector2.new(math.floor(min.X), math.floor(min.Y)),
            topRight = Vector2.new(math.floor(max.X), math.floor(min.Y)),
            bottomLeft = Vector2.new(math.floor(min.X), math.floor(max.Y)),
            bottomRight = Vector2.new(math.floor(max.X), math.floor(max.Y))
        }
    end

    -- MAINN

    local function create_esp(player)
        if not player then return end
        local settings = esp_table.settings.enemy
        loaded_plrs[player] = {
            obj = {
                box_fill = esp.create_obj("Square", { Filled = true, Visible = false }),
                box_outline = esp.create_obj("Square", { Filled = false, Thickness = 3, Visible = false, ZIndex = -1 }),
                box = esp.create_obj("Square", { Filled = false, Thickness = 1, Visible = false }),
                realname = esp.create_obj("Text", { Center = true, Visible = false }),
                displayname = esp.create_obj("Text", { Center = true, Visible = false }),
                health = esp.create_obj("Text", { Center = false, Visible = false }),
                dist = esp.create_obj("Text", { Center = false, Visible = false }),
                weapon = esp.create_obj("Text", { Center = true, Visible = false }),
            },
            esp = {
                visible = false,
                onscreen = false,
                distance = 0,
                alive = false,
                current_gun = "",
                health = 0,
                max_health = 0,
                corners = nil,
                head = nil,
                cache = {},
                cache_children = 0,
                character = nil
            },
            chams_object = Instance.new("Highlight", container),
            plr_instance = player
        }
        for required, _ in next, skeleton_order do
            loaded_plrs[player].obj["skeleton_" .. required] = esp.create_obj("Line", { Visible = false })
        end
        local plr = loaded_plrs[player]
        plr.connection = utility.new_renderstepped(function(delta)
            local plr = loaded_plrs[player]
            -- setup
            camera = workspace.CurrentCamera
            if not camera then return end
            local obj = plr.obj
            local esp = plr.esp
            local main_settings = esp_table.main_settings
            if settings.enabled and
                (main_settings.teamcheck and lplr.Team ~= player.Team or not main_settings.teamcheck) and
                (player.Character and player.Character:FindFirstChild("Head")) then
                esp.character = player.Character
                local humanoid = esp.character:FindFirstChildOfClass("Humanoid")
                esp.head = esp.character:FindFirstChild("Head")
                local _, onScreen = worldToScreen(esp.head.Position)
                esp.onscreen = onScreen
                if esp.onscreen then
                    esp.distance = (camera.CFrame.p - esp.head.Position).Magnitude
                    esp.health = humanoid and humanoid.Health or 0
                    esp.max_health = humanoid and humanoid.MaxHealth or 1
                    esp.alive = humanoid and humanoid.Health > 0 or false
                    do
                        local cache = {}
                        for i = 1, #esp.character:GetChildren() do
                            local part = esp.character:GetChildren()[i]
                            if part:IsA("BasePart") and isBodyPart(part.Name) then
                                cache[#cache + 1] = part
                            end
                        end
                        esp.corners = calculateCorners(getBoundingBox(cache))
                    end
                    if esp.corners then
                        local box = obj.box
                        local box_outline = obj.box_outline
                        local box_fill = obj.box_fill
                        local health = obj.health
                        local realname = obj.realname
                        local displayname = obj.displayname
                        local dist = obj.dist
                        local weapon = obj.weapon
                        local cham = plr.chams_object
                        local corners = esp.corners

                        cham.Enabled = settings.chams
                        if cham.Enabled then
                            cham.DepthMode = settings.chams_visible_only and 1 or 0
                            cham.Adornee = esp.character
                            cham.FillColor = settings.chams_fill_color[1]
                            cham.FillTransparency = settings.chams_fill_color[2]
                            cham.OutlineColor = settings.chamsoutline_color[1]
                            cham.OutlineTransparency = settings.chamsoutline_color[2]
                        end

                        box.Visible = settings.box
                        box_outline.Visible = box.Visible and settings.box_outline
                        box_fill.Visible = box.Visible and settings.box_fill
                        if box.Visible then
                            box.Position = corners.topLeft
                            box.Size = corners.bottomRight - corners.topLeft
                            box.Color = settings.box_color[1]


                            box_outline.Position = box.Position + Vector2.new(2, 2)
                            box_outline.Size = box.Size - Vector2.new(2, 2)
                            box_outline.Color = settings.box_outline_color[1]

                            box_fill.Position = box.Position
                            box_fill.Size = box.Size
                            box_fill.Color = settings.box_fill_color[1]
                        end

                        realname.Visible = settings.realname
                        if realname.Visible then
                            realname.Size = main_settings.textSize
                            realname.Font = main_settings.textFont
                            realname.Text = player.Name
                            realname.Color = settings.realname_color[1]

                            realname.Outline = settings.realname_outline
                            realname.OutlineColor = settings.realname_outline_color
                            realname.Position = (corners.topLeft + corners.topRight) * 0.5 -
                                Vector2.yAxis * realname.TextBounds.Y - Vector2.new(0, 2)
                        end

                        displayname.Visible = settings.displayname and settings.realname and
                        not player.Name == player.DisplayName
                        if displayname.Visible then
                            displayname.Size = main_settings.textSize
                            displayname.Font = main_settings.textFont
                            displayname.Text = player.DisplayName
                            displayname.Color = settings.displayname_color[1]

                            displayname.Outline = settings.displayname_outline
                            displayname.OutlineColor = settings.displayname_outline_color
                            displayname.Position = (corners.topLeft + corners.topRight) * 0.5 -
                                Vector2.yAxis * displayname.TextBounds.Y -
                                (realname.Visible and Vector2.yAxis * realname.TextBounds.Y or Vector2.zero)
                        end

                        dist.Visible = settings.dist
                        if dist.Visible then
                            dist.Size = main_settings.textSize
                            dist.Font = main_settings.textFont
                            dist.Text = math.round(esp.distance) .. "s"
                            dist.Color = settings.dist_color[1]

                            dist.Outline = settings.dist_outline
                            dist.OutlineColor = settings.dist_outline_color
                            dist.Position = corners.topRight + Vector2.new(2, 0) -
                                Vector2.yAxis * (dist.TextBounds.Y * 0.25)
                        end

                        health.Visible = settings.health
                        if health.Visible then
                            health.Size = main_settings.textSize
                            health.Font = main_settings.textFont
                            health.Text = esp.health
                            health.Color = settings.health_color[1]

                            health.Outline = settings.health_outline
                            health.OutlineColor = settings.health_outline_color
                            health.Position = corners.topLeft - Vector2.new(2, 0) -
                                Vector2.yAxis * (health.TextBounds.Y * 0.25) - 
                                Vector2.xAxis * health.TextBounds.X
                        end

                        weapon.Visible = settings.weapon
                        if weapon.Visible then
                            weapon.Size = main_settings.textSize
                            weapon.Font = main_settings.textFont
                            weapon.Text = esp_table.get_gun(player)
                            weapon.Color = settings.weapon_color[1]

                            weapon.Outline = settings.weapon_outline
                            weapon.OutlineColor = settings.weapon_outline_color
                            weapon.Position = (corners.bottomLeft + corners.bottomRight) * 0.5
                        end
                        task.spawn(function()
                            if (settings.skeleton and esp.character) then
                                for _, part in next, esp.character:GetChildren() do
                                    if skeleton_order[part.Name] and esp.character[part.Name] then
                                        local parent_part = skeleton_order[part.Name]
                                        local part_position, _ = camera:WorldToViewportPoint(part.Position)
                                        local parent_part_position, _ = camera:WorldToViewportPoint(
                                            (
                                                esp.character[parent_part].CFrame
                                            ).Position
                                        )
                                        obj["skeleton_" .. part.Name].From = Vector2.new(part_position.X, part_position
                                        .Y)
                                        obj["skeleton_" .. part.Name].To = Vector2.new(parent_part_position.X,
                                            parent_part_position.Y)
                                        obj["skeleton_" .. part.Name].Color = settings.skeleton_color[1]
                                        obj["skeleton_" .. part.Name].Transparency = settings.skeleton_color[2]
                                        obj["skeleton_" .. part.Name].Visible = true
                                    end
                                end
                            else
                                for required, _ in next, skeleton_order do
                                    if (obj["skeleton_" .. required]) then
                                        obj["skeleton_" .. required].Visible = settings.skeleton
                                    end
                                end
                            end
                        end)
                        if not esp.alive then -- not alive womp womp
                            local fadetime = main_settings.fadetime
                            for _, v in obj do
                                v.Transparency = v.Transparency - (delta / fadetime)
                                if v.Transparency <= 0 then
                                    v.Visible = false
                                end
                            end
                            cham.FillTransparency = cham.FillTransparency - (delta / fadetime)
                            cham.OutlineTransparency = cham.OutlineTransparency - (delta / fadetime)
                            if cham.FillTransparency <= 0 or cham.OutlineTransparency <= 0 then
                                cham.Enabled = false
                            end
                        else
                            box.Transparency = settings.box_color[2]
                            box_outline.Transparency = settings.box_outline_color[2]
                            box_fill.Transparency = settings.box_fill_color[2]
                            realname.Transparency = settings.realname_color[2]
                            displayname.Transparency = settings.displayname_color[2]
                            health.Transparency = settings.health_color[2]
                            dist.Transparency = settings.dist_color[2]
                            weapon.Transparency = settings.weapon_color[2]
                        end
                    else -- disabled, no corners
                        for _, v in obj do v.Visible = false end
                        plr.chams_object.Enabled = false
                    end
                else -- not on screen
                    for _, v in obj do v.Visible = false end
                    plr.chams_object.Enabled = false
                end
            else -- not here
                for _, v in obj do v.Visible = false end
                plr.chams_object.Enabled = false
            end
        end)
    end
    local function destroy_esp(player)
        if not loaded_plrs[player] then return end
        loaded_plrs[player].connection:Disconnect()
        table.foreach(loaded_plrs[player].obj, function(i, v)
            v:Remove()
        end)
        loaded_plrs[player].chams_object:Destroy()
        loaded_plrs[player] = nil
    end

    function esp_table.load()
        assert(not esp_table.__loaded, "[ESP] already loaded");

        for i, v in next, plrs:GetPlayers() do
            task.spawn(function() if v ~= lplr then create_esp(v) end end)
        end

        esp_table.playerAdded = plrs.PlayerAdded:Connect(create_esp);
        esp_table.playerRemoving = plrs.PlayerRemoving:Connect(destroy_esp);
        esp_table.__loaded = true;
    end

    function esp_table.unload()
        assert(esp_table.__loaded, "[ESP] not loaded yet");

        for i, v in next, plrs:GetPlayers() do
            task.spawn(function() destroy_esp(v) end)
        end

        esp_table.playerAdded:Disconnect();
        esp_table.playerRemoving:Disconnect();
        esp_table.__loaded = false;
    end

    function esp_table.get_gun(player)
        return "unknown"
    end

    return esp_table
end
