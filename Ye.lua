-- skeetui.lua | Gamesense-style UI Library for Roblox
-- https://github.com/YOURUSERNAME/YOURREPO/blob/main/skeetui.lua

local SkeetUI = {}
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Config
local GUI_NAME = "GamesenseUI"
local THEME = {
    Background = Color3.fromRGB(24, 24, 24),
    TabBackground = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Code,
    TextSize = 14
}

-- Utility
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- Main GUI
function SkeetUI:CreateWindow(title)
    local ScreenGui = create("ScreenGui", {
        Name = GUI_NAME,
        Parent = game:GetService("CoreGui"),
        ResetOnSpawn = false
    })

    local Main = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })

    local TopBar = create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = THEME.TabBackground,
        BorderSizePixel = 0,
        Parent = Main
    })

    local Title = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = title or "gamesense",
        TextColor3 = THEME.Text,
        BackgroundTransparency = 1,
        Font = THEME.Font,
        TextSize = THEME.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local TabHolder = create("Frame", {
        Name = "TabHolder",
        Size = UDim2.new(0, 150, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = THEME.TabBackground,
        BorderSizePixel = 0,
        Parent = Main
    })

    local Container = create("Frame", {
        Name = "Container",
        Size = UDim2.new(1, -150, 1, -30),
        Position = UDim2.new(0, 150, 0, 30),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local window = {
        ScreenGui = ScreenGui,
        Main = Main,
        TabHolder = TabHolder,
        Container = Container,
        Tabs = {},
        CurrentTab = nil
    }

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return window
end

function SkeetUI:CreateTab(window, name)
    local TabButton = create("TextButton", {
        Name = name,
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, #window.Tabs * 35),
        Text = name,
        TextColor3 = THEME.Text,
        BackgroundColor3 = THEME.TabBackground,
        BorderSizePixel = 0,
        Font = THEME.Font,
        TextSize = THEME.TextSize,
        Parent = window.TabHolder
    })

    local TabFrame = create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Visible = false,
        Parent = window.Container
    })

    local UIListLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = TabFrame
    })

    table.insert(window.Tabs, {Button = TabButton, Frame = TabFrame})

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in ipairs(window.Tabs) do
            tab.Frame.Visible = false
            tab.Button.BackgroundColor3 = THEME.TabBackground
        end
        TabFrame.Visible = true
        TabButton.BackgroundColor3 = THEME.Accent
    end)

    if not window.CurrentTab then
        TabFrame.Visible = true
        TabButton.BackgroundColor3 = THEME.Accent
        window.CurrentTab = TabFrame
    end

    return TabFrame
end

function SkeetUI:CreateToggle(tab, text, callback)
    local Toggle = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 25),
        Text = text .. " [OFF]",
        TextColor3 = THEME.Text,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Font = THEME.Font,
        TextSize = THEME.TextSize,
        Parent = tab
    })

    local enabled = false
    Toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        Toggle.Text = text .. (enabled and " [ON]" or " [OFF]")
        if callback then callback(enabled) end
    end)

    return Toggle
end

function SkeetUI:CreateButton(tab, text, callback)
    local Button = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 25),
        Text = text,
        TextColor3 = THEME.Text,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Font = THEME.Font,
        TextSize = THEME.TextSize,
        Parent = tab
    })

    Button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Button
end

return SkeetUI
