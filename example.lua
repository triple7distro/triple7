-- Triple7 UI Library Example Script
-- This demonstrates all features of the library

-- Load the library from GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/thememanager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/savemanager.lua"))()

-- Create the main window
local Window = Library:CreateWindow({
    Title = "Triple7",
    SubTitle = "Example Hub",
    Size = UDim2.new(0, 600, 0, 450)
})

-- Create a watermark (top-left corner with FPS counter)
Window:CreateWatermark("Triple7 Example")

-- Create a keybind list
Window:CreateKeybindList()

-- ============================================
-- MAIN TAB
-- ============================================
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://7733965119"  -- Home icon
})

-- Left Section
local MainLeft = MainTab:CreateSection({Name = "Basic Elements", Side = "Left"})

MainLeft:AddButton({
    Name = "Test Button",
    Callback = function()
        Library:Notify({
            Title = "Button Clicked!",
            Content = "This is a notification from the button callback",
            Type = "Success",
            Duration = 3
        })
    end
})

MainLeft:AddToggle({
    Name = "God Mode",
    Default = false,
    Flag = "GodMode",
    Callback = function(value)
        Library:Notify({
            Title = "God Mode",
            Content = value and "Enabled" or "Disabled",
            Type = value and "Success" or "Info",
            Duration = 2
        })
    end
})

MainLeft:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(value)
        print("Auto Farm:", value)
    end
})

MainLeft:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Suffix = " studs/sec",
    Flag = "WalkSpeed",
    Callback = function(value)
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

MainLeft:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Increment = 5,
    Suffix = " power",
    Flag = "JumpPower",
    Callback = function(value)
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
    end
})

-- Right Section
local MainRight = MainTab:CreateSection({Name = "Input Elements", Side = "Right"})

MainRight:AddTextBox({
    Name = "Player Name",
    Default = "",
    Placeholder = "Enter target name...",
    Flag = "TargetPlayer",
    Callback = function(text)
        print("Target player:", text)
    end
})

MainRight:AddTextBox({
    Name = "Teleport X Coordinate",
    Default = "0",
    Placeholder = "Enter X coordinate...",
    Numeric = true,
    Flag = "TPX",
    Callback = function(value)
        print("X Coordinate:", value)
    end
})

MainRight:AddDropdown({
    Name = "Select Weapon",
    Values = {"Sword", "Gun", "Bow", "Magic Staff", "Fists"},
    Default = "Sword",
    Flag = "SelectedWeapon",
    Callback = function(value)
        Library:Notify({
            Title = "Weapon Selected",
            Content = "You selected: " .. tostring(value),
            Type = "Info",
            Duration = 2
        })
    end
})

MainRight:AddDropdown({
    Name = "Multi Select (Tags)",
    Values = {"PvP", "Roleplay", "Trading", "Farming", "Social"},
    Default = {},
    Multi = true,
    Flag = "PlayerTags",
    Callback = function(values)
        -- values is a table with true/false for each option
        local selected = {}
        for tag, enabled in pairs(values) do
            if enabled then
                table.insert(selected, tag)
            end
        end
        print("Selected tags:", table.concat(selected, ", "))
    end
})

MainRight:AddKeybind({
    Name = "Menu Keybind",
    Default = Enum.KeyCode.RightShift,
    Flag = "MenuKey",
    Callback = function(key)
        print("Menu key set to:", key.Name)
    end,
    Pressed = function()
        -- Toggle UI visibility
        local mainFrame = Window.UI.MainFrame
        mainFrame.Visible = not mainFrame.Visible
    end
})

MainRight:AddKeybind({
    Name = "Noclip Key",
    Default = Enum.KeyCode.N,
    Flag = "NoclipKey",
    Pressed = function()
        Library:Notify({
            Title = "Noclip",
            Content = "Toggled noclip mode",
            Type = "Info",
            Duration = 2
        })
    end
})

-- ============================================
-- VISUALS TAB
-- ============================================
local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "rbxassetid://7734053495"  -- Eye icon
})

local VisualsLeft = VisualsTab:CreateSection({Name = "ESP Settings", Side = "Left"})

VisualsLeft:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Flag = "ESPEnabled",
    Callback = function(value)
        print("ESP:", value)
    end
})

VisualsLeft:AddToggle({
    Name = "Show Names",
    Default = true,
    Flag = "ESPNames",
    Callback = function(value)
        print("Show Names:", value)
    end
})

VisualsLeft:AddToggle({
    Name = "Show Boxes",
    Default = true,
    Flag = "ESPBoxes",
    Callback = function(value)
        print("Show Boxes:", value)
    end
})

VisualsLeft:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Flag = "ESPTracers",
    Callback = function(value)
        print("Show Tracers:", value)
    end
})

VisualsLeft:AddSlider({
    Name = "ESP Range",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Increment = 100,
    Suffix = " studs",
    Flag = "ESPRange",
    Callback = function(value)
        print("ESP Range:", value)
    end
})

local VisualsRight = VisualsTab:CreateSection({Name = "Colors & Effects", Side = "Right"})

VisualsRight:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        print("ESP Color:", tostring(color))
    end
})

VisualsRight:AddColorPicker({
    Name = "Team Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "TeamESPColor",
    Callback = function(color)
        print("Team Color:", tostring(color))
    end
})

VisualsRight:AddColorPicker({
    Name = "Enemy Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "EnemyESPColor",
    Callback = function(color)
        print("Enemy Color:", tostring(color))
    end
})

