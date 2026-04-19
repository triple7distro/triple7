# Triple7 UI Library

A modern, feature-rich UI library for Roblox executors with support for Synapse X, KRNL, Fluxus, Script-Ware, Electron, and Oxygen U.

## Features

- **Modern Design**: Clean, Discord-inspired dark theme with smooth animations
- **Window System**: Draggable, resizable, minimizable windows
- **Tab Navigation**: Icon and text-based tabs with smooth transitions
- **Element Types**:
  - Buttons with hover effects
  - Toggles with smooth animations
  - Sliders with precise value control
  - TextBoxes (text and numeric input)
  - Dropdowns (single and multi-select)
  - Keybinds with callback support
  - Color Pickers with preset colors
  - Labels and Dividers
- **Theme System**: 9 built-in themes + custom theme support
- **Config System**: Save/load settings with auto-save option
- **Notifications**: Styled notifications with different types
- **Watermark**: Draggable FPS counter display
- **Keybind List**: Visual keybind reference

## Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/triple7/main/library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/triple7/main/thememanager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/triple7/main/savemanager.lua"))()

-- Create Window
local Window = Library:CreateWindow({
    Title = "Triple7",
    SubTitle = "Hub",
    Size = UDim2.new(0, 550, 0, 400)
})

-- Create Watermark
Window:CreateWatermark("My Hub")

-- Create Tab
local MainTab = Window:CreateTab({Name = "Main", Icon = "rbxassetid://7733965119"})

-- Create Section
local Section = MainTab:CreateSection({Name = "Features", Side = "Left"})

-- Add Elements
Section:AddButton({
    Name = "Click Me",
    Callback = function()
        Library:Notify({
            Title = "Success",
            Content = "Button clicked!",
            Type = "Success",
            Duration = 3
        })
    end
})

Section:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "FeatureEnabled",
    Callback = function(value)
        print("Feature:", value)
    end
})
```

## Elements

### Button
```lua
Section:AddButton({
    Name = "Button Name",
    Callback = function()
        -- Code here
    end
})
```

### Toggle
```lua
Section:AddToggle({
    Name = "Toggle Name",
    Default = false,
    Flag = "ToggleFlag",  -- Optional: for saving
    Callback = function(value)
        -- Code here
    end
})
```

### Slider
```lua
Section:AddSlider({
    Name = "Slider Name",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Flag = "SliderFlag",
    Callback = function(value)
        -- Code here
    end
})
```

### TextBox
```lua
Section:AddTextBox({
    Name = "TextBox Name",
    Default = "",
    Placeholder = "Enter text...",
    Numeric = false,  -- Set true for numbers only
    Flag = "TextFlag",
    Callback = function(value)
        -- Code here
    end
})
```

### Dropdown
```lua
Section:AddDropdown({
    Name = "Dropdown Name",
    Values = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Multi = false,  -- Set true for multi-select
    Flag = "DropdownFlag",
    Callback = function(value)
        -- Code here
    end
})
```

### Keybind
```lua
Section:AddKeybind({
    Name = "Keybind Name",
    Default = Enum.KeyCode.LeftShift,
    Flag = "KeybindFlag",
    Callback = function(key)  -- Called when key is set
        print("Set to:", key)
    end,
    Pressed = function()  -- Called when key is pressed
        print("Key pressed!")
    end
})
```

### Color Picker
```lua
Section:AddColorPicker({
    Name = "Color Picker Name",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ColorFlag",
    Callback = function(color)
        -- Code here
    end
})
```

### Label & Divider
```lua
Section:AddLabel("This is a label")
Section:AddDivider()
```

## Themes

Built-in themes: Default, Midnight, Cherry, Forest, Ocean, Amethyst, Sunset, Monochrome, Discord

```lua
ThemeManager:SetLibrary(Library)
ThemeManager:ApplyTheme("Ocean")
```

## Config System

```lua
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("MyHub/configs")

-- Save
SaveManager:Save("MyConfig")

-- Load
SaveManager:Load("MyConfig")

-- Auto-save
SaveManager.AutoSave = true
SaveManager:AutoSaveLoop()
```

## Notifications

```lua
Library:Notify({
    Title = "Title",
    Content = "Message content",
    Type = "Info",  -- Info, Success, Error, Warning
    Duration = 5
})
```

## License

MIT
