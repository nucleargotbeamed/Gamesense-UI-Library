--[[
    Gamesense/Skeet Style UI Library for Roblox
    Accurate recreation of the CS:GO cheat menu aesthetic
]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

-- Theme Configuration (Gamesense Style)
local Theme = {
    -- Main Colors
    WindowBackground = Color3.fromRGB(16, 16, 16),
    TitleBar = Color3.fromRGB(22, 22, 22),
    SidebarBackground = Color3.fromRGB(18, 18, 18),
    GroupBackground = Color3.fromRGB(20, 20, 20),
    GroupBorder = Color3.fromRGB(35, 35, 35),
    GroupHeader = Color3.fromRGB(25, 25, 25),
    
    -- Element Colors
    ElementBackground = Color3.fromRGB(32, 32, 32),
    ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
    ElementBorder = Color3.fromRGB(50, 50, 50),
    
    -- Accent Colors
    Accent = Color3.fromRGB(127, 194, 65), -- Lime green
    AccentDark = Color3.fromRGB(90, 140, 45),
    AccentBlue = Color3.fromRGB(65, 150, 194),
    AccentPink = Color3.fromRGB(194, 65, 150),
    AccentRed = Color3.fromRGB(194, 65, 65),
    AccentYellow = Color3.fromRGB(194, 180, 65),
    AccentCyan = Color3.fromRGB(65, 194, 194),
    AccentOrange = Color3.fromRGB(194, 130, 65),
    
    -- Text Colors
    Text = Color3.fromRGB(205, 205, 205),
    TextDark = Color3.fromRGB(130, 130, 130),
    TextDisabled = Color3.fromRGB(80, 80, 80),
    TextHeader = Color3.fromRGB(180, 180, 180),
    
    -- Checkbox
    CheckboxBackground = Color3.fromRGB(36, 36, 36),
    CheckboxBorder = Color3.fromRGB(55, 55, 55),
    CheckboxEnabled = Color3.fromRGB(127, 194, 65),
    CheckboxDisabled = Color3.fromRGB(45, 45, 45),
    
    -- Slider
    SliderBackground = Color3.fromRGB(30, 30, 30),
    SliderFill = Color3.fromRGB(127, 194, 65),
    
    -- Dropdown
    DropdownBackground = Color3.fromRGB(28, 28, 28),
    DropdownBorder = Color3.fromRGB(45, 45, 45),
    
    -- Fonts
    Font = Enum.Font.Gotham,
    FontSemibold = Enum.Font.GothamSemibold,
    FontBold = Enum.Font.GothamBold,
    
    -- Sizes
    TextSize = 11,
    HeaderSize = 11,
    SmallText = 10,
}

-- Utility Functions
local function Create(class, properties, children)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function AddStroke(instance, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Theme.GroupBorder,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = instance
    })
end

local function CreateNoise(parent)
    local noise = Create("ImageLabel", {
        Name = "Noise",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://6071575925",
        ImageColor3 = Color3.new(1, 1, 1),
        ImageTransparency = 0.97,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 128, 0, 128),
        ZIndex = 0,
        Parent = parent
    })
    return noise
end

-- Icon data (simplified representations)
local Icons = {
    ESP = "👁",
    Crosshair = "⊕",
    Target = "◎",
    Visuals = "☀",
    Settings = "⚙",
    Misc = "📱",
    Profile = "👤",
    Rage = "💀",
    Legit = "🎯",
    Skins = "🎨"
}

