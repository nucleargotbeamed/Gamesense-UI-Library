--[[
Skeet/Gamesense Style UI Library for Roblox
Recreation of the CS:GO/CS2 cheat menu aesthetic
]]

local SkeetLib = {}
SkeetLib.__index = SkeetLib

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Colors (Exact Skeet/Gamesense colors)
local Theme = {
-- Main colors
WindowBackground = Color3.fromRGB(24, 24, 24),
WindowBorder = Color3.fromRGB(40, 40, 40),
TitleBar = Color3.fromRGB(30, 30, 30),

-- Tab colors
TabBackground = Color3.fromRGB(35, 35, 35),
TabActive = Color3.fromRGB(45, 45, 45),
TabHover = Color3.fromRGB(40, 40, 40),
TabBorder = Color3.fromRGB(50, 50, 50),

-- Section/Groupbox colors
GroupboxBackground = Color3.fromRGB(32, 32, 32),
GroupboxBorder = Color3.fromRGB(45, 45, 45),
GroupboxTitle = Color3.fromRGB(180, 180, 180),

-- Element colors
ElementBackground = Color3.fromRGB(40, 40, 40),
ElementBackgroundHover = Color3.fromRGB(45, 45, 45),
ElementBorder = Color3.fromRGB(55, 55, 55),

-- Text colors
TextPrimary = Color3.fromRGB(200, 200, 200),
TextSecondary = Color3.fromRGB(140, 140, 140),
TextDisabled = Color3.fromRGB(80, 80, 80),

-- Accent colors
Accent = Color3.fromRGB(114, 137, 218), -- Skeet blue
AccentDark = Color3.fromRGB(90, 110, 180),
AccentLight = Color3.fromRGB(130, 155, 235),

-- Toggle colors
ToggleEnabled = Color3.fromRGB(114, 137, 218),
ToggleDisabled = Color3.fromRGB(50, 50, 50),
ToggleBorder = Color3.fromRGB(60, 60, 60),

-- Slider colors
SliderBackground = Color3.fromRGB(30, 30, 30),
SliderFill = Color3.fromRGB(114, 137, 218),

-- Dropdown colors
DropdownBackground = Color3.fromRGB(35, 35, 35),
DropdownHover = Color3.fromRGB(45, 45, 45),

-- Rainbow gradient colors for top bar
RainbowColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(139, 0, 255)
}
}

-- Utility Functions
local function Create(instanceType, properties)
local instance = Instance.new(instanceType)
for prop, value in pairs(properties) do
if prop ~= "Parent" then
instance[prop] = value
end
end
if properties.Parent then
instance.Parent = properties.Parent
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
CornerRadius = UDim.new(0, radius or 3),
Parent = instance
})
end

local function AddStroke(instance, color, thickness, transparency)
return Create("UIStroke", {
Color = color or Theme.ElementBorder,
Thickness = thickness or 1,
Transparency = transparency or 0,
Parent = instance
})
end

local function AddPadding(instance, padding)
return Create("UIPadding", {
PaddingTop = UDim.new(0, padding),
PaddingBottom = UDim.new(0, padding),
PaddingLeft = UDim.new(0, padding),
PaddingRight = UDim.new(0, padding),
Parent = instance
})
end

local function Ripple(button)
local ripple = Create("Frame", {
Name = "Ripple",
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
BackgroundTransparency = 0.85,
Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X, 0, Mouse.Y - button.AbsolutePosition.Y),
Size = UDim2.new(0, 0, 0, 0),
AnchorPoint = Vector2.new(0.5, 0.5),
Parent = button
})
AddCorner(ripple, 100)

local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)

task.delay(0.5, function()
    ripple:Destroy()
end)
end

-- Main Library
function SkeetLib:CreateWindow(config)
config = config or {}
local windowName = config.Name or "Skeet"
local windowSize = config.Size or UDim2.new(0, 610, 0, 460)



local Window = {}
Window.Tabs = {}
Window.ActiveTab = nil

-- Create ScreenGui
local ScreenGui = Create("ScreenGui", {
    Name = "SkeetUI_" .. windowName,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Try to parent to CoreGui, fallback to PlayerGui
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- Main Window Frame
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    BackgroundColor3 = Theme.WindowBackground,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = windowSize,
    Parent = ScreenGui
})
AddCorner(MainFrame, 4)
AddStroke(MainFrame, Theme.WindowBorder, 1)

-- Rainbow gradient bar at top
local RainbowBar = Create("Frame", {
    Name = "RainbowBar",
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 2),
    Parent = MainFrame
})

local RainbowGradient = Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 127, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(139, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }),
    Parent = RainbowBar
})

-- Animate rainbow
task.spawn(function()
    while ScreenGui.Parent do
        for i = 0, 1, 0.01 do
            RainbowGradient.Offset = Vector2.new(i, 0)
            task.wait(0.05)
        end
    end
end)

