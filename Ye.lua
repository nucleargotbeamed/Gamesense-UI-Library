--[[
    Gamesense-Style UI Library for Roblox
    Usage: local Library = loadstring(game:HttpGet("YOUR_URL"))()
]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Theme = {
    -- Main Colors
    Background = Color3.fromRGB(24, 24, 26),
    Secondary = Color3.fromRGB(32, 32, 36),
    Tertiary = Color3.fromRGB(40, 40, 44),
    Border = Color3.fromRGB(50, 50, 55),
    
    -- Accent
    Accent = Color3.fromRGB(130, 180, 255),
    AccentDark = Color3.fromRGB(90, 140, 215),
    
    -- Text
    Text = Color3.fromRGB(220, 220, 220),
    TextDark = Color3.fromRGB(150, 150, 150),
    TextDisabled = Color3.fromRGB(100, 100, 100),
    
    -- Elements
    ElementBackground = Color3.fromRGB(45, 45, 50),
    ElementBackgroundHover = Color3.fromRGB(55, 55, 60),
    
    -- Tab
    TabBackground = Color3.fromRGB(28, 28, 32),
    TabActive = Color3.fromRGB(40, 40, 44),
    
    -- Groupbox
    GroupboxBackground = Color3.fromRGB(28, 28, 32),
    GroupboxBorder = Color3.fromRGB(45, 45, 50),
    
    -- Fonts
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    
    -- Sizes
    TextSize = 12,
    HeaderSize = 14,
}

-- Utility Functions
local function Create(class, properties, children)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.15, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function AddCorner(instance, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = instance
    })
end

local function AddStroke(instance, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = instance
    })
end

local function Ripple(button)
    local ripple = Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = button
    })
    AddCorner(ripple, 100)
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.4)
    
    task.delay(0.4, function()
        ripple:Destroy()
    end)
end

