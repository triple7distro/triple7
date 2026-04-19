-- Triple7 Theme Manager
-- Handles theme customization and preset themes

local HttpService = game:GetService("HttpService")

local ThemeManager = {
    Library = nil,
    Themes = {},
    CurrentTheme = "Default",
    CustomThemes = {}
}

-- Preset Themes
ThemeManager.Themes["Default"] = {
    Background = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(50, 50, 50),
    ElementBackground = Color3.fromRGB(35, 35, 35)
}

ThemeManager.Themes["Midnight"] = {
    Background = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(100, 100, 255),
    Text = Color3.fromRGB(240, 240, 255),
    TextDark = Color3.fromRGB(150, 150, 170),
    Border = Color3.fromRGB(40, 40, 55),
    ElementBackground = Color3.fromRGB(25, 25, 35)
}

ThemeManager.Themes["Cherry"] = {
    Background = Color3.fromRGB(30, 20, 20),
    Accent = Color3.fromRGB(255, 100, 100),
    Text = Color3.fromRGB(255, 240, 240),
    TextDark = Color3.fromRGB(200, 170, 170),
    Border = Color3.fromRGB(60, 45, 45),
    ElementBackground = Color3.fromRGB(45, 30, 30)
}

ThemeManager.Themes["Forest"] = {
    Background = Color3.fromRGB(20, 30, 20),
    Accent = Color3.fromRGB(100, 200, 100),
    Text = Color3.fromRGB(240, 255, 240),
    TextDark = Color3.fromRGB(170, 200, 170),
    Border = Color3.fromRGB(45, 60, 45),
    ElementBackground = Color3.fromRGB(30, 45, 30)
}

ThemeManager.Themes["Ocean"] = {
    Background = Color3.fromRGB(20, 25, 35),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 245, 255),
    TextDark = Color3.fromRGB(170, 180, 200),
    Border = Color3.fromRGB(45, 50, 65),
    ElementBackground = Color3.fromRGB(30, 35, 50)
}

ThemeManager.Themes["Amethyst"] = {
    Background = Color3.fromRGB(30, 20, 35),
    Accent = Color3.fromRGB(180, 100, 255),
    Text = Color3.fromRGB(250, 240, 255),
    TextDark = Color3.fromRGB(190, 170, 200),
    Border = Color3.fromRGB(55, 40, 65),
    ElementBackground = Color3.fromRGB(45, 30, 55)
}

ThemeManager.Themes["Sunset"] = {
    Background = Color3.fromRGB(35, 25, 20),
    Accent = Color3.fromRGB(255, 150, 50),
    Text = Color3.fromRGB(255, 245, 240),
    TextDark = Color3.fromRGB(210, 180, 160),
    Border = Color3.fromRGB(65, 50, 40),
    ElementBackground = Color3.fromRGB(50, 35, 28)
}

ThemeManager.Themes["Monochrome"] = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(180, 180, 180),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(50, 50, 50),
    ElementBackground = Color3.fromRGB(35, 35, 35)
}

ThemeManager.Themes["Discord"] = {
    Background = Color3.fromRGB(54, 57, 63),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(185, 187, 190),
    Border = Color3.fromRGB(66, 70, 77),
    ElementBackground = Color3.fromRGB(47, 49, 54)
}

function ThemeManager:SetLibrary(library)
    self.Library = library
    return self
end

function ThemeManager:ApplyTheme(themeName)
    local theme = self.Themes[themeName] or self.CustomThemes[themeName]
    if not theme then return end
    
    self.CurrentTheme = themeName
    
    if self.Library then
        for key, value in pairs(theme) do
            if self.Library.Theme[key] then
                self.Library.Theme[key] = value
            end
        end
        
        -- Update AccentDark based on Accent
        if theme.Accent then
            local accent = theme.Accent
            self.Library.Theme.AccentDark = Color3.new(
                math.clamp(accent.R * 0.8, 0, 1),
                math.clamp(accent.G * 0.8, 0, 1),
                math.clamp(accent.B * 0.8, 0, 1)
            )
        end
    end
    
    return self
end

function ThemeManager:CreateCustomTheme(name, themeData)
    self.CustomThemes[name] = themeData
    return self
end

function ThemeManager:GetThemes()
    local themes = {}
    for name, _ in pairs(self.Themes) do
        table.insert(themes, name)
    end
    for name, _ in pairs(self.CustomThemes) do
        table.insert(themes, name)
    end
    return themes
end

function ThemeManager:ExportTheme(themeName)
    local theme = self.Themes[themeName] or self.CustomThemes[themeName]
    if not theme then return nil end
    
    local export = {}
    for key, value in pairs(theme) do
        if typeof(value) == "Color3" then
            export[key] = {R = value.R, G = value.G, B = value.B}
        else
            export[key] = value
        end
    end
    
    return HttpService:JSONEncode(export)
end

function ThemeManager:ImportTheme(name, jsonString)
    local success, data = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    
    if not success then return false end
    
    local theme = {}
    for key, value in pairs(data) do
        if type(value) == "table" and value.R then
            theme[key] = Color3.new(value.R, value.G, value.B)
        else
            theme[key] = value
        end
    end
    
    self:CreateCustomTheme(name, theme)
    return true
end

function ThemeManager:CreateThemeSection(tab, side)
    if not self.Library then return end
    
    local section = tab:CreateSection({Name = "Themes", Side = side or "Left"})
    
    -- Theme Dropdown
    section:AddDropdown({
        Name = "Select Theme",
        Values = self:GetThemes(),
        Default = self.CurrentTheme,
        Callback = function(value)
            self:ApplyTheme(value)
        end
    })
    
    -- Accent Color Picker
    section:AddColorPicker({
        Name = "Custom Accent",
        Default = self.Library.Theme.Accent,
        Callback = function(color)
            self.Library.Theme.Accent = color
            self.Library.Theme.AccentDark = Color3.new(color.R * 0.8, color.G * 0.8, color.B * 0.8)
        end
    })
    
    -- Background Color Picker
    section:AddColorPicker({
        Name = "Custom Background",
        Default = self.Library.Theme.Background,
        Callback = function(color)
            self.Library.Theme.Background = color
        end
    })
    
    return section
end

return ThemeManager
