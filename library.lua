-- Triple7 UI Library for Roblox Executors
-- Supports: Synapse X, KRNL, Fluxus, Script-Ware, Electron, Oxygen U

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Windows = {},
    Flags = {},
    Options = {},
    Theme = {
        Background = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentDark = Color3.fromRGB(71, 82, 196),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 50),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementHover = Color3.fromRGB(45, 45, 45),
        Success = Color3.fromRGB(50, 205, 50),
        Error = Color3.fromRGB(255, 69, 69),
        Warning = Color3.fromRGB(255, 165, 0)
    },
    TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenInfoFast = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontSemibold = Enum.Font.GothamSemibold,
    TextSize = 14,
    UseConfigSystem = true,
    Watermark = nil,
    KeybindList = nil,
    Notifications = {},
    NotificationFrame = nil
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function Round(number, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local info = TweenInfo.new(
        duration or 0.25,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out
    )
    TweenService:Create(instance, info, properties):Play()
end

local function AddCorner(instance, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = instance
    })
end

local function AddStroke(instance, color, thickness)
    Create("UIStroke", {
        Color = color or Library.Theme.Border,
        Thickness = thickness or 1,
        Parent = instance
    })
end

local function AddPadding(instance, padding)
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, padding or 8),
        PaddingRight = UDim.new(0, padding or 8),
        PaddingTop = UDim.new(0, padding or 8),
        PaddingBottom = UDim.new(0, padding or 8),
        Parent = instance
    })
end