-- Main Window Creation
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "gamesense"
    local subtitle = config.Subtitle or "cs2"
    local size = config.Size or UDim2.new(0, 780, 0, 520)
    
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Visible = true
    
    -- Screen GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "GamesenseUI_" .. HttpService:GenerateGUID(false),
        Parent = RunService:IsStudio() and Player:WaitForChild("PlayerGui") or game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.WindowBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        Parent = ScreenGui
    })
    
    -- Outer border
    Create("UIStroke", {
        Color = Color3.fromRGB(45, 45, 45),
        Thickness = 1,
        Parent = MainFrame
    })
    
    -- Add noise texture
    CreateNoise(MainFrame)
    
    -- Inner glow effect
    local InnerGlow = Create("Frame", {
        Name = "InnerGlow",
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 1,
        Parent = MainFrame
    })
    
    Create("UIStroke", {
        Color = Color3.fromRGB(35, 35, 35),
        Thickness = 1,
        Parent = InnerGlow
    })
    
    -- Accent line at top
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 0, 2),
        ZIndex = 10,
        Parent = MainFrame
    })
    
    local AccentGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(0.3, Theme.AccentDark),
            ColorSequenceKeypoint.new(0.5, Theme.Accent),
            ColorSequenceKeypoint.new(0.7, Theme.AccentDark),
            ColorSequenceKeypoint.new(1, Theme.Accent)
        }),
        Parent = AccentLine
    })
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Theme.TitleBar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 3),
        Size = UDim2.new(1, -2, 0, 26),
        ZIndex = 2,
        Parent = MainFrame
    })
    
    CreateNoise(TitleBar)
    
    -- Title text
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TitleBar
    })
    
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50 + TitleLabel.TextBounds.X + 5, 0, 0),
        Size = UDim2.new(0, 50, 1, 0),
        Font = Theme.Font,
        Text = subtitle,
        TextColor3 = Theme.TextDark,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TitleBar
    })
    
    -- Window controls
    local CloseButton = Create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Font = Theme.Font,
        Text = "×",
        TextColor3 = Theme.TextDark,
        TextSize = 18,
        ZIndex = 3,
        Parent = TitleBar
    })
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {TextColor3 = Theme.AccentRed}, 0.15)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {TextColor3 = Theme.TextDark}, 0.15)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    local MinimizeButton = Create("TextButton", {
        Name = "Minimize",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -26, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Font = Theme.Font,
        Text = "−",
        TextColor3 = Theme.TextDark,
        TextSize = 18,
        ZIndex = 3,
        Parent = TitleBar
    })
    
    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {TextColor3 = Theme.Text}, 0.15)
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {TextColor3 = Theme.TextDark}, 0.15)
    end)
    
    -- Left Sidebar (Icon Bar)
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.SidebarBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 29),
        Size = UDim2.new(0, 44, 1, -30),
        ZIndex = 2,
        Parent = MainFrame
    })
    
    CreateNoise(Sidebar)
    
    Create("UIStroke", {
        Color = Theme.GroupBorder,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = Sidebar
    })
    
    local SidebarLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = Sidebar
    })
    
    local SidebarPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        Parent = Sidebar
    })
    
    -- Tab Container (horizontal tabs below title)
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Theme.TitleBar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 45, 0, 29),
        Size = UDim2.new(1, -46, 0, 24),
        ZIndex = 2,
        Parent = MainFrame
    })
    
    CreateNoise(TabContainer)
    
    local TabLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = TabContainer
    })
    
    local TabPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        Parent = TabContainer
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 56),
        Size = UDim2.new(1, -55, 1, -61),
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = MainFrame
    })
    
    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
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
    
    -- Toggle visibility with keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            Window.Visible = not Window.Visible
            ScreenGui.Enabled = Window.Visible
        end
    end)
    
    -- Sidebar Icon Creation
    function Window:AddSidebarIcon(iconConfig)
        iconConfig = iconConfig or {}
        local icon = iconConfig.Icon or "⚙"
        local tooltip = iconConfig.Tooltip or "Tab"
        local callback = iconConfig.Callback or function() end
        
        local IconButton = Create("TextButton", {
            Name = tooltip,
            BackgroundColor3 = Theme.GroupBackground,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 36, 0, 36),
            Font = Enum.Font.SourceSans,
            Text = icon,
            TextColor3 = Theme.TextDark,
            TextSize = 18,
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = Sidebar
        })
        
        local IconIndicator = Create("Frame", {
            Name = "Indicator",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0.6, 0),
            ZIndex = 4,
            Parent = IconButton
        })
        
        IconButton.MouseEnter:Connect(function()
            if IconButton.BackgroundTransparency == 1 then
                Tween(IconButton, {TextColor3 = Theme.Text}, 0.15)
            end
        end)
        
        IconButton.MouseLeave:Connect(function()
            if IconButton.BackgroundTransparency == 1 then
                Tween(IconButton, {TextColor3 = Theme.TextDark}, 0.15)
            end
        end)
        
        IconButton.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return {
            Button = IconButton,
            Indicator = IconIndicator,
            SetActive = function(active)
                if active then
                    Tween(IconButton, {TextColor3 = Theme.Text}, 0.15)
                    Tween(IconIndicator, {Size = UDim2.new(0, 2, 0.6, 0)}, 0.15)
                else
                    Tween(IconButton, {TextColor3 = Theme.TextDark}, 0.15)
                    Tween(IconIndicator, {Size = UDim2.new(0, 0, 0.6, 0)}, 0.15)
                end
            end
        }
    end
    
    -- Sub-tab creation
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local icon = tabConfig.Icon or nil
        
        local Tab = {}
        Tab.Groupboxes = {}
        Tab.Name = tabName
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            BackgroundColor3 = Theme.TitleBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 75, 1, 0),
            Font = Theme.Font,
            Text = string.lower(tabName),
            TextColor3 = Theme.TextDark,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = TabContainer
        })
        
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(0.9, 0, 0, 0),
            ZIndex = 4,
            Parent = TabButton
        })
        
        -- Tab Content (scrolling frame with columns)
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.TextDark,
            ScrollBarImageTransparency = 0.5,
            Visible = false,
            ZIndex = 2,
            Parent = ContentContainer
        })
        
        -- Two column layout
        local LeftColumn = Create("Frame", {
            Name = "LeftColumn",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -8, 1, 0),
            ZIndex = 2,
            Parent = TabContent
        })
        
        local LeftLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = LeftColumn
        })
        
        local RightColumn = Create("Frame", {
            Name = "RightColumn",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 4, 0, 0),
            Size = UDim2.new(0.5, -8, 1, 0),
            ZIndex = 2,
            Parent = TabContent
        })
        
        local RightLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
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
                tab.Button.TextColor3 = Theme.TextDark
                Tween(tab.Indicator, {Size = UDim2.new(0.9, 0, 0, 0)}, 0.1)
                tab.Content.Visible = false
            end
            
            TabButton.TextColor3 = Theme.Text
            Tween(TabIndicator, {Size = UDim2.new(0.9, 0, 0, 2)}, 0.1)
            TabContent.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {TextColor3 = Theme.Text}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {TextColor3 = Theme.TextDark}, 0.1)
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
                BackgroundColor3 = Theme.GroupBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 3,
                Parent = side == "Left" and LeftColumn or RightColumn
            })
            
            CreateNoise(GroupFrame)
            
            -- Double border effect
            Create("UIStroke", {
                Color = Theme.GroupBorder,
                Thickness = 1,
                Parent = GroupFrame
            })
            
            -- Group Header
            local GroupHeader = Create("Frame", {
                Name = "Header",
                BackgroundColor3 = Theme.GroupHeader,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 4,
                Parent = GroupFrame
            })
            
            local HeaderLine = Create("Frame", {
                Name = "Line",
                BackgroundColor3 = Theme.GroupBorder,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                ZIndex = 5,
                Parent = GroupHeader
            })
            
            local GroupTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Theme.FontSemibold,
                Text = groupName,
                TextColor3 = Theme.TextHeader,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = GroupHeader
            })
            
            local GroupContent = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 26),
                Size = UDim2.new(1, -16, 1, -30),
                ZIndex = 4,
                Parent = GroupFrame
            })
            
            local ContentLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = GroupContent
            })
            
            local function UpdateGroupSize()
                local contentHeight = ContentLayout.AbsoluteContentSize.Y
                GroupFrame.Size = UDim2.new(1, 0, 0, contentHeight + 34)
            end
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateGroupSize)
            
            -- ═══════════════════════════════════════════════
            -- CHECKBOX (Square style like Gamesense)
            -- ═══════════════════════════════════════════════
            function Groupbox:AddCheckbox(checkConfig)
                checkConfig = checkConfig or {}
                local text = checkConfig.Text or "Checkbox"
                local default = checkConfig.Default or false
                local callback = checkConfig.Callback or function() end
                local colorPickerConfig = checkConfig.ColorPicker or nil
                
                local Checkbox = {Value = default}
                
                local CheckboxFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    ZIndex = 5,
                    Parent = GroupContent
                })
                
                local CheckboxOuter = Create("Frame", {
                    Name = "Outer",
                    BackgroundColor3 = Theme.CheckboxBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 6,
                    Parent = CheckboxFrame
                })
                
                Create("UIStroke", {
                    Color = Theme.CheckboxBorder,
                    Thickness = 1,
                    Parent = CheckboxOuter
                })
                
                local CheckboxInner = Create("Frame", {
                    Name = "Inner",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Theme.CheckboxEnabled,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 0, 0, 0),
                    ZIndex = 7,
                    Parent = CheckboxOuter
                })
                
                local CheckboxLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 18, 0, 0),
                    Size = UDim2.new(1, -18, 1, 0),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = CheckboxFrame
                })
                
                local CheckboxButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, colorPickerConfig and -22 or 0, 1, 0),
                    Text = "",
                    ZIndex = 8,
                    Parent = CheckboxFrame
                })
                
                -- Color picker attachment
                local ColorPicker = nil
                if colorPickerConfig then
                    local cpDefault = colorPickerConfig.Default or Color3.fromRGB(255, 255, 255)
                    local cpCallback = colorPickerConfig.Callback or function() end
                    
                    ColorPicker = {Value = cpDefault, Open = false}
                    local H, S, V = cpDefault:ToHSV()
                    
                    local ColorButton = Create("TextButton", {
                        Name = "ColorButton",
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = cpDefault,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 18, 0, 10),
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 6,
                        Parent = CheckboxFrame
                    })
                    
                    Create("UIStroke", {
                        Color = Color3.fromRGB(0, 0, 0),
                        Thickness = 1,
                        Parent = ColorButton
                    })
                    
                    -- Color picker popup
                    local ColorPopup = Create("Frame", {
                        Name = "ColorPopup",
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundColor3 = Theme.GroupBackground,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 1, 4),
                        Size = UDim2.new(0, 180, 0, 140),
                        Visible = false,
                        ZIndex = 100,
                        Parent = CheckboxFrame
                    })
                    
                    Create("UIStroke", {
                        Color = Theme.GroupBorder,
                        Thickness = 1,
                        Parent = ColorPopup
                    })
                    
                    -- Saturation/Value picker
                    local SVPicker = Create("Frame", {
                        Name = "SVPicker",
                        BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0, 8),
                        Size = UDim2.new(0, 140, 0, 100),
                        ZIndex = 101,
                        Parent = ColorPopup
                    })
                    
                    local SaturationGradient = Create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0)
                        }),
                        Parent = SVPicker
                    })
                    
                    local ValueOverlay = Create("Frame", {
                        Name = "ValueOverlay",
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 102,
                        Parent = SVPicker
                    })
                    
                    Create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0)
                        }),
                        Rotation = 90,
                        Parent = ValueOverlay
                    })
                    
                    local SVCursor = Create("Frame", {
                        Name = "Cursor",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(S, 0, 1 - V, 0),
                        Size = UDim2.new(0, 6, 0, 6),
                        ZIndex = 104,
                        Parent = SVPicker
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = SVCursor
                    })
                    
                    Create("UIStroke", {
                        Color = Color3.new(0, 0, 0),
                        Thickness = 1,
                        Parent = SVCursor
                    })
                    
                    -- Hue slider
                    local HueSlider = Create("Frame", {
                        Name = "HueSlider",
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 154, 0, 8),
                        Size = UDim2.new(0, 18, 0, 100),
                        ZIndex = 101,
                        Parent = ColorPopup
                    })
                    
                    Create("UIGradient", {
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
                        Parent = HueSlider
                    })
                    
                    local HueCursor = Create("Frame", {
                        Name = "Cursor",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, H, 0),
                        Size = UDim2.new(1, 4, 0, 4),
                        ZIndex = 102,
                        Parent = HueSlider
                    })
                    
                    Create("UIStroke", {
                        Color = Color3.new(1, 1, 1),
                        Thickness = 1,
                        Parent = HueCursor
                    })
                    
                    -- Preview
                    local Preview = Create("Frame", {
                        Name = "Preview",
                        BackgroundColor3 = cpDefault,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0, 114),
                        Size = UDim2.new(1, -16, 0, 18),
                        ZIndex = 101,
                        Parent = ColorPopup
                    })
                    
                    Create("UIStroke", {
                        Color = Theme.GroupBorder,
                        Thickness = 1,
                        Parent = Preview
                    })
                    
                    local function UpdateColor()
                        local color = Color3.fromHSV(H, S, V)
                        ColorPicker.Value = color
                        ColorButton.BackgroundColor3 = color
                        Preview.BackgroundColor3 = color
                        SVPicker.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                        cpCallback(color)
                    end
                    
                    -- SV dragging
                    local svDragging = false
                    SVPicker.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = true
                        end
                    end)
                    
                    ValueOverlay.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = true
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = false
                        end
                    end)
                    
                    -- Hue dragging
                    local hueDragging = false
                    HueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            hueDragging = true
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if svDragging then
                                local relX = math.clamp((input.Position.X - SVPicker.AbsolutePosition.X) / SVPicker.AbsoluteSize.X, 0, 1)
                                local relY = math.clamp((input.Position.Y - SVPicker.AbsolutePosition.Y) / SVPicker.AbsoluteSize.Y, 0, 1)
                                S = relX
                                V = 1 - relY
                                SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                                UpdateColor()
                            elseif hueDragging then
                                local relY = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                                H = relY
                                HueCursor.Position = UDim2.new(0.5, 0, H, 0)
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
                        SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        HueCursor.Position = UDim2.new(0.5, 0, H, 0)
                        UpdateColor()
                    end
                    
                    Checkbox.ColorPicker = ColorPicker
                end
                
                local function UpdateCheckbox()
                    if Checkbox.Value then
                        Tween(CheckboxInner, {Size = UDim2.new(0, 8, 0, 8)}, 0.1)
                        Tween(CheckboxLabel, {TextColor3 = Theme.Text}, 0.1)
                    else
                        Tween(CheckboxInner, {Size = UDim2.new(0, 0, 0, 0)}, 0.1)
                        Tween(CheckboxLabel, {TextColor3 = Theme.TextDark}, 0.1)
                    end
                end
                
                CheckboxButton.MouseButton1Click:Connect(function()
                    Checkbox.Value = not Checkbox.Value
                    UpdateCheckbox()
                    callback(Checkbox.Value)
                end)
                
                CheckboxButton.MouseEnter:Connect(function()
                    Tween(CheckboxLabel, {TextColor3 = Theme.Text}, 0.1)
                end)
                
                CheckboxButton.MouseLeave:Connect(function()
                    if not Checkbox.Value then
                        Tween(CheckboxLabel, {TextColor3 = Theme.TextDark}, 0.1)
                    end
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
            
            -- ═══════════════════════════════════════════════
            -- SLIDER
            -- ═══════════════════════════════════════════════
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
                    Size = UDim2.new(1, 0, 0, 28),
                    ZIndex = 5,
                    Parent = GroupContent
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = SliderFrame
                })
                
                local SliderValue = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 5,
                    Parent = SliderFrame
                })
                
                local SliderBack = Create("Frame", {
                    Name = "Back",
                    BackgroundColor3 = Theme.SliderBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 16),
                    Size = UDim2.new(1, 0, 0, 10),
                    ZIndex = 6,
                    Parent = SliderFrame
                })
                
                Create("UIStroke", {
                    Color = Theme.GroupBorder,
                    Thickness = 1,
                    Parent = SliderBack
                })
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    ZIndex = 7,
                    Parent = SliderBack
                })
                
                -- Gradient on fill
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.Accent),
                        ColorSequenceKeypoint.new(1, Theme.AccentDark)
                    }),
                    Rotation = 90,
                    Parent = SliderFill
                })
                
                local SliderButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 8,
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
                    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    callback(value)
                end
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
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
            
            -- ═══════════════════════════════════════════════
            -- DROPDOWN
            -- ═══════════════════════════════════════════════
            function Groupbox:AddDropdown(dropConfig)
                dropConfig = dropConfig or {}
                local text = dropConfig.Text or "Dropdown"
                local options = dropConfig.Options or {}
                local default = dropConfig.Default or options[1] or ""
                local callback = dropConfig.Callback or function() end
                local multi = dropConfig.Multi or false
                
                local Dropdown = {Value = multi and {} or default, Open = false}
                
                if multi and type(default) == "table" then
                    Dropdown.Value = default
                elseif multi then
                    Dropdown.Value = {}
                end
                
                local DropdownFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = false,
                    ZIndex = 5,
                    Parent = GroupContent
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Theme.DropdownBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 16),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Theme.Font,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 6,
                    Parent = DropdownFrame
                })
                
                Create("UIStroke", {
                    Color = Theme.DropdownBorder,
                    Thickness = 1,
                    Parent = DropdownButton
                })
                
                local DropdownText = Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Font = Theme.Font,
                    Text = multi and "..." or tostring(default),
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 7,
                    Parent = DropdownButton
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    Font = Theme.FontBold,
                    Text = "▾",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    ZIndex = 7,
                    Parent = DropdownButton
                })
                
                local DropdownList = Create("Frame", {
                    Name = "List",
                    BackgroundColor3 = Theme.DropdownBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 38),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50,
                    Parent = DropdownFrame
                })
                
                Create("UIStroke", {
                    Color = Theme.DropdownBorder,
                    Thickness = 1,
                    Parent = DropdownList
                })
                
                local ListScroll = Create("ScrollingFrame", {
                    Name = "Scroll",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.TextDark,
                    ZIndex = 51,
                    Parent = DropdownList
                })
                
                local ListLayout = Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 1),
                    Parent = ListScroll
                })
                
                local function UpdateDisplayText()
                    if multi then
                        local selected = {}
                        for option, enabled in pairs(Dropdown.Value) do
                            if enabled then
                                table.insert(selected, option)
                            end
                        end
                        DropdownText.Text = #selected > 0 and table.concat(selected, ", ") or "..."
                    else
                        DropdownText.Text = tostring(Dropdown.Value)
                    end
                end
                
                local function CreateOption(option)
                    local OptionButton = Create("TextButton", {
                        Name = option,
                        BackgroundColor3 = Theme.ElementBackgroundHover,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        Font = Theme.Font,
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 52,
                        Parent = ListScroll
                    })
                    
                    local OptionLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -16, 1, 0),
                        Font = Theme.Font,
                        Text = option,
                        TextColor3 = (multi and Dropdown.Value[option]) or (not multi and Dropdown.Value == option) and Theme.Accent or Theme.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 53,
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1}, 0.1)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[option] = not Dropdown.Value[option]
                            OptionLabel.TextColor3 = Dropdown.Value[option] and Theme.Accent or Theme.Text
                            UpdateDisplayText()
                            callback(Dropdown.Value)
                        else
                            Dropdown.Value = option
                            UpdateDisplayText()
                            callback(option)
                            
                            -- Update all option colors
                            for _, child in pairs(ListScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local label = child:FindFirstChild("Label")
                                    if label then
                                        label.TextColor3 = child.Name == option and Theme.Accent or Theme.Text
                                    end
                                end
                            end
                            
                            -- Close dropdown
                            Dropdown.Open = false
                            Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                            Tween(DropdownArrow, {Rotation = 0}, 0.15)
                            task.delay(0.15, function()
                                DropdownList.Visible = false
                            end)
                        end
                    end)
                    
                    return OptionButton
                end
                
                for _, option in ipairs(options) do
                    CreateOption(option)
                end
                
                ListScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 19)
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownList.Visible = true
                        local listHeight = math.min(#options * 19, 120)
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
                    if multi then
                        Dropdown.Value = value
                    else
                        Dropdown.Value = value
                    end
                    UpdateDisplayText()
                    callback(value)
                end
                
                function Dropdown:Refresh(newOptions)
                    options = newOptions
                    for _, child in pairs(ListScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, option in ipairs(options) do
                        CreateOption(option)
                    end
                    ListScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 19)
                end
                
                UpdateDisplayText()
                
                table.insert(Groupbox.Elements, Dropdown)
                return Dropdown
            end
            
            -- ═══════════════════════════════════════════════
            -- LABEL
            -- ═══════════════════════════════════════════════
            function Groupbox:AddLabel(labelText)
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = labelText or "Label",
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = GroupContent
                })
                
                function Label:Set(text)
                    LabelFrame.Text = text
                end
                
                table.insert(Groupbox.Elements, Label)
                return Label
            end
            
            -- ═══════════════════════════════════════════════
            -- DIVIDER
            -- ═══════════════════════════════════════════════
            function Groupbox:AddDivider()
                local Divider = Create("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = Theme.GroupBorder,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    ZIndex = 5,
                    Parent = GroupContent
                })
                return Divider
            end
            
            -- ═══════════════════════════════════════════════
            -- BUTTON
            -- ═══════════════════════════════════════════════
            function Groupbox:AddButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                local text = buttonConfig.Text or "Button"
                local callback = buttonConfig.Callback or function() end
                
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = text,
                    BackgroundColor3 = Theme.DropdownBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    AutoButtonColor = false,
                    ZIndex = 6,
                    Parent = GroupContent
                })
                
                Create("UIStroke", {
                    Color = Theme.DropdownBorder,
                    Thickness = 1,
                    Parent = ButtonFrame
                })
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.1)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.DropdownBackground}, 0.1)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    callback()
                    -- Flash effect
                    ButtonFrame.BackgroundColor3 = Theme.Accent
                    task.delay(0.1, function()
                        Tween(ButtonFrame, {BackgroundColor3 = Theme.DropdownBackground}, 0.2)
                    end)
                end)
                
                table.insert(Groupbox.Elements, Button)
                return Button
            end
            
            -- ═══════════════════════════════════════════════
            -- KEYBIND
            -- ═══════════════════════════════════════════════
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
                    Size = UDim2.new(1, 0, 0, 15),
                    ZIndex = 5,
                    Parent = GroupContent
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.DropdownBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 45, 0, 14),
                    Font = Theme.Font,
                    Text = default ~= Enum.KeyCode.Unknown and default.Name or "...",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    AutoButtonColor = false,
                    ZIndex = 6,
                    Parent = KeybindFrame
                })
                
                Create("UIStroke", {
                    Color = Theme.DropdownBorder,
                    Thickness = 1,
                    Parent = KeybindButton
                })
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                    KeybindButton.TextColor3 = Theme.Accent
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then
                                Keybind.Value = Enum.KeyCode.Unknown
                                KeybindButton.Text = "..."
                            else
                                Keybind.Value = input.KeyCode
                                KeybindButton.Text = input.KeyCode.Name
                            end
                            Keybind.Listening = false
                            KeybindButton.TextColor3 = Theme.TextDark
                            changedCallback(Keybind.Value)
                        end
                    elseif not processed and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Keybind.Value then
                            callback(Keybind.Value)
                        end
                    end
                end)
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key ~= Enum.KeyCode.Unknown and key.Name or "..."
                end
                
                table.insert(Groupbox.Elements, Keybind)
                return Keybind
            end
            
            -- ═══════════════════════════════════════════════
            -- TEXTBOX
            -- ═══════════════════════════════════════════════
            function Groupbox:AddTextbox(textConfig)
                textConfig = textConfig or {}
                local text = textConfig.Text or "Textbox"
                local placeholder = textConfig.Placeholder or ""
                local default = textConfig.Default or ""
                local callback = textConfig.Callback or function() end
                
                local Textbox = {Value = default}
                
                local TextboxFrame = Create("Frame", {
                    Name = text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                    ZIndex = 5,
                    Parent = GroupContent
                })
                
                local TextboxLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = TextboxFrame
                })
                
                local TextboxInput = Create("TextBox", {
                    Name = "Input",
                    BackgroundColor3 = Theme.DropdownBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 16),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Theme.Font,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDark,
                    Text = default,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 6,
                    Parent = TextboxFrame
                })
                
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = TextboxInput
                })
                
                local inputStroke = Create("UIStroke", {
                    Color = Theme.DropdownBorder,
                    Thickness = 1,
                    Parent = TextboxInput
                })
                
                TextboxInput.Focused:Connect(function()
                    Tween(inputStroke, {Color = Theme.Accent}, 0.1)
                end)
                
                TextboxInput.FocusLost:Connect(function()
                    Tween(inputStroke, {Color = Theme.DropdownBorder}, 0.1)
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
            
            table.insert(Tab.Groupboxes, Groupbox)
            UpdateGroupSize()
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
    
    -- Utility functions
    function Window:SetAccent(color)
        Theme.Accent = color
        Theme.CheckboxEnabled = color
        Theme.SliderFill = color
        AccentLine.BackgroundColor3 = color
    end
    
    function Window:Toggle()
        Window.Visible = not Window.Visible
        ScreenGui.Enabled = Window.Visible
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return Library
