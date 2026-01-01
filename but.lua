-- Gamesense UI Library v2 for Roblox
-- Authentic recreation with rainbow bar and green accents
-- Author: Gamesense UI Remake
-- Version: 2.0

local Gamesense = {
    Name = "Gamesense UI Library v2",
    Version = "2.0",
    Tabs = {},
    ActiveTab = nil,
    UI = nil,
    MainFrame = nil,
    TabButtons = {},
    Components = {},
    Initialized = false,
    RainbowBar = nil,
    RainbowGradient = nil
}

-- Authentic Gamesense color scheme
local Colors = {
    Background = Color3.fromRGB(10, 10, 10),
    Secondary = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(0, 255, 0),        -- Gamesense green
    AccentHover = Color3.fromRGB(0, 200, 0),   -- Darker green
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(30, 30, 30),
    ToggleOn = Color3.fromRGB(0, 255, 0),      -- Green
    ToggleOff = Color3.fromRGB(60, 60, 60),
    SliderFill = Color3.fromRGB(0, 255, 0),    -- Green
    SliderBackground = Color3.fromRGB(40, 40, 40),
    ButtonHover = Color3.fromRGB(30, 30, 30),
    ButtonClick = Color3.fromRGB(45, 45, 45),
    Rainbow = {
        Color3.fromRGB(255, 0, 0),     -- Red
        Color3.fromRGB(255, 127, 0),   -- Orange
        Color3.fromRGB(255, 255, 0),   -- Yellow
        Color3.fromRGB(0, 255, 0),     -- Green
        Color3.fromRGB(0, 0, 255),     -- Blue
        Color3.fromRGB(75, 0, 130),    -- Indigo
        Color3.fromRGB(148, 0, 211)    -- Violet
    }
}

-- Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Utility functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(obj, properties, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create rainbow gradient
local function CreateRainbowGradient(parent)
    local gradient = Create("UIGradient", {
        Parent = parent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.Rainbow[1]),
            ColorSequenceKeypoint.new(0.17, Colors.Rainbow[2]),
            ColorSequenceKeypoint.new(0.33, Colors.Rainbow[3]),
            ColorSequenceKeypoint.new(0.5, Colors.Rainbow[4]),
            ColorSequenceKeypoint.new(0.67, Colors.Rainbow[5]),
            ColorSequenceKeypoint.new(0.83, Colors.Rainbow[6]),
            ColorSequenceKeypoint.new(1, Colors.Rainbow[7])
        })
    })
    
    -- Animate rainbow effect
    local offset = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if gradient.Parent then
            offset = (offset + deltaTime * 0.5) % 1
            gradient.Offset = Vector2.new(offset, 0)
        else
            connection:Disconnect()
        end
    end)
    
    return gradient
end

-- Main UI Creation
function Gamesense:Init()
    if self.Initialized then return end

    -- Create ScreenGui
    self.UI = Create("ScreenGui", {
        Name = "GamesenseUIv2",
        Parent = game:GetService("CoreGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Create Main Frame
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.UI,
        Size = UDim2.new(0, 650, 0, 450),
        Position = UDim2.new(0.5, -325, 0.5, -225),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    -- Add corner radius
    local corner = Create("UICorner", {
        Parent = self.MainFrame,
        CornerRadius = UDim.new(0, 4)
    })

    -- Rainbow Bar at top (authentic Gamesense feature)
    self.RainbowBar = Create("Frame", {
        Name = "RainbowBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })

    self.RainbowGradient = CreateRainbowGradient(self.RainbowBar)

    -- Add stroke for border
    local stroke = Create("UIStroke", {
        Parent = self.MainFrame,
        Color = Colors.Border,
        Thickness = 1
    })

    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0
    })

    -- Title Label (gamesense text)
    local titleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = titleBar,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "gamesense",
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Tab Frame (Left side)
    local tabFrame = Create("Frame", {
        Name = "TabFrame",
        Parent = self.MainFrame,
        Size = UDim2.new(0, 130, 1, -31),
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0
    })

    -- Content Frame (Right side)
    local contentFrame = Create("Frame", {
        Name = "ContentFrame",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -130, 1, -31),
        Position = UDim2.new(0, 130, 0, 31),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })

    -- Tab Container (for layout)
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = tabFrame,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1
    })

    -- Content Container
    self.ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = contentFrame,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1
    })

    -- UIListLayout for tabs
    self.TabLayout = Create("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Vertical
    })

    -- Make draggable
    MakeDraggable(titleBar)

    self.Initialized = true
end