VisualsRight:AddLabel("Available ESP Types:")
VisualsRight:AddLabel("- Players")
VisualsRight:AddLabel("- Items")
VisualsRight:AddLabel("- NPCs")

VisualsRight:AddDivider()

VisualsRight:AddButton({
    Name = "Reset to Default",
    Callback = function()
        -- Reset colors
        if Library.Options["ESPColor"] then
            Library.Options["ESPColor"]:SetValue(Color3.fromRGB(255, 0, 0))
        end
        if Library.Options["TeamESPColor"] then
            Library.Options["TeamESPColor"]:SetValue(Color3.fromRGB(0, 255, 0))
        end
        if Library.Options["EnemyESPColor"] then
            Library.Options["EnemyESPColor"]:SetValue(Color3.fromRGB(255, 0, 0))
        end
        
        Library:Notify({
            Title = "Reset",
            Content = "ESP colors reset to default",
            Type = "Success",
            Duration = 2
        })
    end
})

-- ============================================
-- MISC TAB
-- ============================================
local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "rbxassetid://7733954760"  -- Settings/Gear icon
})

local MiscLeft = MiscTab:CreateSection({Name = "Game Modifiers", Side = "Left"})

MiscLeft:AddButton({
    Name = "Unlock Gamepasses",
    Callback = function()
        Library:Notify({
            Title = "Info",
            Content = "This would unlock gamepasses (example only)",
            Type = "Warning",
            Duration = 3
        })
    end
})

MiscLeft:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

MiscLeft:AddButton({
    Name = "Dex Explorer",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end
})

MiscLeft:AddButton({
    Name = "Remote Spy",
    Callback = function()
        Library:Notify({
            Title = "Remote Spy",
            Content = "This would load a remote spy tool",
            Type = "Info",
            Duration = 2
        })
    end
})

MiscLeft:AddDivider()

MiscLeft:AddToggle({
    Name = "Anti AFK",
    Default = true,
    Flag = "AntiAFK",
    Callback = function(value)
        print("Anti AFK:", value)
        if value then
            -- Setup anti-afk
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

local MiscRight = MiscTab:CreateSection({Name = "Fun Stuff", Side = "Right"})

MiscRight:AddButton({
    Name = "Rainbow Character",
    Callback = function()
        Library:Notify({
            Title = "Fun",
            Content = "Rainbow effect applied!",
            Type = "Success",
            Duration = 2
        })
    end
})

MiscRight:AddButton({
    Name = "Big Head",
    Callback = function()
        Library:Notify({
            Title = "Fun",
            Content = "Big head mode toggled!",
            Type = "Success",
            Duration = 2
        })
    end
})

MiscRight:AddButton({
    Name = "Fly (E to toggle)",
    Callback = function()
        Library:Notify({
            Title = "Fly Enabled",
            Content = "Press E to toggle flight",
            Type = "Info",
            Duration = 3
        })
    end
})

MiscRight:AddDivider()

MiscRight:AddSlider({
    Name = "Field of View",
    Min = 30,
    Max = 120,
    Default = 70,
    Increment = 5,
    Suffix = "°",
    Flag = "FOV",
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

MiscRight:AddDropdown({
    Name = "Time of Day",
    Values = {"Dawn", "Day", "Noon", "Dusk", "Night", "Midnight"},
    Default = "Day",
    Callback = function(value)
        local lighting = game:GetService("Lighting")
        local times = {
            Dawn = 6,
            Day = 10,
            Noon = 12,
            Dusk = 18,
            Night = 20,
            Midnight = 0
        }
        lighting.ClockTime = times[value] or 12
    end
})

-- ============================================
-- SETTINGS TAB (Built-in + Custom)
-- ============================================
local SettingsTab = Window:AddSettingsTab()

-- Setup Theme Manager
ThemeManager:SetLibrary(Library)
ThemeManager:CreateThemeSection(SettingsTab, "Left")

-- Setup Save Manager
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("Triple7Example")
SaveManager:CreateConfigSection(SettingsTab, "Right")

-- ============================================
-- INITIALIZATION
-- ============================================

-- Show welcome notification
Library:Notify({
    Title = "Triple7 Loaded",
    Content = "Welcome to Triple7 UI Library Example!",
    Type = "Success",
    Duration = 5
})

-- Load default config if it exists
local configs = SaveManager:GetConfigs()
for _, config in ipairs(configs) do
    if config == "Default" then
        SaveManager:Load("Default")
        Library:Notify({
            Title = "Config Loaded",
            Content = "Default config loaded successfully",
            Type = "Success",
            Duration = 3
        })
        break
    end
end

-- Print loaded flags for debugging
print("=== Triple7 Example Script Loaded ===")
print("Available flags:")
for flag, value in pairs(Library.Flags) do
    print("  " .. flag .. ":", value)
end

-- Export to global for debugging
getgenv().ExampleWindow = Window
getgenv().ExampleLibrary = Library

--[[
Usage Tips:
------------
1. Use Flags to save settings automatically
2. Set Numeric = true for TextBox to only accept numbers
3. Use Multi = true for Dropdown to allow multiple selections
4. Keybinds have both Callback (on set) and Pressed (on key press)
5. Use Library:Notify() for user feedback
6. Access elements via Library.Options[Flag] to modify them later
7. Save configs with SaveManager:Save("ConfigName")
8. Load configs with SaveManager:Load("ConfigName")
9. Switch themes with ThemeManager:ApplyTheme("ThemeName")

Available Themes:
- Default
- Midnight
- Cherry
- Forest
- Ocean
- Amethyst
- Sunset
- Monochrome
- Discord
]]