-- Title Bar
local TitleBar = Create("Frame", {
    Name = "TitleBar",
    BackgroundColor3 = Theme.TitleBar,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 2),
    Size = UDim2.new(1, 0, 0, 26),
    Parent = MainFrame
})

local TitleText = Create("TextLabel", {
    Name = "TitleText",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 0),
    Size = UDim2.new(0, 200, 1, 0),
    Font = Enum.Font.Code,
    Text = windowName,
    TextColor3 = Theme.TextPrimary,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

-- Close Button
local CloseButton = Create("TextButton", {
    Name = "CloseButton",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -25, 0, 0),
    Size = UDim2.new(0, 25, 1, 0),
    Font = Enum.Font.Code,
    Text = "×",
    TextColor3 = Theme.TextSecondary,
    TextSize = 18,
    Parent = TitleBar
})

CloseButton.MouseEnter:Connect(function()
    Tween(CloseButton, {TextColor3 = Color3.fromRGB(255, 100, 100)}, 0.1)
end)

CloseButton.MouseLeave:Connect(function()
    Tween(CloseButton, {TextColor3 = Theme.TextSecondary}, 0.1)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinimizeButton = Create("TextButton", {
    Name = "MinimizeButton",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -50, 0, 0),
    Size = UDim2.new(0, 25, 1, 0),
    Font = Enum.Font.Code,
    Text = "−",
    TextColor3 = Theme.TextSecondary,
    TextSize = 18,
    Parent = TitleBar
})

MinimizeButton.MouseEnter:Connect(function()
    Tween(MinimizeButton, {TextColor3 = Theme.Accent}, 0.1)
end)

MinimizeButton.MouseLeave:Connect(function()
    Tween(MinimizeButton, {TextColor3 = Theme.TextSecondary}, 0.1)
end)

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Tween(MainFrame, {Size = UDim2.new(0, windowSize.X.Offset, 0, 28)}, 0.2)
    else
        Tween(MainFrame, {Size = windowSize}, 0.2)
    end
end)

-- Make window draggable
local dragging = false
local dragStart = nil
local startPos = nil

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
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Tab Container
local TabContainer = Create("Frame", {
    Name = "TabContainer",
    BackgroundColor3 = Theme.TabBackground,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 28),
    Size = UDim2.new(1, 0, 0, 28),
    Parent = MainFrame
})
AddStroke(TabContainer, Theme.TabBorder, 1)

local TabHolder = Create("Frame", {
    Name = "TabHolder",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 5, 0, 0),
    Size = UDim2.new(1, -10, 1, 0),
    Parent = TabContainer
})

local TabLayout = Create("UIListLayout", {
    FildirChe = Enum.finegirection.Horizontal,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Parent = TabHolder
})

-- Sub Tab Container
local SubTabContainer = Create("Frame", {
    Name = "SubTabContainer",
    BackgroundColor3 = Theme.TabBackground,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 56),
    Size = UDim2.new(1, 0, 0, 24),
    Parent = MainFrame
})
AddStroke(SubTabContainer, Theme.TabBorder, 1)

local SubTabHolder = Create("Frame", {
    Name = "SubTabHolder",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 5, 0, 0),
    Size = UDim2.new(1, -10, 1, 0),
    Parent = SubTabContainer
})

local SubTabLayout = Create("UIListLayout", {
    FildirChe = Enum.finegirection.Horizontal,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Parent = SubTabHolder
})

-- Content Container
local ContentContainer = Create("Frame", {
    Name = "ContentContainer",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 85),
    Size = UDim2.new(1, -16, 1, -93),
    ClipsDescendants = true,
    Parent = MainFrame
})