-- Main Window Creation
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Gamesense"
    local subtitle = config.Subtitle or "v1.0.0"
    local size = config.Size or UDim2.new(0, 620, 0, 450)
    local accentColor = config.AccentColor or Theme.Accent
    
    Theme.Accent = accentColor
    
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    
    -- Screen GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "GamesenseUI",
        Parent = RunService:IsStudio() and Player:WaitForChild("PlayerGui") or game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 6)
    AddStroke(MainFrame, Theme.Border, 1)
    
    -- Accent Line at Top
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Parent = MainFrame
    })
    
    local AccentGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(0.5, Theme.AccentDark),
            ColorSequenceKeypoint.new(1, Theme.Accent)
        }),
        Parent = AccentLine
    })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0, 45),
        Parent = MainFrame
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15 + TitleLabel.TextBounds.X + 5, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = Theme.Font,
        Text = subtitle,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Close Button
    local CloseButton = Create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Theme.FontBold,
        Text = "×",
        TextColor3 = Theme.TextDark,
        TextSize = 22,
        Parent = Header
    })
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {TextColor3 = Color3.fromRGB(255, 80, 80)}, 0.15)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {TextColor3 = Theme.TextDark}, 0.15)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local MinimizeButton = Create("TextButton", {
        Name = "Minimize",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0.5, 0),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Theme.FontBold,
        Text = "−",
        TextColor3 = Theme.TextDark,
        TextSize = 22,
        Parent = Header
    })
    
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 47)}, 0.2)
        else
            Tween(MainFrame, {Size = size}, 0.2)
        end
    end)
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Theme.TabBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 47),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = MainFrame
    })
    
    local TabLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = TabContainer
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 85),
        Size = UDim2.new(1, -20, 1, -95),
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Tab Creation
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or ""
        
        local Tab = {}
        Tab.Groupboxes = {}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            BackgroundColor3 = Theme.TabBackground,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 80, 1, 0),
            Font = Theme.Font,
            Text = tabName,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = TabContainer
        })
        
        -- Tab Indicator
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(0.8, 0, 0, 0),
            Parent = TabButton
        })
        AddCorner(TabIndicator, 2)
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            Parent = ContentContainer
        })
        
        local LeftColumn = Create("Frame", {
            Name = "LeftColumn",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 1, 0),
            Parent = TabContent
        })
        
        local LeftLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = LeftColumn
        })
        
        local RightColumn = Create("Frame", {
            Name = "RightColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 5, 0, 0),
            Size = UDim2.new(0.5, -5, 1, 0),
            Parent = TabContent
        })
        
        local RightLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = RightColumn
        })
        
        -- Update canvas size
        local function UpdateCanvas()
            local leftHeight = LeftLayout.AbsoluteContentSize.Y
            local rightHeight = RightLayout.AbsoluteContentSize.Y
            TabContent.CanvasSize = UDim2.new(0, 0, 0, math.max(leftHeight, rightHeight) + 10)
        end
        
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        
        -- Tab Selection
        local function SelectTab()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Theme.TabBackground
                tab.Button.TextColor3 = Theme.TextDark
                Tween(tab.Indicator, {Size = UDim2.new(0.8, 0, 0, 0)}, 0.15)
                tab.Content.Visible = false
            end
            
            TabButton.BackgroundColor3 = Theme.TabActive
            TabButton.TextColor3 = Theme.Text
            Tween(TabIndicator, {Size = UDim2.new(0.8, 0, 0, 2)}, 0.15)
            TabContent.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Tertiary}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.TabBackground}, 0.15)
            end
        end)
        
        -- Groupbox Creation
        function Tab:CreateGroupbox(groupConfig)
            groupConfig = groupConfig or {}
            local groupName = groupConfig.Name or "Groupbox"
            local side = groupConfig.Side or "Left"
            
            local Groupbox = {}
            Groupbox.Elements = {}
            
            local GroupFrame = Create("Frame", {
                Name = groupName,
                BackgroundColor3 = Theme.GroupboxBackground,
                Size = UDim2.new(1, 0, 0, 35),
                Parent = side == "Left" and LeftColumn or RightColumn
            })
            AddCorner(GroupFrame, 4)
            AddStroke(GroupFrame, Theme.GroupboxBorder, 1)
            
            local GroupTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 28),
                Font = Theme.FontBold,
                Text = groupName,
                TextColor3 = Theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = GroupFrame
            })
            
            local GroupContent = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 1, -35),
                Parent = GroupFrame
            })
            
            local ContentLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = GroupContent
            })
            
            local function UpdateGroupSize()
                GroupFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 40)
            end
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateGroupSize)
            
            -- CHECKBOX
            function Groupbox:AddCheckbox(checkConfig)
                checkConfig = checkConfig or {}
                local text = checkConfig.Text or "Checkbox"
                local default = checkConfig.Default or false
                local callback = checkConfig.Callback or function() end
                
                local Checkbox = {Value = default}
                
                local CheckboxFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = GroupContent
                })
                
                local CheckboxButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Theme.ElementBackground,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 0, 0.5, -7),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = CheckboxFrame
                })
                AddCorner(CheckboxButton, 3)
                AddStroke(CheckboxButton, Theme.Border, 1)
                
                local CheckMark = Create("TextLabel", {
                    Name = "Check",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Theme.FontBold,
                    Text = "✓",
                    TextColor3 = Theme.Background,
                    TextSize = 10,
                    TextTransparency = 1,
                    Parent = CheckboxButton
                })
                
                local CheckboxLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 22, 0, 0),
                    Size = UDim2.new(1, -22, 1, 0),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = CheckboxFrame
                })
                
                local function UpdateCheckbox()
                    if Checkbox.Value then
                        Tween(CheckboxButton, {BackgroundColor3 = Theme.Accent}, 0.15)
                        Tween(CheckMark, {TextTransparency = 0}, 0.15)
                    else
                        Tween(CheckboxButton, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
                        Tween(CheckMark, {TextTransparency = 1}, 0.15)
                    end
                end
                
                CheckboxButton.MouseButton1Click:Connect(function()
                    Checkbox.Value = not Checkbox.Value
                    UpdateCheckbox()
                    callback(Checkbox.Value)
                end)
                
                function Checkbox:Set(value)
                    Checkbox.Value = value
                    UpdateCheckbox()
                    callback(Checkbox.Value)
                end
                
                if default then UpdateCheckbox() end
                
                table.insert(Groupbox.Elements, Checkbox)
                return Checkbox
            end
            
            -- SLIDER
            function Groupbox:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local text = sliderConfig.Text or "Slider"
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                local default = sliderConfig.Default or min
                local increment = sliderConfig.Increment or 1
                local suffix = sliderConfig.Suffix or ""
                local callback = sliderConfig.Callback or function() end
                
                local Slider = {Value = default}
                
                local SliderFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = GroupContent
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local SliderValue = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBack = Create("Frame", {
                    Name = "Back",
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 12),
                    Parent = SliderFrame
                })
                AddCorner(SliderBack, 4)
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    Parent = SliderBack
                })
                AddCorner(SliderFill, 4)
                
                local SliderButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = SliderBack
                })
                
                local dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * pos
                    value = math.floor(value / increment + 0.5) * increment
                    value = math.clamp(value, min, max)
                    
                    Slider.Value = value
                    SliderValue.Text = tostring(value) .. suffix
                    Tween(SliderFill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.05)
                    callback(value)
                end
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                function Slider:Set(value)
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    SliderValue.Text = tostring(value) .. suffix
                    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    callback(value)
                end
                
                table.insert(Groupbox.Elements, Slider)
                return Slider
            end
            
            -- DROPDOWN
            function Groupbox:AddDropdown(dropConfig)
                dropConfig = dropConfig or {}
                local text = dropConfig.Text or "Dropdown"
                local options = dropConfig.Options or {}
                local default = dropConfig.Default or options[1] or ""
                local callback = dropConfig.Callback or function() end
                
                local Dropdown = {Value = default, Open = false}
                
                local DropdownFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ClipsDescendants = false,
                    Parent = GroupContent
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Theme.Font,
                    Text = "  " .. tostring(default),
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = DropdownFrame
                })
                AddCorner(DropdownButton, 4)
                AddStroke(DropdownButton, Theme.Border, 1)
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    Font = Theme.FontBold,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 8,
                    Parent = DropdownButton
                })
                
                local DropdownList = Create("Frame", {
                    Name = "List",
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, 48),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    ZIndex = 10,
                    Visible = false,
                    Parent = DropdownFrame
                })
                AddCorner(DropdownList, 4)
                AddStroke(DropdownList, Theme.Border, 1)
                
                local ListLayout = Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownList
                })
                
                local ListPadding = Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    Parent = DropdownList
                })
                
                local function CreateOption(option)
                    local OptionButton = Create("TextButton", {
                        Name = option,
                        BackgroundColor3 = Theme.ElementBackgroundHover,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 24),
                        Font = Theme.Font,
                        Text = "  " .. option,
                        TextColor3 = option == Dropdown.Value and Theme.Accent or Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        ZIndex = 11,
                        Parent = DropdownList
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1}, 0.1)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownButton.Text = "  " .. option
                        callback(option)
                        
                        for _, child in pairs(DropdownList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = child.Name == option and Theme.Accent or Theme.Text
                            end
                        end
                        
                        Dropdown.Open = false
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        Tween(DropdownArrow, {Rotation = 0}, 0.15)
                        task.delay(0.15, function()
                            DropdownList.Visible = false
                        end)
                    end)
                end
                
                for _, option in ipairs(options) do
                    CreateOption(option)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownList.Visible = true
                        local listHeight = math.min(#options * 24 + 8, 150)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, listHeight)}, 0.15)
                        Tween(DropdownArrow, {Rotation = 180}, 0.15)
                    else
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        Tween(DropdownArrow, {Rotation = 0}, 0.15)
                        task.delay(0.15, function()
                            DropdownList.Visible = false
                        end)
                    end
                end)
                
                function Dropdown:Set(value)
                    if table.find(options, value) then
                        Dropdown.Value = value
                        DropdownButton.Text = "  " .. value
                        callback(value)
                    end
                end
                
                function Dropdown:Refresh(newOptions, keepValue)
                    options = newOptions
                    for _, child in pairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, option in ipairs(options) do
                        CreateOption(option)
                    end
                    if not keepValue or not table.find(options, Dropdown.Value) then
                        Dropdown.Value = options[1] or ""
                        DropdownButton.Text = "  " .. Dropdown.Value
                    end
                end
                
                table.insert(Groupbox.Elements, Dropdown)
                return Dropdown
            end
            
            -- COLORPICKER
            function Groupbox:AddColorPicker(colorConfig)
                colorConfig = colorConfig or {}
                local text = colorConfig.Text or "Color"
                local default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
                local callback = colorConfig.Callback or function() end
                
                local ColorPicker = {Value = default, Open = false}
                local H, S, V = default:ToHSV()
                
                local ColorFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = GroupContent
                })
                
                local ColorLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -35, 1, 0),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })
                
                local ColorButton = Create("TextButton", {
                    Name = "Button",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = default,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 28, 0, 14),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ColorFrame
                })
                AddCorner(ColorButton, 4)
                AddStroke(ColorButton, Theme.Border, 1)
                
                -- Color Picker Popup
                local ColorPopup = Create("Frame", {
                    Name = "Popup",
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = Theme.Secondary,
                    Position = UDim2.new(1, 0, 1, 5),
                    Size = UDim2.new(0, 180, 0, 160),
                    Visible = false,
                    ZIndex = 20,
                    Parent = ColorFrame
                })
                AddCorner(ColorPopup, 6)
                AddStroke(ColorPopup, Theme.Border, 1)
                
                local SaturationFrame = Create("ImageLabel", {
                    Name = "Saturation",
                    BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(0, 130, 0, 100),
                    Image = "rbxassetid://4155801252",
                    ZIndex = 21,
                    Parent = ColorPopup
                })
                AddCorner(SaturationFrame, 4)
                
                local SaturationGradient = Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0, 0, 0)),
                    Rotation = 90,
                    Parent = SaturationFrame
                })
                
                local SaturationPicker = Create("Frame", {
                    Name = "Picker",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(S, 0, 1 - V, 0),
                    Size = UDim2.new(0, 8, 0, 8),
                    ZIndex = 22,
                    Parent = SaturationFrame
                })
                AddCorner(SaturationPicker, 100)
                AddStroke(SaturationPicker, Color3.new(0, 0, 0), 1)
                
                local HueFrame = Create("Frame", {
                    Name = "Hue",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(0, 150, 0, 10),
                    Size = UDim2.new(0, 20, 0, 100),
                    ZIndex = 21,
                    Parent = ColorPopup
                })
                AddCorner(HueFrame, 4)
                
                local HueGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }),
                    Rotation = 90,
                    Parent = HueFrame
                })
                
                local HuePicker = Create("Frame", {
                    Name = "Picker",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(0.5, 0, H, 0),
                    Size = UDim2.new(1, 4, 0, 4),
                    ZIndex = 22,
                    Parent = HueFrame
                })
                AddCorner(HuePicker, 2)
                AddStroke(HuePicker, Color3.new(0, 0, 0), 1)
                
                local PreviewColor = Create("Frame", {
                    Name = "Preview",
                    BackgroundColor3 = default,
                    Position = UDim2.new(0, 10, 0, 120),
                    Size = UDim2.new(1, -20, 0, 30),
                    ZIndex = 21,
                    Parent = ColorPopup
                })
                AddCorner(PreviewColor, 4)
                AddStroke(PreviewColor, Theme.Border, 1)
                
                local function UpdateColor()
                    local color = Color3.fromHSV(H, S, V)
                    ColorPicker.Value = color
                    ColorButton.BackgroundColor3 = color
                    PreviewColor.BackgroundColor3 = color
                    SaturationFrame.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    callback(color)
                end
                
                -- Saturation/Value picking
                local satDragging = false
                SaturationFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        satDragging = true
                    end
                end)
                SaturationFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        satDragging = false
                    end
                end)
                
                -- Hue picking
                local hueDragging = false
                HueFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                    end
                end)
                HueFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if satDragging then
                            local pos = input.Position
                            local relX = math.clamp((pos.X - SaturationFrame.AbsolutePosition.X) / SaturationFrame.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((pos.Y - SaturationFrame.AbsolutePosition.Y) / SaturationFrame.AbsoluteSize.Y, 0, 1)
                            S = relX
                            V = 1 - relY
                            SaturationPicker.Position = UDim2.new(S, 0, 1 - V, 0)
                            UpdateColor()
                        elseif hueDragging then
                            local pos = input.Position
                            local relY = math.clamp((pos.Y - HueFrame.AbsolutePosition.Y) / HueFrame.AbsoluteSize.Y, 0, 1)
                            H = relY
                            HuePicker.Position = UDim2.new(0.5, 0, H, 0)
                            UpdateColor()
                        end
                    end
                end)
                
                ColorButton.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    ColorPopup.Visible = ColorPicker.Open
                end)
                
                function ColorPicker:Set(color)
                    H, S, V = color:ToHSV()
                    SaturationPicker.Position = UDim2.new(S, 0, 1 - V, 0)
                    HuePicker.Position = UDim2.new(0.5, 0, H, 0)
                    UpdateColor()
                end
                
                table.insert(Groupbox.Elements, ColorPicker)
                return ColorPicker
            end
            
            -- BUTTON
            function Groupbox:AddButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                local text = buttonConfig.Text or "Button"
                local callback = buttonConfig.Callback or function() end
                
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = text,
                    BackgroundColor3 = Theme.ElementBackground,
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                    Parent = GroupContent
                })
                AddCorner(ButtonFrame, 4)
                AddStroke(ButtonFrame, Theme.Border, 1)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.15)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Ripple(ButtonFrame)
                    callback()
                end)
                
                table.insert(Groupbox.Elements, Button)
                return Button
            end
            
            -- TEXTBOX
            function Groupbox:AddTextbox(textConfig)
                textConfig = textConfig or {}
                local text = textConfig.Text or "Textbox"
                local placeholder = textConfig.Placeholder or "Enter text..."
                local default = textConfig.Default or ""
                local callback = textConfig.Callback or function() end
                
                local Textbox = {Value = default}
                
                local TextboxFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = GroupContent
                })
                
                local TextboxLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextboxFrame
                })
                
                local TextboxInput = Create("TextBox", {
                    Name = "Input",
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Theme.Font,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDark,
                    Text = default,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                    Parent = TextboxFrame
                })
                AddCorner(TextboxInput, 4)
                AddStroke(TextboxInput, Theme.Border, 1)
                
                local inputStroke = TextboxInput:FindFirstChildOfClass("UIStroke")
                
                TextboxInput.Focused:Connect(function()
                    Tween(inputStroke, {Color = Theme.Accent}, 0.15)
                end)
                
                TextboxInput.FocusLost:Connect(function()
                    Tween(inputStroke, {Color = Theme.Border}, 0.15)
                    Textbox.Value = TextboxInput.Text
                    callback(TextboxInput.Text)
                end)
                
                function Textbox:Set(value)
                    TextboxInput.Text = value
                    Textbox.Value = value
                end
                
                table.insert(Groupbox.Elements, Textbox)
                return Textbox
            end
            
            -- KEYBIND
            function Groupbox:AddKeybind(keybindConfig)
                keybindConfig = keybindConfig or {}
                local text = keybindConfig.Text or "Keybind"
                local default = keybindConfig.Default or Enum.KeyCode.Unknown
                local callback = keybindConfig.Callback or function() end
                local changedCallback = keybindConfig.ChangedCallback or function() end
                
                local Keybind = {Value = default, Listening = false}
                
                local KeybindFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = GroupContent
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 55, 0, 18),
                    Font = Theme.Font,
                    Text = default ~= Enum.KeyCode.Unknown and default.Name or "None",
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    AutoButtonColor = false,
                    Parent = KeybindFrame
                })
                AddCorner(KeybindButton, 4)
                AddStroke(KeybindButton, Theme.Border, 1)
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            Keybind.Listening = false
                            changedCallback(input.KeyCode)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                               input.UserInputType == Enum.UserInputType.MouseButton2 then
                            -- Cancel
                            Keybind.Listening = false
                            KeybindButton.Text = Keybind.Value ~= Enum.KeyCode.Unknown and Keybind.Value.Name or "None"
                        end
                    elseif input.UserInputType == Enum.UserInputType.Keyboard and 
                           input.KeyCode == Keybind.Value and not processed then
                        callback(Keybind.Value)
                    end
                end)
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key ~= Enum.KeyCode.Unknown and key.Name or "None"
                end
                
                table.insert(Groupbox.Elements, Keybind)
                return Keybind
            end
            
            -- TOGGLE
            function Groupbox:AddToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local text = toggleConfig.Text or "Toggle"
                local default = toggleConfig.Default or false
                local callback = toggleConfig.Callback or function() end
                
                local Toggle = {Value = default}
                
                local ToggleFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = GroupContent
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -45, 1, 0),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = Create("TextButton", {
                    Name = "Button",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 38, 0, 18),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ToggleFrame
                })
                AddCorner(ToggleButton, 9)
                AddStroke(ToggleButton, Theme.Border, 1)
                
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Theme.TextDark,
                    Position = UDim2.new(0, 3, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    Parent = ToggleButton
                })
                AddCorner(ToggleCircle, 100)
                
                local function UpdateToggle()
                    if Toggle.Value then
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Accent}, 0.2)
                        Tween(ToggleCircle, {
                            Position = UDim2.new(1, -15, 0.5, 0),
                            BackgroundColor3 = Color3.new(1, 1, 1)
                        }, 0.2)
                    else
                        Tween(ToggleButton, {BackgroundColor3 = Theme.ElementBackground}, 0.2)
                        Tween(ToggleCircle, {
                            Position = UDim2.new(0, 3, 0.5, 0),
                            BackgroundColor3 = Theme.TextDark
                        }, 0.2)
                    end
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                    callback(Toggle.Value)
                end)
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    UpdateToggle()
                    callback(Toggle.Value)
                end
                
                if default then UpdateToggle() end
                
                table.insert(Groupbox.Elements, Toggle)
                return Toggle
            end
            
            -- LABEL
            function Groupbox:AddLabel(labelText)
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Theme.Font,
                    Text = labelText or "Label",
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = GroupContent
                })
                
                function Label:Set(text)
                    LabelFrame.Text = text
                end
                
                table.insert(Groupbox.Elements, Label)
                return Label
            end
            
            -- DIVIDER
            function Groupbox:AddDivider()
                local Divider = Create("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = Theme.Border,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = GroupContent
                })
                return Divider
            end
            
            table.insert(Tab.Groupboxes, Groupbox)
            return Groupbox
        end
        
        table.insert(Window.Tabs, {
            Tab = Tab,
            Button = TabButton,
            Indicator = TabIndicator,
            Content = TabContent
        })
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            SelectTab()
        end
        
        return Tab
    end
    
    -- Toggle UI visibility
    function Window:Toggle()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
    
    -- Set accent color
    function Window:SetAccent(color)
        Theme.Accent = color
        AccentLine.BackgroundColor3 = color
        -- Update all accent elements
    end
    
    -- Destroy window
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return Library