-- Notification System
function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 5
    local type = options.Type or "Info" -- Info, Success, Error, Warning
    
    if not Library.NotificationFrame then
        Library.NotificationFrame = Create("Frame", {
            Name = "Notifications",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -320, 0, 20),
            Parent = CoreGui
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Parent = Library.NotificationFrame
        })
    end
    
    local colors = {
        Info = Library.Theme.Accent,
        Success = Library.Theme.Success,
        Error = Library.Theme.Error,
        Warning = Library.Theme.Warning
    }
    
    local notif = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Library.Theme.ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 300, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = Library.NotificationFrame
    })
    AddCorner(notif, 8)
    AddStroke(notif)
    
    local accentBar = Create("Frame", {
        Name = "Accent",
        BackgroundColor3 = colors[type] or Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notif
    })
    AddCorner(accentBar, 2)
    
    local contentFrame = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 12, 0, 0),
        Parent = notif
    })
    
    AddPadding(contentFrame, 12)
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Library.FontBold,
        Text = title,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame
    })
    
    local contentLabel = Create("TextLabel", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Library.Font,
        Text = content,
        TextColor3 = Library.Theme.TextDark,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = contentFrame
    })
    
    notif.Size = UDim2.new(0, 300, 0, contentFrame.AbsoluteSize.Y)
    
    -- Close button
    local closeBtn = Create("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -28, 0, 8),
        Font = Library.Font,
        Text = "×",
        TextColor3 = Library.Theme.TextDark,
        TextSize = 18,
        Parent = notif
    })
    
    local function close()
        Tween(notif, {Position = UDim2.new(0, 350, notif.Position.Y.Scale, notif.Position.Y.Offset)}, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end
    
    closeBtn.MouseButton1Click:Connect(close)
    
    -- Auto close
    task.spawn(function()
        task.wait(duration)
        if notif and notif.Parent then
            close()
        end
    end)
    
    return notif
end

-- Create Main Window
function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Triple7"
    local subTitle = options.SubTitle or ""
    local size = options.Size or UDim2.new(0, 550, 0, 400)
    
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Minimized = false,
        UI = {}
    }
    
    -- Main GUI
    local ScreenGui = Create("ScreenGui", {
        Name = title .. "_" .. HttpService:GenerateGUID(false),
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    Window.UI.ScreenGui = ScreenGui
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 10)
    AddStroke(MainFrame, Library.Theme.Border, 1)
    Window.UI.MainFrame = MainFrame
    
    -- Top Bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Library.Theme.ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45),
        Parent = MainFrame
    })
    AddCorner(TopBar, 10)
    
    -- Fix corners
    local TopBarFix = Create("Frame", {
        Name = "Fix",
        BackgroundColor3 = Library.Theme.ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        Parent = TopBar
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Font = Library.FontBold,
        Text = title,
        TextColor3 = Library.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    if subTitle ~= "" then
        TitleLabel.Text = title .. " <font color=\"rgb(180,180,180)\">" .. subTitle .. "</font>"
        TitleLabel.RichText = true
    end
    
    -- Window Controls
    local ControlsFrame = Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 30),
        Position = UDim2.new(1, -70, 0, 8),
        Parent = TopBar
    })
    
    local MinimizeBtn = Create("TextButton", {
        Name = "Minimize",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 25, 1, 0),
        Font = Library.Font,
        Text = "−",
        TextColor3 = Library.Theme.TextDark,
        TextSize = 18,
        Parent = ControlsFrame
    })
    
    local CloseBtn = Create("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 25, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        Font = Library.Font,
        Text = "×",
        TextColor3 = Library.Theme.Error,
        TextSize = 18,
        Parent = ControlsFrame
    })
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Library.Theme.ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 140, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        Parent = MainFrame
    })
    
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabContainer
    })
    AddPadding(TabList, 10)
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = TabList
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -150, 1, -55),
        Position = UDim2.new(0, 145, 0, 50),
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    -- Dragging
    MakeDraggable(MainFrame, TopBar)
    
    -- Minimize/Maximize
    MinimizeBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        Tween(ContentContainer, {Size = Window.Minimized and UDim2.new(1, -150, 0, 0) or UDim2.new(1, -150, 1, -55)}, 0.3)
        Tween(TabContainer, {Size = Window.Minimized and UDim2.new(0, 140, 0, 0) or UDim2.new(0, 140, 1, -45)}, 0.3)
        MainFrame.Size = Window.Minimized and UDim2.new(0, size.X.Offset, 0, 45) or size
        MinimizeBtn.Text = Window.Minimized and "+" or "−"
    end)
    
    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Create Tab Function
    function Window:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local icon = options.Icon or nil
        
        local Tab = {
            Sections = {},
            Elements = {},
            Active = false
        }
        
        -- Tab Button
        local TabBtn = Create("TextButton", {
            Name = tabName .. "Tab",
            BackgroundColor3 = Library.Theme.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Font = Library.FontSemibold,
            Text = "      " .. tabName,
            TextColor3 = Library.Theme.TextDark,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabList
        })
        AddCorner(TabBtn, 6)
        
        -- Icon support
        if icon then
            local IconLabel = Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, -9),
                Image = icon,
                ImageColor3 = Library.Theme.TextDark,
                Parent = TabBtn
            })
        end
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentContainer
        })
        AddPadding(TabContent, 10)
        
        local TabLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = TabContent
        })
        
        -- Tab Selection
        TabBtn.MouseButton1Click:Connect(function()
            if Window.ActiveTab then
                Window.ActiveTab:SetActive(false)
            end
            Tab:SetActive(true)
            Window.ActiveTab = Tab
        end)
        
        function Tab:SetActive(active)
            self.Active = active
            TabContent.Visible = active
            Tween(TabBtn, {BackgroundColor3 = active and Library.Theme.Accent or Library.Theme.Background}, 0.2)
            Tween(TabBtn, {TextColor3 = active and Library.Theme.Text or Library.Theme.TextDark}, 0.2)
        end
        
        -- Create Section
        function Tab:CreateSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            local side = options.Side or "Left" -- Left or Right
            
            local Section = {
                Elements = {}
            }
            
            local SectionFrame = Create("Frame", {
                Name = sectionName .. "Section",
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(0.48, -5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabContent
            })
            AddCorner(SectionFrame, 8)
            AddStroke(SectionFrame)
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundColor3 = Library.Theme.Background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 32),
                Font = Library.FontBold,
                Text = " " .. sectionName,
                TextColor3 = Library.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            AddCorner(SectionTitle, 8)
            
            local SectionContent = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, -42),
                Position = UDim2.new(0, 10, 0, 37),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })
            
            local SectionList = Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = SectionContent
            })
            
            -- Element Creation Functions
            
            -- Button
            function Section:AddButton(options)
                options = options or {}
                local name = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local Btn = Create("TextButton", {
                    Name = name .. "Button",
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Library.FontSemibold,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    Parent = SectionContent
                })
                AddCorner(Btn, 6)
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Library.Theme.AccentDark}, 0.2)
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Library.Theme.Accent}, 0.2)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {Size = UDim2.new(0.98, 0, 0, 32)}, 0.05)
                    task.wait(0.05)
                    Tween(Btn, {Size = UDim2.new(1, 0, 0, 32)}, 0.1)
                    callback()
                end)
                
                return Btn
            end
            
            -- Toggle
            function Section:AddToggle(options)
                options = options or {}
                local name = options.Name or "Toggle"
                local default = options.Default or false
                local flag = options.Flag
                local callback = options.Callback or function() end
                
                local Toggle = {
                    Value = default
                }
                
                local ToggleFrame = Create("Frame", {
                    Name = name .. "Toggle",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Library.Font,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleBtn = Create("TextButton", {
                    Name = "ToggleBtn",
                    BackgroundColor3 = default and Library.Theme.Accent or Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 44, 0, 24),
                    Position = UDim2.new(1, -44, 0.5, -12),
                    Text = "",
                    Parent = ToggleFrame
                })
                AddCorner(ToggleBtn, 12)
                AddStroke(ToggleBtn)
                
                local Circle = Create("Frame", {
                    Name = "Circle",
                    BackgroundColor3 = Library.Theme.Text,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                    Parent = ToggleBtn
                })
                AddCorner(Circle, 9)
                
                function Toggle:SetValue(value)
                    self.Value = value
                    Tween(ToggleBtn, {BackgroundColor3 = value and Library.Theme.Accent or Library.Theme.Background}, 0.2)
                    Tween(Circle, {Position = value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.2)
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    callback(value)
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggle:SetValue(not Toggle.Value)
                end)
                
                if flag then
                    Library.Flags[flag] = default
                    Library.Options[flag] = Toggle
                end
                
                return Toggle
            end
            
            -- Slider
            function Section:AddSlider(options)
                options = options or {}
                local name = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local flag = options.Flag
                local callback = options.Callback or function() end
                local suffix = options.Suffix or ""
                
                local Slider = {
                    Value = default
                }
                
                local SliderFrame = Create("Frame", {
                    Name = name .. "Slider",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45),
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 0, 18),
                    Font = Library.Font,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local ValueLabel = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 0, 18),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    Font = Library.Font,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBg = Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 30),
                    Parent = SliderFrame
                })
                AddCorner(SliderBg, 4)
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    Parent = SliderBg
                })
                AddCorner(SliderFill, 4)
                
                local SliderBtn = Create("TextButton", {
                    Name = "SliderBtn",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = SliderBg
                })
                
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    local value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
                    Slider.Value = value
                    ValueLabel.Text = tostring(value) .. suffix
                    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    callback(value)
                end
                
                SliderBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        update(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                function Slider:SetValue(value)
                    value = math.clamp(value, min, max)
                    value = math.floor(value / increment + 0.5) * increment
                    Slider.Value = value
                    ValueLabel.Text = tostring(value) .. suffix
                    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    callback(value)
                end
                
                if flag then
                    Library.Flags[flag] = default
                    Library.Options[flag] = Slider
                end
                
                return Slider
            end
            
            -- TextBox
            function Section:AddTextBox(options)
                options = options or {}
                local name = options.Name or "TextBox"
                local default = options.Default or ""
                local placeholder = options.Placeholder or "Enter text..."
                local flag = options.Flag
                local callback = options.Callback or function() end
                local numeric = options.Numeric or false
                
                local TextBox = {
                    Value = default
                }
                
                local BoxFrame = Create("Frame", {
                    Name = name .. "TextBox",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 55),
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Library.Font,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = BoxFrame
                })
                
                local InputBg = Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 25),
                    Parent = BoxFrame
                })
                AddCorner(InputBg, 6)
                AddStroke(InputBg)
                
                local Input = Create("TextBox", {
                    Name = "Input",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    Font = Library.Font,
                    Text = default,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Library.Theme.TextDark,
                    ClearTextOnFocus = false,
                    Parent = InputBg
                })
                
                Input.FocusLost:Connect(function()
                    local value = Input.Text
                    
                    if numeric then
                        value = tonumber(value) or 0
                        Input.Text = tostring(value)
                    end
                    
                    TextBox.Value = value
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    callback(value)
                end)
                
                function TextBox:SetValue(value)
                    Input.Text = tostring(value)
                    TextBox.Value = value
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    callback(value)
                end
                
                if flag then
                    Library.Flags[flag] = default
                    Library.Options[flag] = TextBox
                end
                
                return TextBox
            end
            
            -- Dropdown
            function Section:AddDropdown(options)
                options = options or {}
                local name = options.Name or "Dropdown"
                local values = options.Values or {}
                local default = options.Default
                local multi = options.Multi or false
                local flag = options.Flag
                local callback = options.Callback or function() end
                
                local Dropdown = {
                    Value = multi and (default or {}) or (default or values[1]),
                    Values = values,
                    Multi = multi,
                    Open = false
                }
                
                local DropdownFrame = Create("Frame", {
                    Name = name .. "Dropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Library.Font,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownBtn = Create("TextButton", {
                    Name = "DropdownBtn",
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 25),
                    Font = Library.Font,
                    Text = "",
                    Parent = DropdownFrame
                })
                AddCorner(DropdownBtn, 6)
                AddStroke(DropdownBtn)
                
                local SelectedText = Create("TextLabel", {
                    Name = "Selected",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Font = Library.Font,
                    Text = multi and "Select..." or (Dropdown.Value or "Select..."),
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropdownBtn
                })
                
                local Arrow = Create("TextLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    Font = Library.Font,
                    Text = "▼",
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 12,
                    Parent = DropdownBtn
                })
                
                local DropdownList = Create("Frame", {
                    Name = "List",
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                    Parent = DropdownBtn
                })
                AddCorner(DropdownList, 6)
                AddStroke(DropdownList)
                
                local ListScrolling = Create("ScrollingFrame", {
                    Name = "Scrolling",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 1, -10),
                    Position = UDim2.new(0, 5, 0, 5),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 10,
                    Parent = DropdownList
                })
                
                Create("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    Parent = ListScrolling
                })
                
                local function refreshList()
                    for _, child in pairs(ListScrolling:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, value in pairs(Dropdown.Values) do
                        local Option = Create("TextButton", {
                            Name = tostring(value),
                            BackgroundColor3 = (multi and Dropdown.Value[value]) or Dropdown.Value == value and Library.Theme.Accent or Library.Theme.ElementBackground,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 28),
                            Font = Library.Font,
                            Text = tostring(value),
                            TextColor3 = (multi and Dropdown.Value[value]) or Dropdown.Value == value and Library.Theme.Text or Library.Theme.TextDark,
                            TextSize = 12,
                            ZIndex = 10,
                            Parent = ListScrolling
                        })
                        AddCorner(Option, 4)
                        
                        Option.MouseButton1Click:Connect(function()
                            if multi then
                                Dropdown.Value[value] = not Dropdown.Value[value]
                                local selected = {}
                                for k, v in pairs(Dropdown.Value) do
                                    if v then
                                        table.insert(selected, k)
                                    end
                                end
                                SelectedText.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                                Option.BackgroundColor3 = Dropdown.Value[value] and Library.Theme.Accent or Library.Theme.ElementBackground
                                Option.TextColor3 = Dropdown.Value[value] and Library.Theme.Text or Library.Theme.TextDark
                            else
                                Dropdown.Value = value
                                SelectedText.Text = tostring(value)
                                Dropdown.Open = false
                                Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                                Tween(Arrow, {Rotation = 0}, 0.2)
                                DropdownList.Visible = false
                                
                                for _, btn in pairs(ListScrolling:GetChildren()) do
                                    if btn:IsA("TextButton") then
                                        btn.BackgroundColor3 = btn.Name == tostring(value) and Library.Theme.Accent or Library.Theme.ElementBackground
                                        btn.TextColor3 = btn.Name == tostring(value) and Library.Theme.Text or Library.Theme.TextDark
                                    end
                                end
                            end
                            
                            if flag then
                                Library.Flags[flag] = Dropdown.Value
                            end
                            
                            callback(Dropdown.Value)
                        end)
                    end
                end
                
                DropdownBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    DropdownList.Visible = true
                    Tween(DropdownList, {Size = Dropdown.Open and UDim2.new(1, 0, 0, math.min(150, #Dropdown.Values * 32)) or UDim2.new(1, 0, 0, 0)}, 0.2)
                    Tween(Arrow, {Rotation = Dropdown.Open and 180 or 0}, 0.2)
                    
                    if not Dropdown.Open then
                        task.wait(0.2)
                        DropdownList.Visible = false
                    end
                end)
                
                function Dropdown:SetValues(newValues)
                    Dropdown.Values = newValues
                    refreshList()
                end
                
                function Dropdown:SetValue(value)
                    Dropdown.Value = value
                    if multi then
                        local selected = {}
                        for k, v in pairs(value) do
                            if v then
                                table.insert(selected, k)
                            end
                        end
                        SelectedText.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                    else
                        SelectedText.Text = tostring(value)
                    end
                    refreshList()
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    callback(value)
                end
                
                refreshList()
                
                if flag then
                    Library.Flags[flag] = Dropdown.Value
                    Library.Options[flag] = Dropdown
                end
                
                return Dropdown
            end
            
            -- Keybind
            function Section:AddKeybind(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local default = options.Default
                local flag = options.Flag
                local callback = options.Callback or function() end
                local onPressed = options.Pressed or function() end
                
                local Keybind = {
                    Value = default
                }
                
                local KeybindFrame = Create("Frame", {
                    Name = name .. "Keybind",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -70, 1, 0),
                    Font = Library.Font,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindBtn = Create("TextButton", {
                    Name = "KeybindBtn",
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 65, 0, 24),
                    Position = UDim2.new(1, -65, 0.5, -12),
                    Font = Library.Font,
                    Text = default and default.Name or "None",
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    Parent = KeybindFrame
                })
                AddCorner(KeybindBtn, 4)
                AddStroke(KeybindBtn)
                
                local listening = false
                
                KeybindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindBtn.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        Keybind.Value = input.KeyCode
                        KeybindBtn.Text = input.KeyCode.Name
                        
                        if flag then
                            Library.Flags[flag] = input.KeyCode
                        end
                        
                        callback(input.KeyCode)
                    elseif Keybind.Value and input.KeyCode == Keybind.Value and not gameProcessed and not listening then
                        onPressed()
                    end
                end)
                
                function Keybind:SetValue(key)
                    Keybind.Value = key
                    KeybindBtn.Text = key and key.Name or "None"
                    
                    if flag then
                        Library.Flags[flag] = key
                    end
                    
                    callback(key)
                end
                
                if flag then
                    Library.Flags[flag] = default
                    Library.Options[flag] = Keybind
                end
                
                return Keybind
            end
            
            -- Color Picker
            function Section:AddColorPicker(options)
                options = options or {}
                local name = options.Name or "Color Picker"
                local default = options.Default or Color3.fromRGB(255, 255, 255)
                local flag = options.Flag
                local callback = options.Callback or function() end
                
                local ColorPicker = {
                    Value = default,
                    Open = false
                }
                
                local PickerFrame = Create("Frame", {
                    Name = name .. "ColorPicker",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Library.Font,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = PickerFrame
                })
                
                local ColorDisplay = Create("TextButton", {
                    Name = "ColorDisplay",
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 35, 0, 22),
                    Position = UDim2.new(1, -35, 0.5, -11),
                    Text = "",
                    Parent = PickerFrame
                })
                AddCorner(ColorDisplay, 4)
                AddStroke(ColorDisplay)
                
                -- Simple color picker popup (simplified version)
                local ColorPopup = Create("Frame", {
                    Name = "Popup",
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 200, 0, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                    Parent = PickerFrame
                })
                AddCorner(ColorPopup, 8)
                AddStroke(ColorPopup)
                
                local HueBar = Create("Frame", {
                    Name = "HueBar",
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, 10),
                    ZIndex = 10,
                    Parent = ColorPopup
                })
                AddCorner(HueBar, 4)
                
                local SaturationFrame = Create("Frame", {
                    Name = "Saturation",
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -20, 0, 100),
                    Position = UDim2.new(0, 10, 0, 40),
                    ZIndex = 10,
                    Parent = ColorPopup
                })
                AddCorner(SaturationFrame, 4)
                
                local presetColors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(0, 0, 0)
                }
                
                local presetFrame = Create("Frame", {
                    Name = "Presets",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 25),
                    Position = UDim2.new(0, 10, 0, 150),
                    ZIndex = 10,
                    Parent = ColorPopup
                })
                
                for i, color in ipairs(presetColors) do
                    local preset = Create("TextButton", {
                        Name = "Preset" .. i,
                        BackgroundColor3 = color,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 20, 0, 20),
                        Position = UDim2.new(0, (i - 1) * 25, 0, 0),
                        Text = "",
                        ZIndex = 10,
                        Parent = presetFrame
                    })
                    AddCorner(preset, 4)
                    
                    preset.MouseButton1Click:Connect(function()
                        ColorPicker.Value = color
                        ColorDisplay.BackgroundColor3 = color
                        SaturationFrame.BackgroundColor3 = color
                        
                        if flag then
                            Library.Flags[flag] = color
                        end
                        
                        callback(color)
                    end)
                end
                
                ColorDisplay.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    ColorPopup.Visible = true
                    Tween(ColorPopup, {Size = ColorPicker.Open and UDim2.new(0, 200, 0, 185) or UDim2.new(0, 200, 0, 0)}, 0.2)
                    
                    if not ColorPicker.Open then
                        task.wait(0.2)
                        ColorPopup.Visible = false
                    end
                end)
                
                function ColorPicker:SetValue(color)
                    ColorPicker.Value = color
                    ColorDisplay.BackgroundColor3 = color
                    SaturationFrame.BackgroundColor3 = color
                    
                    if flag then
                        Library.Flags[flag] = color
                    end
                    
                    callback(color)
                end
                
                if flag then
                    Library.Flags[flag] = default
                    Library.Options[flag] = ColorPicker
                end
                
                return ColorPicker
            end
            
            -- Label
            function Section:AddLabel(text)
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Library.Font,
                    Text = text or "Label",
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = SectionContent
                })
                
                return Label
            end
            
            -- Divider
            function Section:AddDivider()
                local Divider = Create("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = Library.Theme.Border,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = SectionContent
                })
                
                return Divider
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Set first tab as active
        if #Window.Tabs == 1 then
            Tab:SetActive(true)
            Window.ActiveTab = Tab
        end
        
        return Tab
    end
    
    -- Keybind List
    function Window:CreateKeybindList()
        local ListGui = Create("ScreenGui", {
            Name = "KeybindList",
            Parent = CoreGui,
            ResetOnSpawn = false
        })
        
        local ListFrame = Create("Frame", {
            Name = "List",
            BackgroundColor3 = Library.Theme.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 200, 0, 30),
            Position = UDim2.new(0, 20, 0.5, -100),
            Parent = ListGui
        })
        AddCorner(ListFrame, 8)
        AddStroke(ListFrame)
        
        local Title = Create("TextLabel", {
            Name = "Title",
            BackgroundColor3 = Library.Theme.ElementBackground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Library.FontBold,
            Text = "  Keybinds",
            TextColor3 = Library.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ListFrame
        })
        AddCorner(Title, 8)
        
        local Content = Create("ScrollingFrame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, -40),
            Position = UDim2.new(0, 5, 0, 35),
            ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = ListFrame
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            Parent = Content
        })
        
        MakeDraggable(ListFrame, Title)
        
        Library.KeybindList = {
            Frame = ListFrame,
            Content = Content,
            Items = {}
        }
        
        return Library.KeybindList
    end
    
    -- Watermark
    function Window:CreateWatermark(text)
        local WatermarkGui = Create("ScreenGui", {
            Name = "Watermark",
            Parent = CoreGui,
            ResetOnSpawn = false
        })
        
        local WatermarkFrame = Create("Frame", {
            Name = "Watermark",
            BackgroundColor3 = Library.Theme.Background,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 200, 0, 25),
            Position = UDim2.new(0, 20, 0, 20),
            Parent = WatermarkGui
        })
        AddCorner(WatermarkFrame, 6)
        
        local WatermarkText = Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            Font = Library.FontSemibold,
            Text = text or "Triple7 | 60 FPS",
            TextColor3 = Library.Theme.Text,
            TextSize = 12,
            Parent = WatermarkFrame
        })
        
        -- FPS Counter
        local fps = 60
        local lastUpdate = tick()
        
        RunService.RenderStepped:Connect(function()
            if tick() - lastUpdate >= 1 then
                fps = math.floor(1 / RunService.RenderStepped:Wait())
                WatermarkText.Text = (text or "Triple7") .. " | " .. fps .. " FPS"
                lastUpdate = tick()
            end
        end)
        
        Library.Watermark = WatermarkFrame
        return WatermarkFrame
    end
    
    -- Settings Tab (Auto-generated)
    function Window:AddSettingsTab()
        local SettingsTab = Window:CreateTab({Name = "Settings", Icon = "rbxassetid://7733965119"})
        
        local ConfigSection = SettingsTab:CreateSection({Name = "Configuration", Side = "Left"})
        
        -- Theme Settings
        local ThemeSection = SettingsTab:CreateSection({Name = "Theme", Side = "Right"})
        
        ThemeSection:AddColorPicker({
            Name = "Accent Color",
            Default = Library.Theme.Accent,
            Callback = function(color)
                Library.Theme.Accent = color
                Library.Theme.AccentDark = Color3.new(color.R * 0.8, color.G * 0.8, color.B * 0.8)
            end
        })
        
        -- Destroy UI Button
        ConfigSection:AddButton({
            Name = "Destroy UI",
            Callback = function()
                ScreenGui:Destroy()
                if Library.NotificationFrame then
                    Library.NotificationFrame:Destroy()
                end
                if Library.Watermark then
                    Library.Watermark.Parent.Parent:Destroy()
                end
                if Library.KeybindList then
                    Library.KeybindList.Frame.Parent.Parent:Destroy()
                end
            end
        })
        
        -- Rejoin Button
        ConfigSection:AddButton({
            Name = "Rejoin Server",
            Callback = function()
                local TeleportService = game:GetService("TeleportService")
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        
        return SettingsTab
    end
    
    table.insert(Library.Windows, Window)
    return Window
end

-- Config System Integration
function Library:SaveConfig(name)
    if not self.UseConfigSystem then return end
    
    local config = {}
    for flag, value in pairs(self.Flags) do
        if typeof(value) == "Color3" then
            config[flag] = {R = value.R, G = value.G, B = value.B, Type = "Color3"}
        elseif typeof(value) == "EnumItem" then
            config[flag] = {Value = value.Value, Type = "EnumItem", EnumType = tostring(value.EnumType)}
        else
            config[flag] = value
        end
    end
    
    -- This would be saved via savemanager
    return HttpService:JSONEncode(config)
end

function Library:LoadConfig(configString)
    if not self.UseConfigSystem then return end
    
    local success, config = pcall(function()
        return HttpService:JSONDecode(configString)
    end)
    
    if not success then return end
    
    for flag, value in pairs(config) do
        if self.Options[flag] then
            if type(value) == "table" and value.Type == "Color3" then
                self.Options[flag]:SetValue(Color3.new(value.R, value.G, value.B))
            elseif type(value) == "table" and value.Type == "EnumItem" then
                self.Options[flag]:SetValue(Enum[value.EnumType]:GetEnumItems()[value.Value + 1])
            else
                self.Options[flag]:SetValue(value)
            end
        end
    end
end

-- Export
getgenv().Triple7 = Library
return Library
