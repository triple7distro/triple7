-- made on earth, by humans.
-- assist LEGIT

wait(1)

local e1_001 = game:GetService("Players")
local e1_002 = game:GetService("RunService")
local e1_003 = game:GetService("UserInputService")
local e1_004 = e1_001.LocalPlayer
local e1_005 = workspace.CurrentCamera

getgenv().e2_001 = true
getgenv().e2_002 = 0.1
getgenv().e2_003 = 250

local e1_006 = Drawing.new("Circle")
e1_006.Thickness = 1
e1_006.Visible = true
e1_006.Color = Color3.fromRGB(111, 111, 111)
e1_006.Transparency = 0

e1_003.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        getgenv().e2_001 = not getgenv().e2_001
    end
end)

e1_003.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.P then
        if not getgenv().rageLoaded then
            getgenv().rageLoaded = true
            getgenv().e2_001 = true
            getgenv().e2_002 = 2
            getgenv().e2_003 = 500
            loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/ee/light.lua"))()
        end
        if not getgenv().rageText then
            local text = Drawing.new("Text")
            text.Text = "NIGGER RAGE ON!!!"
            text.Size = 25
            text.Color = Color3.fromRGB(255, 0, 0)
            text.Outline = true
            text.OutlineColor = Color3.fromRGB(0, 0, 0)
            text.Position = Vector2.new(
                e1_005.ViewportSize.X / 2,
                text.Size / 2 + 3
            )
            text.Center = true
            text.Visible = true
            getgenv().rageText = text
        end
    end
end)

local function e1_007()
    local e1_008 = nil
    local e1_009 = getgenv().e2_003
    local e1_010 = e1_003:GetMouseLocation()

    for e1_011, e1_012 in pairs(e1_001:GetPlayers()) do
        if e1_012 ~= e1_004 and e1_012.Character and e1_012.Character:FindFirstChild("Humanoid") and e1_012.Character.Humanoid.Health > 0 and e1_012.UserId ~= 910871806717 then
            local e1_013 = e1_012.Character:FindFirstChild("HeadHB") or e1_012.Character:FindFirstChild("Head") or e1_012.Character:FindFirstChild("UpperTorso")
            if e1_013 then
                local e1_014, e1_015 = e1_005:WorldToViewportPoint(e1_013.Position)
                if e1_015 then
                    local e1_023 = RaycastParams.new()
                    e1_023.FilterDescendantsInstances = {e1_004.Character}
                    local e1_024 = workspace:Raycast(e1_005.CFrame.Position, (e1_013.Position - e1_005.CFrame.Position).Unit * 1000, e1_023)
                    local e1_025 = e1_024 and e1_024.Instance
                    if e1_025 and (e1_025 == e1_013 or e1_025:IsDescendantOf(e1_012.Character)) then
                        local e1_026 = (Vector2.new(e1_014.X, e1_014.Y) - e1_010).Magnitude
                        if e1_026 < e1_009 then
                            e1_009 = e1_026
                            e1_008 = e1_013
                        end
                    end
                end
            end
        end
    end
    return e1_008
end

e1_002.RenderStepped:Connect(function()
    e1_006.Visible = getgenv().e2_001
    e1_006.Radius = getgenv().e2_003
    e1_006.Position = e1_003:GetMouseLocation()

    if (e1_003:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or e1_003:IsKeyDown(Enum.KeyCode.Z)) and getgenv().e2_001 then
        local e1_017 = e1_007()
        if e1_017 then
            local e1_018, e1_019 = e1_005:WorldToViewportPoint(e1_017.Position)
            local e1_020 = e1_003:GetMouseLocation()
            local e1_021 = (e1_018.X - e1_020.X) * getgenv().e2_002
            local e1_022 = (e1_018.Y - e1_020.Y) * getgenv().e2_002
            if mousemoverel then
                mousemoverel(e1_021, e1_022)
            end
        end
    end
end)