-- Tab Creation
function Gamesense:CreateTab(name)
    if not self.Initialized then
        self:Init()
    end

    local tab = {
        Name = name,
        Components = {},
        Frame = nil,
        Button = nil
    }

    -- Create Tab Button
    tab.Button = Create("TextButton", {
        Name = name .. "Tab",
        Parent = self.TabContainer,
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Colors.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Code,
        LayoutOrder = #self.Tabs + 1
    })

    local tabCorner = Create("UICorner", {
        Parent = tab.Button,
        CornerRadius = UDim.new(0, 3)
    })

    -- Create Content Frame for this tab
    tab.Frame = Create("Frame", {
        Name = name .. "Frame",
        Parent = self.ContentContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })

    -- UIListLayout for components
    tab.ComponentLayout = Create("UIListLayout", {
        Parent = tab.Frame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        FillDirection = Enum.FillDirection.Vertical
    })

    -- Tab button functionality
    tab.Button.MouseButton1Click:Connect(function()
        self:SetActiveTab(tab)
    end)

    -- Hover effects
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, {BackgroundColor3 = Colors.ButtonHover}, 0.2)
        end
    end)

    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, {BackgroundColor3 = Colors.Secondary}, 0.2)
        end
    end)

    table.insert(self.Tabs, tab)

    -- Set first tab as active
    if #self.Tabs == 1 then
        self:SetActiveTab(tab)
    end

    return tab
end

-- Set Active Tab
function Gamesense:SetActiveTab(tab)
    if self.ActiveTab == tab then return end

    -- Deactivate current tab
    if self.ActiveTab then
        self.ActiveTab.Frame.Visible = false
        Tween(self.ActiveTab.Button, {BackgroundColor3 = Colors.Secondary, TextColor3 = Colors.TextSecondary}, 0.2)
    end

    -- Activate new tab
    self.ActiveTab = tab
    tab.Frame.Visible = true
    Tween(tab.Button, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.Text}, 0.2)
end

-- Button Component
function Gamesense:CreateButton(tab, text, callback)
    callback = callback or function() end

    local button = Create("TextButton", {
        Name = text .. "Button",
        Parent = tab.Frame,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        LayoutOrder = #tab.Components + 1
    })

    local buttonCorner = Create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 3)
    })

    button.MouseButton1Click:Connect(callback)

    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = Colors.ButtonHover}, 0.2)
    end)

    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = Colors.Secondary}, 0.2)
    end)

    button.MouseButton1Down:Connect(function()
        Tween(button, {BackgroundColor3 = Colors.ButtonClick}, 0.1)
    end)

    button.MouseButton1Up:Connect(function()
        Tween(button, {BackgroundColor3 = Colors.ButtonHover}, 0.1)
    end)

    table.insert(tab.Components, button)
    return button
end

