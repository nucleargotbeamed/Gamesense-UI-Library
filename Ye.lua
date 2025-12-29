local SenseUI = {}
SenseUI.__index = SenseUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SenseUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

if syn then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    Secondary = Color3.fromRGB(25, 25, 25),
    Tertiary = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 200, 100),
    AccentDark = Color3.fromRGB(0, 150, 75),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(175, 175, 175),
    TextDarker = Color3.fromRGB(100, 100, 100),
    Disabled = Color3.fromRGB(60, 60, 60),
    Border = Color3.fromRGB(45, 45, 45),
    Shadow = Color3.fromRGB(0, 0, 0)
}

local Icons = {
    player = "rbxassetid://6034509993",
    crosshair = "rbxassetid://6034509993",
    visuals = "rbxassetid://6035067836",
    settings = "rbxassetid://6031280882",
    world = "rbxassetid://6034973478",
    misc = "rbxassetid://6031229048"
}

local ConfigFolder = "SenseCFGS"

local function EnsureConfigFolder()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

local function GetConfigs()
    EnsureConfigFolder()
    local configs = {}
    local files = listfiles(ConfigFolder)
    for _, file in pairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end
    return configs
end

local function Create(class, properties)
    local instance = Instance.new(class)
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
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = parent
    })
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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
end

function SenseUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "SenseUI"
    local size = config.Size or UDim2.new(0, 650, 0, 450)

    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Visible = true
    Window.Flags = {}
    Window.Elements = {}
    Window.ToggleKey = Enum.KeyCode.RightShift
    Window.ToggleKeyConnection = nil

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Theme.Background,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 8)

    local MainShadow = Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = MainFrame
    })

    local RGBBar = Create("Frame", {
        Name = "RGBBar",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    AddCorner(RGBBar, 8)

    local RGBGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }),
        Parent = RGBBar
    })

    spawn(function()
        local offset = 0
        while MainFrame and MainFrame.Parent do
            offset = (offset + 0.005) % 1
            RGBGradient.Offset = Vector2.new(offset, 0)
            RunService.RenderStepped:Wait()
        end
    end)

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local CloseButton = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -35, 0, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.TextDark,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Parent = TopBar
    })

    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {TextColor3 = Color3.fromRGB(255, 100, 100)}, 0.15)
    end)

    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {TextColor3 = Theme.TextDark}, 0.15)
    end)

    CloseButton.MouseButton1Click:Connect(function()
        Window.Visible = false
        MainFrame.Visible = false
    end)

    MakeDraggable(MainFrame, TopBar)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 50, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    AddCorner(Sidebar, 0)

    local SidebarList = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = Sidebar
    })

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        Parent = Sidebar
    })

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -55, 1, -43),
        Position = UDim2.new(0, 55, 0, 43),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = MainFrame
    })

    local ContentScroll = Create("ScrollingFrame", {
        Name = "ContentScroll",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = ContentContainer
    })

    local ContentLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        Parent = ContentScroll
    })

    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)

    local function SetupToggleKey()
        if Window.ToggleKeyConnection then
            Window.ToggleKeyConnection:Disconnect()
        end
        Window.ToggleKeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == Window.ToggleKey then
                Window.Visible = not Window.Visible
                MainFrame.Visible = Window.Visible
            end
        end)
    end

    SetupToggleKey()

    function Window:SetToggleKey(key)
        Window.ToggleKey = key
        SetupToggleKey()
    end

    function Window:SaveConfig(name)
        EnsureConfigFolder()
        local data = {}
        for flag, element in pairs(Window.Elements) do
            if element.Type == "Toggle" then
                data[flag] = {Type = "Toggle", Value = element.Value}
            elseif element.Type == "Slider" then
                data[flag] = {Type = "Slider", Value = element.Value}
            elseif element.Type == "Dropdown" then
                data[flag] = {Type = "Dropdown", Value = element.Value}
            elseif element.Type == "ColorPicker" then
                data[flag] = {Type = "ColorPicker", Value = {element.Value.R * 255, element.Value.G * 255, element.Value.B * 255}}
            elseif element.Type == "Keybind" then
                data[flag] = {Type = "Keybind", Value = element.Value.Name}
            elseif element.Type == "Textbox" then
                data[flag] = {Type = "Textbox", Value = element.Value}
            end
        end
        local json = HttpService:JSONEncode(data)
        writefile(ConfigFolder .. "/" .. name .. ".json", json)
    end

    function Window:LoadConfig(name)
        EnsureConfigFolder()
        local path = ConfigFolder .. "/" .. name .. ".json"
        if isfile(path) then
            local json = readfile(path)
            local data = HttpService:JSONDecode(json)
            for flag, info in pairs(data) do
                local element = Window.Elements[flag]
                if element then
                    if info.Type == "Toggle" then
                        element:Set(info.Value)
                    elseif info.Type == "Slider" then
                        element:Set(info.Value)
                    elseif info.Type == "Dropdown" then
                        element:Set(info.Value)
                    elseif info.Type == "ColorPicker" then
                        element:Set(Color3.fromRGB(info.Value[1], info.Value[2], info.Value[3]))
                    elseif info.Type == "Keybind" then
                        element:Set(Enum.KeyCode[info.Value])
                    elseif info.Type == "Textbox" then
                        element:Set(info.Value)
                    end
                end
            end
            return true
        end
        return false
    end

    function Window:DeleteConfig(name)
        EnsureConfigFolder()
        local path = ConfigFolder .. "/" .. name .. ".json"
        if isfile(path) then
            delfile(path)
            return true
        end
        return false
    end

    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Sections = {}
        Tab.Name = name

        local TabButton = Create("ImageButton", {
            Name = name,
            Size = UDim2.new(0, 36, 0, 36),
            BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = 1,
            Image = Icons[icon] or Icons.player,
            ImageColor3 = Theme.TextDarker,
            Parent = Sidebar
        })
        AddCorner(TabButton, 8)

        local TabContent = Create("Frame", {
            Name = name .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentScroll
        })

        local ColumnContainer = Create("Frame", {
            Name = "Columns",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = TabContent
        })

        local LeftColumn = Create("Frame", {
            Name = "Left",
            Size = UDim2.new(0.5, -5, 1, 0),
            BackgroundTransparency = 1,
            Parent = ColumnContainer
        })

        local LeftLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = LeftColumn
        })

        local RightColumn = Create("Frame", {
            Name = "Right",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            Parent = ColumnContainer
        })

        local RightLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = RightColumn
        })

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.5, ImageColor3 = Theme.TextDark}, 0.15)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1, ImageColor3 = Theme.TextDarker}, 0.15)
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                local oldButton = Sidebar:FindFirstChild(Window.CurrentTab.Name)
                if oldButton then
                    Tween(oldButton, {BackgroundTransparency = 1, ImageColor3 = Theme.TextDarker}, 0.15)
                end
                local oldContent = ContentScroll:FindFirstChild(Window.CurrentTab.Name .. "Content")
                if oldContent then
                    oldContent.Visible = false
                end
            end

            Window.CurrentTab = Tab
            Tween(TabButton, {BackgroundTransparency = 0, ImageColor3 = Theme.Accent}, 0.15)
            TabContent.Visible = true
        end)

        if #Window.Tabs == 0 then
            Window.CurrentTab = Tab
            TabButton.BackgroundTransparency = 0
            TabButton.ImageColor3 = Theme.Accent
            TabContent.Visible = true
        end

        function Tab:CreateSection(name, side)
            local Section = {}
            Section.Elements = {}

            local column = side == "right" and RightColumn or LeftColumn

            local SectionFrame = Create("Frame", {
                Name = name,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Theme.Secondary,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            AddCorner(SectionFrame, 6)
            AddStroke(SectionFrame, Theme.Border, 1)

            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })

            local SectionContent = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })

            local ContentList = Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = SectionContent
            })

            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 10),
                Parent = SectionContent
            })

            local function UpdateColumnSize()
                local leftSize = 0
                for _, child in pairs(LeftColumn:GetChildren()) do
                    if child:IsA("Frame") then
                        leftSize = leftSize + child.AbsoluteSize.Y + 10
                    end
                end

                local rightSize = 0
                for _, child in pairs(RightColumn:GetChildren()) do
                    if child:IsA("Frame") then
                        rightSize = rightSize + child.AbsoluteSize.Y + 10
                    end
                end

                ContentScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(leftSize, rightSize) + 20)
            end

            SectionContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateColumnSize)

            function Section:CreateToggle(config)
                local Toggle = {}
                config = config or {}
                local name = config.Name or "Toggle"
                local default = config.Default or false
                local callback = config.Callback or function() end
                local flag = config.Flag

                Toggle.Value = default
                Toggle.Type = "Toggle"

                local ToggleFrame = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })

                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })

                local ToggleButton = Create("Frame", {
                    Name = "Button",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    BackgroundColor3 = Theme.Disabled,
                    Parent = ToggleFrame
                })
                AddCorner(ToggleButton, 10)

                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = Theme.TextDarker,
                    Parent = ToggleButton
                })
                AddCorner(ToggleCircle, 8)

                local ToggleClick = Create("TextButton", {
                    Name = "Click",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = ToggleFrame
                })

                local function UpdateToggle(noCallback)
                    if Toggle.Value then
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Accent}, 0.2)
                        Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}, 0.2)
                        Tween(ToggleLabel, {TextColor3 = Theme.Text}, 0.2)
                    else
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Disabled}, 0.2)
                        Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDarker}, 0.2)
                        Tween(ToggleLabel, {TextColor3 = Theme.TextDark}, 0.2)
                    end
                    if not noCallback then
                        callback(Toggle.Value)
                    end
                end

                ToggleClick.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                end)

                if default then
                    UpdateToggle()
                end

                function Toggle:Set(value, noCallback)
                    Toggle.Value = value
                    UpdateToggle(noCallback)
                end

                if flag then
                    Window.Elements[flag] = Toggle
                end

                table.insert(Section.Elements, Toggle)
                return Toggle
            end

            function Section:CreateSlider(config)
                local Slider = {}
                config = config or {}
                local name = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local suffix = config.Suffix or ""
                local callback = config.Callback or function() end
                local flag = config.Flag

                Slider.Value = default
                Slider.Type = "Slider"

                local SliderFrame = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })

                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -50, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })

                local SliderValue = Create("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })

                local SliderTrack = Create("Frame", {
                    Name = "Track",
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = Theme.Tertiary,
                    Parent = SliderFrame
                })
                AddCorner(SliderTrack, 3)

                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    Parent = SliderTrack
                })
                AddCorner(SliderFill, 3)

                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
                    BackgroundColor3 = Theme.Text,
                    Parent = SliderTrack
                })
                AddCorner(SliderKnob, 7)

                local SliderInput = Create("TextButton", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = SliderFrame
                })

                local dragging = false

                local function UpdateSlider(input, noCallback)
                    local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    Slider.Value = value

                    Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                    Tween(SliderKnob, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.05)
                    SliderValue.Text = tostring(value) .. suffix

                    if not noCallback then
                        callback(value)
                    end
                end

                SliderInput.MouseButton1Down:Connect(function()
                    dragging = true
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

                SliderInput.MouseButton1Click:Connect(function()
                    local input = {Position = Vector3.new(Mouse.X, Mouse.Y, 0)}
                    UpdateSlider(input)
                end)

                function Slider:Set(value, noCallback)
                    Slider.Value = value
                    local pos = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                    SliderValue.Text = tostring(value) .. suffix
                    if not noCallback then
                        callback(value)
                    end
                end

                if flag then
                    Window.Elements[flag] = Slider
                end

                table.insert(Section.Elements, Slider)
                return Slider
            end

            function Section:CreateDropdown(config)
                local Dropdown = {}
                config = config or {}
                local name = config.Name or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or options[1]
                local callback = config.Callback or function() end
                local flag = config.Flag

                Dropdown.Value = default
                Dropdown.Open = false
                Dropdown.Type = "Dropdown"

                local DropdownFrame = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = SectionContent
                })

                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })

                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.Tertiary,
                    Text = "",
                    Parent = DropdownFrame
                })
                AddCorner(DropdownButton, 4)
                AddStroke(DropdownButton, Theme.Border, 1)

                local DropdownText = Create("TextLabel", {
                    Name = "Text",
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = default or "Select...",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownButton
                })

                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownButton
                })

                local DropdownList = Create("Frame", {
                    Name = "List",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 52),
                    BackgroundColor3 = Theme.Tertiary,
                    ClipsDescendants = true,
                    Parent = DropdownFrame
                })
                AddCorner(DropdownList, 4)
                AddStroke(DropdownList, Theme.Border, 1)

                local ListLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = DropdownList
                })

                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    Parent = DropdownList
                })

                local function ClearOptions()
                    for _, child in pairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                end

                local function CreateOption(option)
                    local OptionButton = Create("TextButton", {
                        Name = option,
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = Theme.Secondary,
                        BackgroundTransparency = 1,
                        Text = option,
                        TextColor3 = Theme.TextDark,
                        TextSize = 12,
                        Font = Enum.Font.Gotham,
                        Parent = DropdownList
                    })
                    AddCorner(OptionButton, 4)

                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0, TextColor3 = Theme.Text}, 0.15)
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}, 0.15)
                    end)

                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownText.Text = option
                        Dropdown.Open = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        Tween(DropdownArrow, {Rotation = 0}, 0.2)
                        callback(option)
                    end)
                end

                for _, option in pairs(options) do
                    CreateOption(option)
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    if Dropdown.Open then
                        local listHeight = #options * 26 + 8
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 54 + listHeight)}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, listHeight)}, 0.2)
                        Tween(DropdownArrow, {Rotation = 180}, 0.2)
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        Tween(DropdownArrow, {Rotation = 0}, 0.2)
                    end
                end)

                function Dropdown:Set(value, noCallback)
                    Dropdown.Value = value
                    DropdownText.Text = value
                    if not noCallback then
                        callback(value)
                    end
                end

                function Dropdown:Refresh(newOptions, keepValue)
                    options = newOptions
                    ClearOptions()
                    for _, option in pairs(options) do
                        CreateOption(option)
                    end
                    if not keepValue then
                        if #options > 0 then
                            Dropdown.Value = options[1]
                            DropdownText.Text = options[1]
                        else
                            Dropdown.Value = nil
                            DropdownText.Text = "Select..."
                        end
                    end
                end

                function Dropdown:GetOptions()
                    return options
                end

                if flag then
                    Window.Elements[flag] = Dropdown
                end

                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end

            function Section:CreateColorPicker(config)
                local ColorPicker = {}
                config = config or {}
                local name = config.Name or "Color Picker"
                local default = config.Default or Color3.fromRGB(255, 255, 255)
                local callback = config.Callback or function() end
                local flag = config.Flag

                ColorPicker.Value = default
                ColorPicker.Open = false
                ColorPicker.Type = "ColorPicker"

                local ColorFrame = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })

                local ColorLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -35, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })

                local ColorButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(0, 28, 0, 18),
                    Position = UDim2.new(1, -28, 0.5, -9),
                    BackgroundColor3 = default,
                    Text = "",
                    Parent = ColorFrame
                })
                AddCorner(ColorButton, 4)
                AddStroke(ColorButton, Theme.Border, 1)

                local ColorPopup = Create("Frame", {
                    Name = "Popup",
                    Size = UDim2.new(0, 180, 0, 150),
                    Position = UDim2.new(1, -180, 0, 28),
                    BackgroundColor3 = Theme.Secondary,
                    Visible = false,
                    ZIndex = 10,
                    Parent = ColorFrame
                })
                AddCorner(ColorPopup, 6)
                AddStroke(ColorPopup, Theme.Border, 1)

                local ColorGradient = Create("ImageLabel", {
                    Name = "Gradient",
                    Size = UDim2.new(1, -20, 0, 100),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    Image = "rbxassetid://4155801252",
                    ZIndex = 11,
                    Parent = ColorPopup
                })
                AddCorner(ColorGradient, 4)

                local ColorSelector = Create("Frame", {
                    Name = "Selector",
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(1, -10, 0, 0),
                    BackgroundColor3 = Theme.Text,
                    ZIndex = 12,
                    Parent = ColorGradient
                })
                AddCorner(ColorSelector, 5)
                AddStroke(ColorSelector, Theme.Shadow, 2)

                local HueSlider = Create("Frame", {
                    Name = "HueSlider",
                    Size = UDim2.new(1, -20, 0, 16),
                    Position = UDim2.new(0, 10, 0, 120),
                    ZIndex = 11,
                    Parent = ColorPopup
                })
                AddCorner(HueSlider, 4)

                local HueGradient = Create("UIGradient", {
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

                local HueSelector = Create("Frame", {
                    Name = "Selector",
                    Size = UDim2.new(0, 6, 1, 4),
                    Position = UDim2.new(0, -3, 0, -2),
                    BackgroundColor3 = Theme.Text,
                    ZIndex = 12,
                    Parent = HueSlider
                })
                AddCorner(HueSelector, 3)
                AddStroke(HueSelector, Theme.Shadow, 1)

                local h, s, v = Color3.toHSV(default)

                local function UpdateColor(noCallback)
                    local color = Color3.fromHSV(h, s, v)
                    ColorPicker.Value = color
                    ColorButton.BackgroundColor3 = color
                    ColorGradient.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    if not noCallback then
                        callback(color)
                    end
                end

                ColorButton.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    ColorPopup.Visible = ColorPicker.Open
                end)

                local draggingGradient = false
                local draggingHue = false

                ColorGradient.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingGradient = true
                    end
                end)

                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingGradient = false
                        draggingHue = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingGradient then
                            local relativeX = math.clamp((input.Position.X - ColorGradient.AbsolutePosition.X) / ColorGradient.AbsoluteSize.X, 0, 1)
                            local relativeY = math.clamp((input.Position.Y - ColorGradient.AbsolutePosition.Y) / ColorGradient.AbsoluteSize.Y, 0, 1)
                            s = relativeX
                            v = 1 - relativeY
                            ColorSelector.Position = UDim2.new(relativeX, -5, relativeY, -5)
                            UpdateColor()
                        elseif draggingHue then
                            local relativeX = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                            h = relativeX
                            HueSelector.Position = UDim2.new(relativeX, -3, 0, -2)
                            UpdateColor()
                        end
                    end
                end)

                function ColorPicker:Set(color, noCallback)
                    ColorPicker.Value = color
                    h, s, v = Color3.toHSV(color)
                    ColorButton.BackgroundColor3 = color
                    ColorGradient.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    ColorSelector.Position = UDim2.new(s, -5, 1 - v, -5)
                    HueSelector.Position = UDim2.new(h, -3, 0, -2)
                    if not noCallback then
                        callback(color)
                    end
                end

                if flag then
                    Window.Elements[flag] = ColorPicker
                end

                table.insert(Section.Elements, ColorPicker)
                return ColorPicker
            end

            function Section:CreateButton(config)
                local Button = {}
                config = config or {}
                local name = config.Name or "Button"
                local callback = config.Callback or function() end

                local ButtonFrame = Create("TextButton", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.Tertiary,
                    Text = name,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    Parent = SectionContent
                })
                AddCorner(ButtonFrame, 4)
                AddStroke(ButtonFrame, Theme.Border, 1)

                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.15)
                end)

                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                end)

                ButtonFrame.MouseButton1Click:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                    wait(0.1)
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                    callback()
                end)

                table.insert(Section.Elements, Button)
                return Button
            end

            function Section:CreateTextbox(config)
                local Textbox = {}
                config = config or {}
                local name = config.Name or "Textbox"
                local default = config.Default or ""
                local placeholder = config.Placeholder or "Enter text..."
                local callback = config.Callback or function() end
                local flag = config.Flag

                Textbox.Value = default
                Textbox.Type = "Textbox"

                local TextboxFrame = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })

                local TextboxLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextboxFrame
                })

                local TextboxInput = Create("TextBox", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.Tertiary,
                    Text = default,
                    PlaceholderText = placeholder,
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDarker,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    Parent = TextboxFrame
                })
                AddCorner(TextboxInput, 4)
                AddStroke(TextboxInput, Theme.Border, 1)

                TextboxInput.FocusLost:Connect(function()
                    Textbox.Value = TextboxInput.Text
                    callback(TextboxInput.Text)
                end)

                function Textbox:Set(value, noCallback)
                    Textbox.Value = value
                    TextboxInput.Text = value
                    if not noCallback then
                        callback(value)
                    end
                end

                if flag then
                    Window.Elements[flag] = Textbox
                end

                table.insert(Section.Elements, Textbox)
                return Textbox
            end

            function Section:CreateKeybind(config)
                local Keybind = {}
                config = config or {}
                local name = config.Name or "Keybind"
                local default = config.Default or Enum.KeyCode.Unknown
                local callback = config.Callback or function() end
                local flag = config.Flag
                local isUIToggle = config.UIToggle or false

                Keybind.Value = default
                Keybind.Listening = false
                Keybind.Type = "Keybind"

                local KeybindFrame = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })

                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -70, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })

                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(0, 60, 0, 22),
                    Position = UDim2.new(1, -60, 0.5, -11),
                    BackgroundColor3 = Theme.Tertiary,
                    Text = default.Name or "None",
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    Parent = KeybindFrame
                })
                AddCorner(KeybindButton, 4)
                AddStroke(KeybindButton, Theme.Border, 1)

                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                    Tween(KeybindButton, {BackgroundColor3 = Theme.Accent}, 0.15)
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            Keybind.Listening = false
                            Tween(KeybindButton, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                            if isUIToggle then
                                Window:SetToggleKey(input.KeyCode)
                            end
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                            Keybind.Listening = false
                            KeybindButton.Text = Keybind.Value.Name or "None"
                            Tween(KeybindButton, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                        end
                    elseif not processed and not isUIToggle and input.KeyCode == Keybind.Value then
                        callback(Keybind.Value)
                    end
                end)

                function Keybind:Set(key, noCallback)
                    Keybind.Value = key
                    KeybindButton.Text = key.Name
                    if isUIToggle then
                        Window:SetToggleKey(key)
                    end
                    if not noCallback then
                        callback(key)
                    end
                end

                if flag then
                    Window.Elements[flag] = Keybind
                end

                table.insert(Section.Elements, Keybind)
                return Keybind
            end

            function Section:CreateConfigSection()
                local ConfigDropdown
                local ConfigNameBox

                ConfigNameBox = Section:CreateTextbox({
                    Name = "Config Name",
                    Default = "",
                    Placeholder = "Enter config name...",
                    Callback = function() end
                })

                Section:CreateButton({
                    Name = "Save Config",
                    Callback = function()
                        local configName = ConfigNameBox.Value
                        if configName and configName ~= "" then
                            Window:SaveConfig(configName)
                            SenseUI:Notify({
                                Title = "Config Saved",
                                Message = "Configuration '" .. configName .. "' saved successfully!",
                                Duration = 3
                            })
                            if ConfigDropdown then
                                ConfigDropdown:Refresh(GetConfigs(), true)
                            end
                        else
                            SenseUI:Notify({
                                Title = "Error",
                                Message = "Please enter a config name!",
                                Duration = 3
                            })
                        end
                    end
                })

                ConfigDropdown = Section:CreateDropdown({
                    Name = "Select Config",
                    Options = GetConfigs(),
                    Default = nil,
                    Callback = function() end
                })

                Section:CreateButton({
                    Name = "Load Config",
                    Callback = function()
                        local configName = ConfigDropdown.Value
                        if configName then
                            local success = Window:LoadConfig(configName)
                            if success then
                                SenseUI:Notify({
                                    Title = "Config Loaded",
                                    Message = "Configuration '" .. configName .. "' loaded successfully!",
                                    Duration = 3
                                })
                            else
                                SenseUI:Notify({
                                    Title = "Error",
                                    Message = "Failed to load configuration!",
                                    Duration = 3
                                })
                            end
                        else
                            SenseUI:Notify({
                                Title = "Error",
                                Message = "Please select a config to load!",
                                Duration = 3
                            })
                        end
                    end
                })

                Section:CreateButton({
                    Name = "Refresh Configs",
                    Callback = function()
                        ConfigDropdown:Refresh(GetConfigs(), false)
                        SenseUI:Notify({
                            Title = "Configs Refreshed",
                            Message = "Config list has been updated!",
                            Duration = 2
                        })
                    end
                })

                Section:CreateButton({
                    Name = "Delete Config",
                    Callback = function()
                        local configName = ConfigDropdown.Value
                        if configName then
                            local success = Window:DeleteConfig(configName)
                            if success then
                                ConfigDropdown:Refresh(GetConfigs(), false)
                                SenseUI:Notify({
                                    Title = "Config Deleted",
                                    Message = "Configuration '" .. configName .. "' deleted!",
                                    Duration = 3
                                })
                            else
                                SenseUI:Notify({
                                    Title = "Error",
                                    Message = "Failed to delete configuration!",
                                    Duration = 3
                                })
                            end
                        else
                            SenseUI:Notify({
                                Title = "Error",
                                Message = "Please select a config to delete!",
                                Duration = 3
                            })
                        end
                    end
                })

                return ConfigDropdown
            end

            table.insert(Tab.Sections, Section)
            return Section
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    function Window:Destroy()
        if Window.ToggleKeyConnection then
            Window.ToggleKeyConnection:Disconnect()
        end
        ScreenGui:Destroy()
    end

    function Window:Toggle(state)
        if state == nil then
            Window.Visible = not Window.Visible
        else
            Window.Visible = state
        end
        MainFrame.Visible = Window.Visible
    end

    return Window
end

function SenseUI:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if Theme[key] then
            Theme[key] = value
        end
    end
end

function SenseUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 3

    local NotifyFrame = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 280, 0, 70),
        Position = UDim2.new(1, 300, 1, -80),
        BackgroundColor3 = Theme.Secondary,
        Parent = ScreenGui
    })
    AddCorner(NotifyFrame, 6)
    AddStroke(NotifyFrame, Theme.Border, 1)

    local NotifyAccent = Create("Frame", {
        Name = "Accent",
        Size = UDim2.new(0, 4, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = Theme.Accent,
        Parent = NotifyFrame
    })
    AddCorner(NotifyAccent, 2)

    local NotifyTitle = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -25, 0, 25),
        Position = UDim2.new(0, 20, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifyFrame
    })

    local NotifyMessage = Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -25, 0, 35),
        Position = UDim2.new(0, 20, 0, 28),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotifyFrame
    })

    Tween(NotifyFrame, {Position = UDim2.new(1, -290, 1, -80)}, 0.3, Enum.EasingStyle.Quart)

    spawn(function()
        wait(duration)
        Tween(NotifyFrame, {Position = UDim2.new(1, 300, 1, -80)}, 0.3, Enum.EasingStyle.Quart)
        wait(0.3)
        NotifyFrame:Destroy()
    end)
end

return SenseUI