-- Tab Creation Function
function Window:CreateTab(tabConfig)
    tabConfig = tabConfig or {}
    local tabName = tabConfig.Name or "Tab"
    local tabIcon = tabConfig.Icon or nil
    
    local Tab = {}
    Tab.SubTabs = {}
    Tab.ActiveSubTab = nil
    
    -- Tab Button
    local TabButton = Create("TextButton", {
        Name = tabName .. "Tab",
        BackgroundColor3 = Theme.TabActive,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 70, 0, 22),
        Font = Enum.Font.Code,
        Text = tabName,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        AutoButtonColor = false,
        Parent = TabHolder
    })
    AddCorner(TabButton, 3)
    
    -- Tab Content Page
    Local Tabpage = Create("Frame", {
        Name = tabName .. "Page",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = ContentContainer
    })
    
    -- Sub Tab Holder for this tab
    local ThisSubTabHolder = Create("Frame", {
        Name = tabName .. "SubTabs",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = SubTabHolder
    })
    
    local ThisSubTabLayout = Create("UIListLayout", {
        FildirChe = Enum.finegirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = ThisSubTabHolder
    })
    
    local function SelectTab()
        -- Deselect all tabs
        for _, existingTab in pairs(Window.Tabs) do
            existingTab.Button.BackgroundTransparency = 1
            existingTab.Button.TextColor3 = Theme.TextSecondary
            existingTab.Page.Visible = false
            existingTab.SubTabHolder.Visible = false
        end
        
        -- Select this tab
        TabButton.BackgroundTransparency = 0
        TabButton.TextColor3 = Theme.TextPrimary
        TabPage.Visible = true
        ThisSubTabHolder.Visible = true
        Window.ActiveTab = Tab
        
        -- Select first subtab if available
        if Tab.SubTabs[1] then
            Tab.SubTabs[1].Select()
        end
    end
    
    TabButton.MouseButton1Click:Connect(SelectTab)
    
    TabButton.MouseEnter:Connect(function()
        if Window.ActiveTab ~= Tab then
            Tween(TabButton, {BackgroundTransparency = 0.5}, 0.1)
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if Window.ActiveTab ~= Tab then
            Tween(TabButton, {BackgroundTransparency = 1}, 0.1)
        end
    end)
    
    -- SubTab Creation Function
    function Tab:CreateSubTab(subTabConfig)
        subTabConfig = subTabConfig or {}
        local subTabName = subTabConfig.Name or "SubTab"
        
        local SubTab = {}
        SubTab.Columns = {}
        
        -- SubTab Button
        local SubTabButton = Create("TextButton", {
            Name = subTabName .. "SubTab",
            BackgroundColor3 = Theme.TabActive,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 60, 0, 18),
            Font = Enum.Font.Code,
            Text = subTabName,
            TextColor3 = Theme.TextSecondary,
            TextSize = 10,
            AutoButtonColor = false,
            Parent = ThisSubTabHolder
        })
        AddCorner(SubTabButton, 2)
        
        -- SubTab Content Page
        local SubTabPage = Create("Frame", {
            Name = subTabName .. "SubPage",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = TabPage
        })
        
        -- Column Layout
        local ColumnLayout = Create("UIListLayout", {
            FildirChe = Enum.finegirection.Horizontal,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = SubTabPage
        })
        
        local function SelectSubTab()
            -- Deselect all subtabs
            for _, existingSubTab in pairs(Tab.SubTabs) do
                existingSubTab.Button.BackgroundTransparency = 1
                existingSubTab.Button.TextColor3 = Theme.TextSecondary
                existingSubTab.Page.Visible = false
            end
            
            -- Select this subtab
            SubTabButton.BackgroundTransparency = 0
            SubTabButton.TextColor3 = Theme.TextPrimary
            SubTabPage.Visible = true
            Tab.ActiveSubTab = SubTab
        end
        
        SubTabButton.MouseButton1Click:Connect(SelectSubTab)
        
        SubTabButton.MouseEnter:Connect(function()
            if Tab.ActiveSubTab ~= SubTab then
                Tween(SubTabButton, {BackgroundTransparency = 0.5}, 0.1)
            end
        end)
        
        SubTabButton.MouseLeave:Connect(function()
            if Tab.ActiveSubTab ~= SubTab then
                Tween(SubTabButton, {BackgroundTransparency = 1}, 0.1)
            end
        end)
        
        -- Column Creation Function
        function SubTab:CreateColumn(columnConfig)
            columnConfig = columnConfig or {}
            
            local Column = {}
            Column.Groupboxes = {}
            
            local ColumnFrame = Create("Frame", {
                Name = "Column",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -4, 1, 0),
                Parent = SubTabPage
            })
            
            local ColumnScrollFrame = Create("ScrollingFrame", {
                Name = "ColumnScroll",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = ColumnFrame
            })
            
            local ColumnScrollLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = ColumnScrollFrame
            })
            
            ColumnScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ColumnScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ColumnScrollLayout.AbsoluteContentSize.Y + 5)
            end)
            
            -- Groupbox Creation Function
            function Column:CreateGroupbox(groupboxConfig)
                groupboxConfig = groupboxConfig or {}
                local groupboxName = groupboxConfig.Name or "Groupbox"
                
                local Groupbox = {}
                
                local GroupboxFrame = Create("Frame", {
                    Name = groupboxName .. "Groupbox",
                    BackgroundColor3 = Theme.GroupboxBackground,
                    Size = UDim2.new(1, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = ColumnScrollFrame
                })
                AddCorner(GroupboxFrame, 3)
                AddStroke(GroupboxFrame, Theme.GroupboxBorder, 1)
                
                local GroupboxTitle = Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 24),
                    Font = Enum.Font.Code,
                    Text = groupboxName,
                    TextColor3 = Theme.GroupboxTitle,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = GroupboxFrame
                })
                
                local GroupboxContent = Create("Frame", {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = GroupboxFrame
                })
                
                local ContentLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = GroupboxContent
                })
                
                local ContentPadding = Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    Parent = GroupboxContent
                })
                
                -- Toggle/Checkbox
                function Groupbox:AddToggle(toggleConfig)
                    toggleConfig = toggleConfig or {}
                    local toggleName = toggleConfig.Name or "Toggle"
                    local default = toggleConfig.Default or false
                    local callback = toggleConfig.Callback or function() end
                    
                    local Toggle = {Value = default}
                    
                    local ToggleFrame = Create("Frame", {
                        Name = toggleName .. "Toggle",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        Parent = GroupboxContent
                    })
                    
                    local ToggleBox = Create("Frame", {
                        Name = "Box",
                        BackgroundColor3 = default and Theme.ToggleEnabled or Theme.ToggleDisabled,
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Parent = ToggleFrame
                    })
                    AddCorner(ToggleBox, 2)
                    AddStroke(ToggleBox, Theme.ToggleBorder, 1)
                    
                    local ToggleLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 18, 0, 0),
                        Size = UDim2.new(1, -18, 1, 0),
                        Font = Enum.Font.Code,
                        Text = toggleName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ToggleFrame
                    })
                    
                    local ToggleButton = Create("TextButton", {
                        Name = "Button",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        Parent = ToggleFrame
                    })
                    
                    local function UpdateToggle()
                        Tween(ToggleBox, {BackgroundColor3 = Toggle.Value and Theme.ToggleEnabled or Theme.ToggleDisabled}, 0.15)
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
                    
                    UpdateToggle()
                    return Toggle
                end
                
                -- Slider
                function Groupbox:AddSlider(sliderConfig)
                    sliderConfig = sliderConfig or {}
                    local sliderName = sliderConfig.Name or "Slider"
                    local min = sliderConfig.Min or 0
                    local max = sliderConfig.Max or 100
                    local default = sliderConfig.Default or min
                    local increment = sliderConfig.Increment or 1
                    local suffix = sliderConfig.Suffix or ""
                    local callback = sliderConfig.Callback or function() end
                    
                    local Slider = {Value = default}
                    
                    local SliderFrame = Create("Frame", {
                        Name = sliderName .. "Slider",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 32),
                        Parent = GroupboxContent
                    })
                    
                    local SliderLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 14),
                        Font = Enum.Font.Code,
                        Text = sliderName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = SliderFrame
                    })
                    
                    local SliderValue = Create("TextLabel", {
                        Name = "Value",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 14),
                        Font = Enum.Font.Code,
                        Text = tostring(default) .. suffix,
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = SliderFrame
                    })
                    
                    local SliderBack = Create("Frame", {
                        Name = "Back",
                        BackgroundColor3 = Theme.SliderBackground,
                        Position = UDim2.new(0, 0, 0, 18),
                        Size = UDim2.new(1, 0, 0, 10),
                        Parent = SliderFrame
                    })
                    AddCorner(SliderBack, 3)
                    AddStroke(SliderBack, Theme.ElementBorder, 1)
                    
                    local SliderFill = Create("Frame", {
                        Name = "Fill",
                        BackgroundColor3 = Theme.SliderFill,
                        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                        Parent = SliderBack
                    })
                    AddCorner(SliderFill, 3)
                    
                    local SliderButton = Create("TextButton", {
                        Name = "Button",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        Parent = SliderBack
                    })
                    
                    local sliding = false
                    
                    local function UpdateSlider(input)
                        local pos = UDim2.new(math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1), 0, 1, 0)
                        SliderFill.Size = pos
                        
                        local value = math.floor((min + (pos.X.Scale * (max - min))) / increment + 0.5) * increment
                        value = math.clamp(value, min, max)
                        
                        Slider.Value = value
                        SliderValue.Text = tostring(value) .. suffix
                        callback(value)
                    end
                    
                    SliderButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            UpdateSlider(input)
                        end
                    end)
                    
                    SliderButton.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(input)
                        end
                    end)
                    
                    function Slider:Set(value)
                        Slider.Value = math.clamp(value, min, max)
                        SliderFill.Size = UDim2.new((Slider.Value - min) / (max - min), 0, 1, 0)
                        SliderValue.Text = tostring(Slider.Value) .. suffix
                        callback(Slider.Value)
                    end
                    
                    return Slider
                end
                
                -- Dropdown
                function Groupbox:AddDropdown(dropdownConfig)
                    dropdownConfig = dropdownConfig or {}
                    local dropdownName = dropdownConfig.Name or "Dropdown"
                    local options = dropdownConfig.Options or {}
                    local default = dropdownConfig.Default or (options[1] or "")
                    local multiSelect = dropdownConfig.MultiSelect or false
                    local callback = dropdownConfig.Callback or function() end
                    
                    local Dropdown = {Value = multiSelect and {} or default, Open = false}
                    if multiSelect and type(default) == "table" then
                        Dropdown.Value = default
                    end
                    
                    local DropdownFrame = Create("Frame", {
                        Name = dropdownName .. "Dropdown",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 38),
                        ClipsDescendants = false,
                        Parent = GroupboxContent
                    })
                    
                    local DropdownLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 14),
                        Font = Enum.Font.Code,
                        Text = dropdownName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = DropdownFrame
                    })
                    
                    local DropdownButton = Create("TextButton", {
                        Name = "Button",
                        BackgroundColor3 = Theme.DropdownBackground,
                        Position = UDim2.new(0, 0, 0, 16),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.Code,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        Parent = DropdownFrame
                    })
                    AddCorner(DropdownButton, 3)
                    AddStroke(DropdownButton, Theme.ElementBorder, 1)
                    AddPadding(DropdownButton, 5)
                    
                    local DropdownArrow = Create("TextLabel", {
                        Name = "Arrow",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -15, 0, 0),
                        Size = UDim2.new(0, 10, 1, 0),
                        Font = Enum.Font.Code,
                        Text = "▼",
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 8,
                        Parent = DropdownButton
                    })
                    
                    local DropdownList = Create("Frame", {
                        Name = "List",
                        BackgroundColor3 = Theme.DropdownBackground,
                        Position = UDim2.new(0, 0, 0, 38),
                        Size = UDim2.new(1, 0, 0, 0),
                        ClipsDescendants = true,
                        Visible = false,
                        ZIndex = 10,
                        Parent = DropdownFrame
                    })
                    AddCorner(DropdownList, 3)
                    AddStroke(DropdownList, Theme.ElementBorder, 1)
                    
                    local DropdownListLayout = Create("UIListLayout", {
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = DropdownList
                    })
                    
                    local DropdownListPadding = Create("UIPadding", {
                        PaddingTop = UDim.new(0, 3),
                        PaddingBottom = UDim.new(0, 3),
                        PaddingLeft = UDim.new(0, 3),
                        PaddingRight = UDim.new(0, 3),
                        Parent = DropdownList
                    })
                    
                    local function GetDisplayText()
                        if multiSelect then
                            local selected = {}
                            for opt, enabled in pairs(Dropdown.Value) do
                                if enabled then
                                    table.insert(selected, opt)
                                end
                            end
                            return #selected > 0 and table.concat(selected, ", ") or "None"
                        else
                            return Dropdown.Value
                        end
                    end
                    
                    local function UpdateDropdown()
                        DropdownButton.Text = GetDisplayText()
                    end
                    
                    local function CreateOption(optionName)
                        local OptionButton = Create("TextButton", {
                            Name = optionName,
                            BackgroundColor3 = Theme.DropdownHover,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 18),
                            Font = Enum.Font.Code,
                            Text = optionName,
                            TextColor3 = Theme.TextPrimary,
                            TextSize = 10,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            ZIndex = 11,
                            Parent = DropdownList
                        })
                        AddCorner(OptionButton, 2)
                        AddPadding(OptionButton, 5)
                        
                        if multiSelect then
                            local Checkmark = Create("TextLabel", {
                                Name = "Checkmark",
                                BackgroundTransparency = 1,
                                Position = UDim2.new(1, -15, 0, 0),
                                Size = UDim2.new(0, 10, 1, 0),
                                Font = Enum.Font.Code,
                                Text = Dropdown.Value[optionName] and "✓" or "",
                                TextColor3 = Theme.Accent,
                                TextSize = 10,
                                ZIndex = 11,
                                Parent = OptionButton
                            })
                            
                            OptionButton.MouseButton1Click:Connect(function()
                                Dropdown.Value[optionName] = not Dropdown.Value[optionName]
                                Checkmark.Text = Dropdown.Value[optionName] and "✓" or ""
                                UpdateDropdown()
                                callback(Dropdown.Value)
                            end)
                        else
                            OptionButton.MouseButton1Click:Connect(function()
                                Dropdown.Value = optionName
                                Dropdown.Open = false
                                DropdownList.Visible = false
                                Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                                DropdownArrow.Text = "▼"
                                UpdateDropdown()
                                callback(Dropdown.Value)
                            end)
                        end
                        
                        OptionButton.MouseEnter:Connect(function()
                            Tween(OptionButton, {BackgroundTransparency = 0}, 0.1)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            Tween(OptionButton, {BackgroundTransparency = 1}, 0.1)
                        end)
                    end
                    
                    for _, option in ipairs(options) do
                        CreateOption(option)
                        if multiSelect then
                            Dropdown.Value[option] = Dropdown.Value[option] or false
                        end
                    end
                    
                    DropdownButton.MouseButton1Click:Connect(function()
                        Dropdown.Open = not Dropdown.Open
                        DropdownList.Visible = true
                        
                        local listSize = #options * 20 + 6
                        if Dropdown.Open then
                            Tween(DropdownList, {Size = UDim2.new(1, 0, 0, math.min(listSize, 150))}, 0.15)
                            DropdownArrow.Text = "▲"
                        else
                            Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                            DropdownArrow.Text = "▼"
                            task.delay(0.15, function()
                                if not Dropdown.Open then
                                    DropdownList.Visible = false
                                end
                            end)
                        end
                    end)
                    
                    DropdownButton.MouseEnter:Connect(function()
                        Tween(DropdownButton, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.1)
                    end)
                    
                    DropdownButton.MouseLeave:Connect(function()
                        Tween(DropdownButton, {BackgroundColor3 = Theme.DropdownBackground}, 0.1)
                    end)
                    
                    function Dropdown:Set(value)
                        if multiSelect then
                            Dropdown.Value = value
                        else
                            Dropdown.Value = value
                        end
                        UpdateDropdown()
                        callback(Dropdown.Value)
                    end
                    
                    function Dropdown:Refresh(newOptions)
                        for _, child in pairs(DropdownList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        options = newOptions
                        for _, option in ipairs(options) do
                            CreateOption(option)
                            if multiSelect then
                                Dropdown.Value[option] = Dropdown.Value[option] or false
                            end
                        end
                    end
                    
                    UpdateDropdown()
                    return Dropdown
                end
                
                -- Button
                function Groupbox:AddButton(buttonConfig)
                    buttonConfig = buttonConfig or {}
                    local buttonName = buttonConfig.Name or "Button"
                    local callback = buttonConfig.Callback or function() end
                    
                    local Button = {}
                    
                    local ButtonFrame = Create("TextButton", {
                        Name = buttonName .. "Button",
                        BackgroundColor3 = Theme.ElementBackground,
                        Size = UDim2.new(1, 0, 0, 24),
                        Font = Enum.Font.Code,
                        Text = buttonName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        AutoButtonColor = false,
                        Parent = GroupboxContent
                    })
                    AddCorner(ButtonFrame, 3)
                    AddStroke(ButtonFrame, Theme.ElementBorder, 1)
                    
                    ButtonFrame.MouseButton1Click:Connect(function()
                        Ripple(ButtonFrame)
                        callback()
                    end)
                    
                    ButtonFrame.MouseEnter:Connect(function()
                        Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.1)
                    end)
                    
                    ButtonFrame.MouseLeave:Connect(function()
                        Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.1)
                    end)
                    
                    return Button
                end
                
                -- Textbox/Input
                function Groupbox:AddInput(inputConfig)
                    inputConfig = inputConfig or {}
                    local inputName = inputConfig.Name or "Input"
                    local default = inputConfig.Default or ""
                    local placeholder = inputConfig.Placeholder or "Enter ..."
                    local numeric = inputConfig.Numeric or false
                    local callback = inputConfig.Callback or function() end
                    
                    local Input = {Value = default}
                    
                    local InputFrame = Create("Frame", {
                        Name = inputName .. "Input",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 38),
                        Parent = GroupboxContent
                    })
                    
                    local InputLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 14),
                        Font = Enum.Font.Code,
                        Text = inputName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = InputFrame
                    })
                    
                    local InputBox = Create("TextBox", {
                        Name = "Box",
                        BackgroundColor3 = Theme.ElementBackground,
                        Position = UDim2.new(0, 0, 0, 16),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.Code,
                        PlaceholderText = placeholder,
                        PlaceholderColor3 = Theme.TextDisabled,
                        Text = default,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = false,
                        Parent = InputFrame
                    })
                    AddCorner(InputBox, 3)
                    AddStroke(InputBox, Theme.ElementBorder, 1)
                    AddPadding(InputBox, 5)
                    
                    InputBox.FocusLost:Connect(function()
                        local  = InputBox.Text
                        if numeric then
                             = tonumber() or 0
                            InputBox.Text = tostring()
                        end
                        Input.Value = 
                        callback()
                    end)
                    
                    InputBox.Focused:Connect(function()
                        Tween(InputBox, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.1)
                    end)
                    
                    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        if numeric then
                            InputBox.Text = InputBox.Text:gsub("[^%d%.%-]", "")
                        end
                    end)
                    
                    function Input:Set(value)
                        Input.Value = value
                        InputBox.Text = tostring(value)
                        callback(value)
                    end
                    
                    return Input
                end
                
                -- Color Picker
                function Groupbox:AddColorPicker(colorConfig)
                    colorConfig = colorConfig or {}
                    local colorName = colorConfig.Name or "Color"
                    local default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
                    local callback = colorConfig.Callback or function() end
                    
                    local ColorPicker = {Value = default, Open = false}
                    
                    local ColorFrame = Create("Frame", {
                        Name = colorName .. "Color",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        Parent = GroupboxContent
                    })
                    
                    local ColorLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        Font = Enum.Font.Code,
                        Text = colorName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ColorFrame
                    })
                    
                    local ColorDisplay = Create("TextButton", {
                        Name = "Display",
                        BackgroundColor3 = default,
                        Position = UDim2.new(1, -24, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(0, 24, 0, 12),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = ColorFrame
                    })
                    AddCorner(ColorDisplay, 2)
                    AddStroke(ColorDisplay, Theme.ElementBorder, 1)
                    
                    -- Color Picker Panel
                    local ColorPanel = Create("Frame", {
                        Name = "Panel",
                        BackgroundColor3 = Theme.GroupboxBackground,
                        Position = UDim2.new(0, 0, 0, 20),
                        Size = UDim2.new(1, 0, 0, 0),
                        ClipsDescendants = true,
                        Visible = false,
                        ZIndex = 15,
                        Parent = ColorFrame
                    })
                    AddCorner(ColorPanel, 3)
                    AddStroke(ColorPanel, Theme.ElementBorder, 1)
                    
                    -- Main Color Picker (Saturation/Value)
                    local ColorMain = Create("ImageButton", {
                        Name = "Main",
                        BackgroundColor3 = Color3.fromHSV(1, 1, 1),
                        Position = UDim2.new(0, 5, 0, 5),
                        Size = UDim2.new(1, -30, 0, 100),
                        AutoButtonColor = false,
                        ZIndex = 16,
                        Parent = ColorPanel
                    })
                    AddCorner(ColorMain, 3)
                    
                    local ColorMainGradient = Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                        }),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Parent = ColorMain
                    })
                    
                    local ColorMainOverlay = Create("Frame", {
                        Name = "Overlay",
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 16,
                        Parent = ColorMain
                    })
                    AddCorner(ColorMainOverlay, 3)
                    
                    local ColorMainOverlayGradient = Create("UIGradient", {
                        Rotation = 90,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0)
                        }),
                        Parent = ColorMainOverlay
                    })
                    
                    local ColorMainCursor = Create("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0, 8, 0, 8),
                        ZIndex = 17,
                        Parent = ColorMain
                    })
                    AddCorner(ColorMainCursor, 100)
                    AddStroke(ColorMainCursor, Color3.fromRGB(0, 0, 0), 1)
                    
                    -- Hue Slider
                    local HueSlider = Create("ImageButton", {
                        Name = "Hue",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Position = UDim2.new(1, -20, 0, 5),
                        Size = UDim2.new(0, 15, 0, 100),
                        AutoButtonColor = false,
                        ZIndex = 16,
                        Parent = ColorPanel
                    })
                    AddCorner(HueSlider, 3)
                    
                    local HueGradient = Create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        }),
                        Parent = HueSlider
                    })
                    
                    local HueCursor = Create("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(1, 4, 0, 4),
                        ZIndex = 17,
                        Parent = HueSlider
                    })
                    AddCorner(HueCursor, 2)
                    AddStroke(HueCursor, Color3.fromRGB(0, 0, 0), 1)
                    
                    local H, S, V = default:ToHSV()
                    
                    local function UpdateColor()
                        ColorPicker.Value = Color3.fromHSV(H, S, V)
                        ColorDisplay.BackgroundColor3 = ColorPicker.Value
                        ColorMain.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                        
                        ColorMainCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        HueCursor.Position = UDim2.new(0.5, 0, H, 0)
                        
                        callback(ColorPicker.Value)
                    end
                    
                    local mainDragging = false
                    local hueDragging = false
                    
                    ColorMain.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            mainDragging = true
                        end
                    end)
                    
                    ColorMain.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            mainDragging = false
                        end
                    end)
                    
                    HueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            hueDragging = true
                        end
                    end)
                    
                    HueSlider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            hueDragging = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if mainDragging then
                                S = math.clamp((input.Position.X - ColorMain.AbsolutePosition.X) / ColorMain.AbsoluteSize.X, 0, 1)
                                V = 1 - math.clamp((input.Position.Y - ColorMain.AbsolutePosition.Y) / ColorMain.AbsoluteSize.Y, 0, 1)
                                UpdateColor()
                            elseif hueDragging then
                                H = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                                UpdateColor()
                            end
                        end
                    end)
                    
                    ColorDisplay.MouseButton1Click:Connect(function()
                        ColorPicker.Open = not ColorPicker.Open
                        ColorPanel.Visible = true
                        
                        if ColorPicker.Open then
                            Tween(ColorPanel, {Size = UDim2.new(1, 0, 0, 115)}, 0.15)
                            DropdownFrame.Size = UDim2.new(1, 0, 0, 135)
                        else
                            Tween(ColorPanel, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                            task.delay(0.15, function()
                                if not ColorPicker.Open then
                                    ColorPanel.Visible = false
                                end
                            end)
                            ColorFrame.Size = UDim2.new(1, 0, 0, 18)
                        end
                    end)
                    
                    function ColorPicker:Set(color)
                        H, S, V = color:ToHSV()
                        UpdateColor()
                    end
                    
                    UpdateColor()
                    return ColorPicker
                end
                
                -- Keybind
                function Groupbox:AddKeybind(keybindConfig)
                    keybindConfig = keybindConfig or {}
                    local keybindName = keybindConfig.Name or "Keybind"
                    local default = keybindConfig.Default or Enum.KeyCode.Unknown
                    local callback = keybindConfig.Callback or function() end
                    local changedCallback = keybindConfig.ChangedCallback or function() end
                    
                    local Keybind = {Value = default, Listening = false}
                    
                    local KeybindFrame = Create("Frame", {
                        Name = keybindName .. "Keybind",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        Parent = GroupboxContent
                    })
                    
                    local KeybindLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, -60, 1, 0),
                        Font = Enum.Font.Code,
                        Text = keybindName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = KeybindFrame
                    })
                    
                    local KeybindButton = Create("TextButton", {
                        Name = "Button",
                        BackgroundColor3 = Theme.ElementBackground,
                        Position = UDim2.new(1, -55, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(0, 55, 0, 16),
                        Font = Enum.Font.Code,
                        Text = default == Enum.KeyCode.Unknown and "None" or default.Name,
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 9,
                        AutoButtonColor = false,
                        Parent = KeybindFrame
                    })
                    AddCorner(KeybindButton, 2)
                    AddStroke(KeybindButton, Theme.ElementBorder, 1)
                    
                    KeybindButton.MouseButton1Click:Connect(function()
                        Keybind.Listening = true
                        KeybindButton.Text = "..."
                        KeybindButton.TextColor3 = Theme.Accent
                    end)
                    
                    UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if Keybind.Listening then
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                Keybind.Value = input.KeyCode
                                KeybindButton.Text = input.KeyCode.Name
                                KeybindButton.TextColor3 = Theme.TextSecondary
                                Keybind.Listening = false
                                changedCallback(Keybind.Value)
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                                -- Cancel
                                KeybindButton.Text = Keybind.Value == Enum.KeyCode.Unknown and "None" or Keybind.Value.Name
                                KeybindButton.TextColor3 = Theme.TextSecondary
                                Keybind.Listening = false
                            end
                        else
                            if input.KeyCode == Keybind.Value and not gameProcessed then
                                callback(true)
                            end
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.KeyCode == Keybind.Value then
                            callback(false)
                        end
                    end)
                    
                    function Keybind:Set(key)
                        Keybind.Value = key
                        KeybindButton.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
                        changedCallback(key)
                    end
                    
                    return Keybind
                end
                
                -- Label
                function Groupbox:AddLabel(labelConfig)
                    labelConfig = labelConfig or {}
                    local labelText = labelConfig.Text or "Label"
                    
                    local Label = {}
                    
                    local LabelFrame = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 14),
                        Font = Enum.Font.Code,
                        Text = labelText,
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = GroupboxContent
                    })
                    
                    function Label:Set()
                        LabelFrame.Text = 
                    end
                    
                    return Label
                end
                
                -- Divider
                function Groupbox:AddDivider()
                    local DividerFrame = Create("Frame", {
                        Name = "Divider",
                        BackgroundColor3 = Theme.GroupboxBorder,
                        Size = UDim2.new(1, 0, 0, 1),
                        Parent = GroupboxContent
                    })
                    
                    return DividerFrame
                end
                
                table.insert(Column.Groupboxes, Groupbox)
                return Groupbox
            end
            
            table.insert(SubTab.Columns, Column)
            return Column
        end
        
        SubTab.Button = SubTabButton
        SubTab.Page = SubTabPage
        SubTab.Select = SelectSubTab
        
        table.insert(Tab.SubTabs, SubTab)
        
        -- Auto-select first subtab
        if #Tab.SubTabs == 1 then
            SelectSubTab()
        end
        
        return SubTab
    end
    
    Tab.Button = TabButton
    Tab.Page = TabPage
    Tab.SubTabHolder = ThisSubTabHolder
    Tab.Select = SelectTab
    
    table.insert(Window.Tabs, Tab)
    
    -- Auto-select first tab
    if #Window.Tabs == 1 then
        SelectTab()
    end
    
    return Tab
end

-- Toggle visibility with keybind
function Window:SetToggleKey(key)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == key then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

-- Notification system
function Window:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 3
    
    local NotifyFrame = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.WindowBackground,
        Position = UDim2.new(1, 10, 1, -60),
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 250, 0, 50),
        Parent = ScreenGui
    })
    AddCorner(NotifyFrame, 4)
    AddStroke(NotifyFrame, Theme.Accent, 1)
    
    local NotifyTitle = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 16),
        Font = Enum.Font.Code,
        Text = title,
        TextColor3 = Theme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifyFrame
    })
    
    local NotifyMessage = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 22),
        Size = UDim2.new(1, -20, 0, 25),
        Font = Enum.Font.Code,
        Text = message,
        TextColor3 = Theme.TextPrimary,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = NotifyFrame
    })
    
    Tween(NotifyFrame, {Position = UDim2.new(1, -10, 1, -60)}, 0.3)
    
    task.delay(duration, function()
        Tween(NotifyFrame, {Position = UDim2.new(1, 10, 1, -60)}, 0.3)
        task.wait(0.3)
        NotifyFrame:Destroy()
    end)
end

return Window
end

return SkeetLib