-- Toggle Component (Green style for ESP)
function Gamesense:CreateToggle(tab, text, default, callback)
    callback = callback or function() end
    default = default or false

    local toggleFrame = Create("Frame", {
        Name = text .. "Toggle",
        Parent = tab.Frame,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = #tab.Components + 1
    })

    local toggleCorner = Create("UICorner", {
        Parent = toggleFrame,
        CornerRadius = UDim.new(0, 3)
    })

    local label = Create("TextLabel", {
        Name = "Label",
        Parent = toggleFrame,
        Size = UDim2.new(1, -55, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local toggleButton = Create("Frame", {
        Name = "ToggleButton",
        Parent = toggleFrame,
        Size = UDim2.new(0, 45, 0, 18),
        Position = UDim2.new(1, -50, 0.5, -9),
        BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff,
        BorderSizePixel = 0
    })

    local toggleButtonCorner = Create("UICorner", {
        Parent = toggleButton,
        CornerRadius = UDim.new(0, 9)
    })

    local toggleIndicator = Create("Frame", {
        Name = "Indicator",
        Parent = toggleButton,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, default and 28 or 2, 0, 2),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0
    })

    local indicatorCorner = Create("UICorner", {
        Parent = toggleIndicator,
        CornerRadius = UDim.new(0, 7)
    })

    local state = default

    toggleFrame.MouseButton1Click:Connect(function()
        state = not state
        
        Tween(toggleButton, {BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
        Tween(toggleIndicator, {Position = UDim2.new(0, state and 28 or 2, 0, 2)}, 0.2)
        
        callback(state)
    end)

    table.insert(tab.Components, toggleFrame)
    return {Frame = toggleFrame, State = state, SetState = function(self, newState) 
        state = newState
        Tween(toggleButton, {BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
        Tween(toggleIndicator, {Position = UDim2.new(0, state and 28 or 2, 0, 2)}, 0.2)
    end}
end

-- Slider Component
function Gamesense:CreateSlider(tab, text, min, max, default, callback)
    callback = callback or function() end
    min = min or 0
    max = max or 100
    default = default or min

    local sliderFrame = Create("Frame", {
        Name = text .. "Slider",
        Parent = tab.Frame,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = #tab.Components + 1
    })

    local sliderCorner = Create("UICorner", {
        Parent = sliderFrame,
        CornerRadius = UDim.new(0, 3)
    })

    local label = Create("TextLabel", {
        Name = "Label",
        Parent = sliderFrame,
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 10, 0, 4),
        BackgroundTransparency = 1,
        Text = text .. ": " .. tostring(default),
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local sliderTrack = Create("Frame", {
        Name = "SliderTrack",
        Parent = sliderFrame,
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 22),
        BackgroundColor3 = Colors.SliderBackground,
        BorderSizePixel = 0
    })

    local trackCorner = Create("UICorner", {
        Parent = sliderTrack,
        CornerRadius = UDim.new(0, 3)
    })

    local sliderFill = Create("Frame", {
        Name = "SliderFill",
        Parent = sliderTrack,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.SliderFill,
        BorderSizePixel = 0
    })

    local fillCorner = Create("UICorner", {
        Parent = sliderFill,
        CornerRadius = UDim.new(0, 3)
    })

    local sliderHandle = Create("Frame", {
        Name = "SliderHandle",
        Parent = sliderTrack,
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new((default - min) / (max - min), -5, 0, -2),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0
    })

    local handleCorner = Create("UICorner", {
        Parent = sliderHandle,
        CornerRadius = UDim.new(0, 5)
    })

    local value = default
    local dragging = false

    local function UpdateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local percent = (value - min) / (max - min)
        
        label.Text = text .. ": " .. tostring(math.floor(value))
        Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        Tween(sliderHandle, {Position = UDim2.new(percent, -5, 0, -2)}, 0.1)
        
        callback(value)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UIS:GetMouseLocation().X
            local trackPos = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            local newValue = min + (max - min) * percent
            
            UpdateSlider(newValue)
        end
    end)

    table.insert(tab.Components, sliderFrame)
    return {Frame = sliderFrame, Value = value, SetValue = function(self, newValue) UpdateSlider(newValue) end}
end

-- Keybind Component
function Gamesense:CreateKeybind(tab, text, default, callback)
    callback = callback or function() end
    default = default or Enum.KeyCode.Unknown

    local keybindFrame = Create("Frame", {
        Name = text .. "Keybind",
        Parent = tab.Frame,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = #tab.Components + 1
    })

    local keybindCorner = Create("UICorner", {
        Parent = keybindFrame,
        CornerRadius = UDim.new(0, 3)
    })

    local label = Create("TextLabel", {
        Name = "Label",
        Parent = keybindFrame,
        Size = UDim2.new(1, -85, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local keybindButton = Create("TextButton", {
        Name = "KeybindButton",
        Parent = keybindFrame,
        Size = UDim2.new(0, 70, 0, 18),
        Position = UDim2.new(1, -75, 0.5, -9),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Text = default.Name ~= "Unknown" and default.Name or "NONE",
        TextColor3 = Colors.Text,
        TextSize = 11,
        Font = Enum.Font.Code
    })

    local keybindButtonCorner = Create("UICorner", {
        Parent = keybindButton,
        CornerRadius = UDim.new(0, 3)
    })

    local currentKey = default
    local listening = false

    keybindButton.MouseButton1Click:Connect(function()
        listening = true
        keybindButton.Text = "..."
        Tween(keybindButton, {BackgroundColor3 = Colors.Accent}, 0.2)
    end)

    UIS.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindButton.Text = currentKey.Name
                listening = false
                Tween(keybindButton, {BackgroundColor3 = Colors.Background}, 0.2)
                callback(currentKey)
            end
        end
    end)

    table.insert(tab.Components, keybindFrame)
    return {Frame = keybindFrame, Key = currentKey}
end

-- Show/Hide UI
function Gamesense:SetVisible(visible)
    if self.MainFrame then
        self.MainFrame.Visible = visible
    end
end

function Gamesense:Toggle()
    if self.MainFrame then
        self:SetVisible(not self.MainFrame.Visible)
    end
end

-- Destroy UI
function Gamesense:Destroy()
    if self.UI then
        self.UI:Destroy()
        self.Initialized = false
        self.Tabs = {}
        self.ActiveTab = nil
    end
end

return Gamesense
