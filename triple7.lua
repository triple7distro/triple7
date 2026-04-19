-- Triple7 UI Library Loader
-- Main entry point for the library

-- Load the library from GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/thememanager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/triple7/refs/heads/main/savemanager.lua"))()

-- Example Usage:
--[[
local Window = Library:CreateWindow({
    Title = "Triple7",
    SubTitle = "Hub",
    Size = UDim2.new(0, 550, 0, 400)
})

-- Create Watermark
Window:CreateWatermark("Triple7 Hub")

-- Create Keybind List
Window:CreateKeybindList()

-- Create Tabs
local MainTab = Window:CreateTab({Name = "Main", Icon = "rbxassetid://7733965119"})
local PlayerTab = Window:CreateTab({Name = "Player", Icon = "rbxassetid://7733774602"})
local VisualsTab = Window:CreateTab({Name = "Visuals", Icon = "rbxassetid://7734053495"})
local MiscTab = Window:CreateTab({Name = "Misc", Icon = "rbxassetid://7733954760"})

-- Setup Theme Manager
ThemeManager:SetLibrary(Library)

-- Setup Save Manager
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("Triple7Hub/configs")
SaveManager:BuildFolderTree()

-- Create Settings Tab with built-in sections
local SettingsTab = Window:AddSettingsTab()
ThemeManager:CreateThemeSection(SettingsTab, "Left")
SaveManager:CreateConfigSection(SettingsTab, "Right")

-- Add elements to Main Tab
local MainSection = MainTab:CreateSection({Name = "Main Features", Side = "Left"})

MainSection:AddButton({
    Name = "Click Me",
    Callback = function()
        Library:Notify({
            Title = "Button Clicked",
            Content = "You clicked the button!",
            Duration = 3
        })
    end
})

MainSection:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Feature enabled:", value)
    end
})

MainSection:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Flag = "SpeedValue",
    Callback = function(value)
        print("Speed:", value)
    end
})

MainSection:AddDropdown({
    Name = "Select Option",
    Values = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Flag = "SelectedOption",
    Callback = function(value)
        print("Selected:", value)
    end
})

MainSection:AddKeybind({
    Name = "Keybind",
    Default = Enum.KeyCode.LeftShift,
    Flag = "MainKeybind",
    Callback = function(key)
        print("Keybind set to:", key)
    end,
    Pressed = function()
        print("Keybind pressed!")
    end
})

-- Another Section
local SecondSection = MainTab:CreateSection({Name = "Other", Side = "Right"})

SecondSection:AddColorPicker({
    Name = "Choose Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ChosenColor",
    Callback = function(color)
        print("Color:", color)
    end
})

SecondSection:AddTextBox({
    Name = "Enter Text",
    Placeholder = "Type here...",
    Flag = "TextInput",
    Callback = function(text)
        print("Text:", text)
    end
})

SecondSection:AddLabel("This is a label")
SecondSection:AddDivider()

-- Load config if exists
SaveManager:Load("Default")
]]

return Library
