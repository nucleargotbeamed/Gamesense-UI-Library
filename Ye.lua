--[[
    Skeet/Gamesense Style UI Library for Roblox
    Complete Working Version with Z-Index Fixes
]]

local SkeetLib = {}
SkeetLib.__index = SkeetLib

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Colors (Exact Skeet/Gamesense colors)
local Theme = {
    WindowBackground = Color3.fromRGB(24, 24, 24),
    WindowBorder = Color3.fromRGB(40, 40, 40),
    TitleBar = Color3.fromRGB(30, 30, 30),
    TabBackground = Color3.fromRGB(35, 35, 35),
    TabActive = Color3.fromRGB(45, 45, 45),
    TabHover = Color3.fromRGB(40, 40, 40),
    TabBorder = Color3.fromRGB(50, 50, 50),
    GroupboxBackground = Color3.fromRGB(32, 32, 32),
    GroupboxBorder = Color3.fromRGB(45, 45, 45),
    GroupboxTitle = Color3.fromRGB(180, 180, 180),
    ElementBackground = Color3.fromRGB(40, 40, 40),
    ElementBackgroundHover = Color3.fromRGB(45, 45, 45),
    ElementBorder = Color3.fromRGB(55, 55, 55),
    TextPrimary = Color3.fromRGB(200, 200, 200),
    TextSecondary = Color3.fromRGB(140, 140, 140),
    TextDisabled = Color3.fromRGB(80, 80, 80),
    Accent = Color3.fromRGB(114, 137, 218),
    AccentDark = Color3.fromRGB(90, 110, 180),
    AccentLight = Color3.fromRGB(130, 155, 235),
    ToggleEnabled = Color3.fromRGB(114, 137, 218),
    ToggleDisabled = Color3.fromRGB(50, 50, 50),
    ToggleBorder = Color3.fromRGB(60, 60, 60),
    SliderBackground = Color3.fromRGB(30, 30, 30),
    SliderFill = Color3.fromRGB(114, 137, 218),
    DropdownBackground = Color3.fromRGB(35, 35, 35),
    DropdownHover = Color3.fromRGB(45, 45, 45),
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
    local configFolder = config.ConfigFolder or "SkeetConfigs"
    
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Flags = {} -- Store all element values
    Window.Elements = {} -- Store element references
    Window.ConfigFolder = configFolder
    
    -- Create ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "SkeetUI_" .. windowName,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    -- Dropdown Container (renders above everything)
    local DropdownContainer = Create("Frame", {
        Name = "DropdownContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100,
        Parent = ScreenGui
    })
    
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
                if not ScreenGui.Parent then break end
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
    local ContentHolder = nil -- Will be set later
    
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
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
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
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
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
    ContentHolder = ContentContainer
    
    -- Close all dropdowns when clicking elsewhere
    local activeDropdown = nil
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if activeDropdown and activeDropdown.CloseDropdown then
                    -- Check if click is outside dropdown
                    local mousePos = UserInputService:GetMouseLocation()
                    -- Small delay to let the dropdown button process first
                end
            end)
        end
    end)
    
    -- Config Functions
    function Window:SaveConfig(configName)
        local configData = {}
        
        for flagName, flagValue in pairs(Window.Flags) do
            if type(flagValue) == "table" then
                -- Handle Color3
                if flagValue.R and flagValue.G and flagValue.B then
                    configData[flagName] = {
                        Type = "Color3",
                        R = flagValue.R,
                        G = flagValue.G,
                        B = flagValue.B
                    }
                else
                    -- Handle multi-select dropdown
                    configData[flagName] = {
                        Type = "Table",
                        Value = flagValue
                    }
                end
            elseif typeof(flagValue) == "Color3" then
                configData[flagName] = {
                    Type = "Color3",
                    R = flagValue.R,
                    G = flagValue.G,
                    B = flagValue.B
                }
            elseif typeof(flagValue) == "EnumItem" then
                configData[flagName] = {
                    Type = "Enum",
                    EnumType = tostring(flagValue.EnumType),
                    Name = flagValue.Name
                }
            else
                configData[flagName] = {
                    Type = typeof(flagValue),
                    Value = flagValue
                }
            end
        end
        
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(configData)
        end)
        
        if success then
            -- Try to save using writefile (executor function)
            local saveSuccess = pcall(function()
                if not isfolder(configFolder) then
                    makefolder(configFolder)
                end
                writefile(configFolder .. "/" .. configName .. ".json", encoded)
            end)
            
            if saveSuccess then
                return true, "Config saved successfully!"
            else
                -- Fallback: copy to clipboard
                pcall(function()
                    setclipboard(encoded)
                end)
                return true, "Config copied to clipboard (file save not available)"
            end
        else
            return false, "Failed to encode config"
        end
    end
    
    function Window:LoadConfig(configName)
        local configData = nil
        
        -- Try to load from file
        local loadSuccess = pcall(function()
            if isfile(configFolder .. "/" .. configName .. ".json") then
                local content = readfile(configFolder .. "/" .. configName .. ".json")
                configData = HttpService:JSONDecode(content)
            end
        end)
        
        if not loadSuccess or not configData then
            return false, "Config not found or failed to load"
        end
        
        -- Apply config
        for flagName, flagData in pairs(configData) do
            if Window.Elements[flagName] then
                local element = Window.Elements[flagName]
                local value
                
                if flagData.Type == "Color3" then
                    value = Color3.new(flagData.R, flagData.G, flagData.B)
                elseif flagData.Type == "Enum" then
                    value = Enum[flagData.EnumType][flagData.Name]
                elseif flagData.Type == "Table" then
                    value = flagData.Value
                else
                    value = flagData.Value
                end
                
                if element.Set then
                    element:Set(value)
                end
            end
        end
        
        return true, "Config loaded successfully!"
    end
    
    function Window:GetConfigs()
        local configs = {}
        
        pcall(function()
            if isfolder(configFolder) then
                for _, file in pairs(listfiles(configFolder)) do
                    local name = file:match("([^/\\]+)%.json$")
                    if name then
                        table.insert(configs, name)
                    end
                end
            end
        end)
        
        return configs
    end
    
    function Window:DeleteConfig(configName)
        local success = pcall(function()
            if isfile(configFolder .. "/" .. configName .. ".json") then
                delfile(configFolder .. "/" .. configName .. ".json")
            end
        end)
        
        return success
    end
    
    -- Tab Creation Function
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        
        local Tab = {}
        Tab.SubTabs = {}
        Tab.ActiveSubTab = nil
        
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
        
        local TabPage = Create("Frame", {
            Name = tabName .. "Page",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = ContentContainer
        })
        
        local ThisSubTabHolder = Create("Frame", {
            Name = tabName .. "SubTabs",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = SubTabHolder
        })
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ThisSubTabHolder
        })
        
        local function SelectTab()
            for _, existingTab in pairs(Window.Tabs) do
                existingTab.Button.BackgroundTransparency = 1
                existingTab.Button.TextColor3 = Theme.TextSecondary
                existingTab.Page.Visible = false
                existingTab.SubTabHolder.Visible = false
            end
            
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = Theme.TextPrimary
            TabPage.Visible = true
            ThisSubTabHolder.Visible = true
            Window.ActiveTab = Tab
            
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
        
        function Tab:CreateSubTab(subTabConfig)
            subTabConfig = subTabConfig or {}
            local subTabName = subTabConfig.Name or "SubTab"
            
            local SubTab = {}
            SubTab.Columns = {}
            
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
            
            local SubTabPage = Create("Frame", {
                Name = subTabName .. "SubPage",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
                Parent = TabPage
            })
            
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SubTabPage
            })
            
            local function SelectSubTab()
                for _, existingSubTab in pairs(Tab.SubTabs) do
                    existingSubTab.Button.BackgroundTransparency = 1
                    existingSubTab.Button.TextColor3 = Theme.TextSecondary
                    existingSubTab.Page.Visible = false
                end
                
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
            
            function SubTab:CreateColumn()
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
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = ColumnFrame
                })
                
                local ColumnScrollLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = ColumnScrollFrame
                })
                
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
                    
                    Create("TextLabel", {
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
                    
                    Create("UIListLayout", {
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = GroupboxContent
                    })
                    
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        Parent = GroupboxContent
                    })
                    
                    -- Toggle
                    function Groupbox:AddToggle(toggleConfig)
                        toggleConfig = toggleConfig or {}
                        local toggleName = toggleConfig.Name or "Toggle"
                        local flag = toggleConfig.Flag or toggleName
                        local default = toggleConfig.Default or false
                        local callback = toggleConfig.Callback or function() end
                        
                        local Toggle = {Value = default, Type = "Toggle"}
                        Window.Flags[flag] = default
                        Window.Elements[flag] = Toggle
                        
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
                        
                        Create("TextLabel", {
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
                            Window.Flags[flag] = Toggle.Value
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
                        
                        function Toggle:Get()
                            return Toggle.Value
                        end
                        
                        UpdateToggle()
                        return Toggle
                    end
                    
                    -- Slider
                    function Groupbox:AddSlider(sliderConfig)
                        sliderConfig = sliderConfig or {}
                        local sliderName = sliderConfig.Name or "Slider"
                        local flag = sliderConfig.Flag or sliderName
                        local min = sliderConfig.Min or 0
                        local max = sliderConfig.Max or 100
                        local default = sliderConfig.Default or min
                        local increment = sliderConfig.Increment or 1
                        local suffix = sliderConfig.Suffix or ""
                        local callback = sliderConfig.Callback or function() end
                        
                        local Slider = {Value = default, Type = "Slider"}
                        Window.Flags[flag] = default
                        Window.Elements[flag] = Slider
                        
                        local SliderFrame = Create("Frame", {
                            Name = sliderName .. "Slider",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 32),
                            Parent = GroupboxContent
                        })
                        
                        Create("TextLabel", {
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
                            local percent = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                            
                            local value = math.floor((min + (percent * (max - min))) / increment + 0.5) * increment
                            value = math.clamp(value, min, max)
                            
                            -- Handle decimal precision
                            if increment < 1 then
                                local decimals = #tostring(increment):match("%.(%d+)") or 0
                                value = tonumber(string.format("%." .. decimals .. "f", value))
                            end
                            
                            Slider.Value = value
                            SliderValue.Text = tostring(value) .. suffix
                            Window.Flags[flag] = value
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
                            value = math.clamp(value, min, max)
                            Slider.Value = value
                            SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                            SliderValue.Text = tostring(value) .. suffix
                            Window.Flags[flag] = value
                            callback(value)
                        end
                        
                        function Slider:Get()
                            return Slider.Value
                        end
                        
                        return Slider
                    end
                    
                    -- Dropdown (Fixed Z-Index)
                    function Groupbox:AddDropdown(dropdownConfig)
                        dropdownConfig = dropdownConfig or {}
                        local dropdownName = dropdownConfig.Name or "Dropdown"
                        local flag = dropdownConfig.Flag or dropdownName
                        local options = dropdownConfig.Options or {}
                        local default = dropdownConfig.Default or (options[1] or "")
                        local multiSelect = dropdownConfig.MultiSelect or false
                        local callback = dropdownConfig.Callback or function() end
                        
                        local Dropdown = {Value = multiSelect and {} or default, Open = false, Type = "Dropdown"}
                        
                        if multiSelect then
                            if type(default) == "table" then
                                Dropdown.Value = default
                            else
                                for _, opt in ipairs(options) do
                                    Dropdown.Value[opt] = false
                                end
                            end
                        end
                        
                        Window.Flags[flag] = Dropdown.Value
                        Window.Elements[flag] = Dropdown
                        
                        local DropdownFrame = Create("Frame", {
                            Name = dropdownName .. "Dropdown",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 38),
                            ClipsDescendants = false,
                            Parent = GroupboxContent
                        })
                        
                        Create("TextLabel", {
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
                            ClipsDescendants = true,
                            Parent = DropdownFrame
                        })
                        AddCorner(DropdownButton, 3)
                        AddStroke(DropdownButton, Theme.ElementBorder, 1)
                        
                        local ButtonPadding = Create("UIPadding", {
                            PaddingLeft = UDim.new(0, 5),
                            PaddingRight = UDim.new(0, 5),
                            Parent = DropdownButton
                        })
                        
                        local DropdownArrow = Create("TextLabel", {
                            Name = "Arrow",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(1, -10, 0, 0),
                            Size = UDim2.new(0, 10, 1, 0),
                            Font = Enum.Font.Code,
                            Text = "▼",
                            TextColor3 = Theme.TextSecondary,
                            TextSize = 8,
                            Parent = DropdownButton
                        })
                        
                        -- Create dropdown list in the DropdownContainer for proper z-index
                        local DropdownList = Create("Frame", {
                            Name = "List",
                            BackgroundColor3 = Theme.DropdownBackground,
                            Size = UDim2.new(0, 0, 0, 0),
                            ClipsDescendants = true,
                            Visible = false,
                            ZIndex = 100,
                            Parent = DropdownContainer
                        })
                        AddCorner(DropdownList, 3)
                        AddStroke(DropdownList, Theme.ElementBorder, 1)
                        
                        local DropdownListScroll = Create("ScrollingFrame", {
                            Name = "Scroll",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            CanvasSize = UDim2.new(0, 0, 0, 0),
                            ScrollBarThickness = 2,
                            ScrollBarImageColor3 = Theme.Accent,
                            BorderSizePixel = 0,
                            ZIndex = 101,
                            Parent = DropdownList
                        })
                        
                        local DropdownListLayout = Create("UIListLayout", {
                            Padding = UDim.new(0, 2),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Parent = DropdownListScroll
                        })
                        
                        Create("UIPadding", {
                            PaddingTop = UDim.new(0, 3),
                            PaddingBottom = UDim.new(0, 3),
                            PaddingLeft = UDim.new(0, 3),
                            PaddingRight = UDim.new(0, 3),
                            Parent = DropdownListScroll
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
                                return Dropdown.Value or "None"
                            end
                        end
                        
                        local function UpdateDropdown()
                            DropdownButton.Text = GetDisplayText()
                            Window.Flags[flag] = Dropdown.Value
                        end
                        
                        local function UpdateListPosition()
                            local buttonPos = DropdownButton.AbsolutePosition
                            local buttonSize = DropdownButton.AbsoluteSize
                            DropdownList.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 2)
                            DropdownList.Size = UDim2.new(0, buttonSize.X, 0, math.min(#options * 20 + 8, 150))
                        end
                        
                        local function CloseDropdown()
                            Dropdown.Open = false
                            DropdownList.Visible = false
                            DropdownArrow.Text = "▼"
                        end
                        
                        Dropdown.CloseDropdown = CloseDropdown
                        
                        local optionButtons = {}
                        
                        local function CreateOption(optionName)
                            local OptionButton = Create("TextButton", {
                                Name = optionName,
                                BackgroundColor3 = Theme.DropdownHover,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 0, 18),
                                Font = Enum.Font.Code,
                                Text = "  " .. optionName,
                                TextColor3 = Theme.TextPrimary,
                                TextSize = 10,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                AutoButtonColor = false,
                                ZIndex = 102,
                                Parent = DropdownListScroll
                            })
                            AddCorner(OptionButton, 2)
                            
                            optionButtons[optionName] = OptionButton
                            
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
                                    ZIndex = 102,
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
                                    CloseDropdown()
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
                            if multiSelect and Dropdown.Value[option] == nil then
                                Dropdown.Value[option] = false
                            end
                        end
                        
                        DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            DropdownListScroll.CanvasSize = UDim2.new(0, 0, 0, DropdownListLayout.AbsoluteContentSize.Y + 6)
                        end)
                        
                        DropdownButton.MouseButton1Click:Connect(function()
                            Dropdown.Open = not Dropdown.Open
                            
                            if Dropdown.Open then
                                if activeDropdown and activeDropdown ~= Dropdown then
                                    activeDropdown.CloseDropdown()
                                end
                                activeDropdown = Dropdown
                                
                                UpdateListPosition()
                                DropdownList.Visible = true
                                DropdownArrow.Text = "▲"
                            else
                                CloseDropdown()
                                activeDropdown = nil
                            end
                        end)
                        
                        DropdownButton.MouseEnter:Connect(function()
                            Tween(DropdownButton, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.1)
                        end)
                        
                        DropdownButton.MouseLeave:Connect(function()
                            Tween(DropdownButton, {BackgroundColor3 = Theme.DropdownBackground}, 0.1)
                        end)
                        
                        -- Update position when scrolling
                        ColumnScrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                            if Dropdown.Open then
                                UpdateListPosition()
                            end
                        end)
                        
                        function Dropdown:Set(value)
                            if multiSelect then
                                Dropdown.Value = value
                                for optName, btn in pairs(optionButtons) do
                                    local checkmark = btn:FindFirstChild("Checkmark")
                                    if checkmark then
                                        checkmark.Text = Dropdown.Value[optName] and "✓" or ""
                                    end
                                end
                            else
                                Dropdown.Value = value
                            end
                            UpdateDropdown()
                            callback(Dropdown.Value)
                        end
                        
                        function Dropdown:Get()
                            return Dropdown.Value
                        end
                        
                        function Dropdown:Refresh(newOptions)
                            for _, child in pairs(DropdownListScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child:Destroy()
                                end
                            end
                            options = newOptions
                            optionButtons = {}
                            for _, option in ipairs(options) do
                                CreateOption(option)
                                if multiSelect then
                                    if Dropdown.Value[option] == nil then
                                        Dropdown.Value[option] = false
                                    end
                                end
                            end
                            UpdateDropdown()
                        end
                        
                        UpdateDropdown()
                        return Dropdown
                    end
                    
                    -- Button
                    function Groupbox:AddButton(buttonConfig)
                        buttonConfig = buttonConfig or {}
                        local buttonName = buttonConfig.Name or "Button"
                        local callback = buttonConfig.Callback or function() end
                        
                        local Button = {Type = "Button"}
                        
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
                    
                    -- Input
                    function Groupbox:AddInput(inputConfig)
                        inputConfig = inputConfig or {}
                        local inputName = inputConfig.Name or "Input"
                        local flag = inputConfig.Flag or inputName
                        local default = inputConfig.Default or ""
                        local placeholder = inputConfig.Placeholder or "Enter text..."
                        local numeric = inputConfig.Numeric or false
                        local callback = inputConfig.Callback or function() end
                        
                        local Input = {Value = default, Type = "Input"}
                        Window.Flags[flag] = default
                        Window.Elements[flag] = Input
                        
                        local InputFrame = Create("Frame", {
                            Name = inputName .. "Input",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 38),
                            Parent = GroupboxContent
                        })
                        
                        Create("TextLabel", {
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
                            local text = InputBox.Text
                            if numeric then
                                text = tonumber(text) or 0
                                InputBox.Text = tostring(text)
                            end
                            Input.Value = text
                            Window.Flags[flag] = text
                            callback(text)
                        end)
                        
                        InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                            if numeric then
                                InputBox.Text = InputBox.Text:gsub("[^%d%.%-]", "")
                            end
                        end)
                        
                        function Input:Set(value)
                            Input.Value = value
                            InputBox.Text = tostring(value)
                            Window.Flags[flag] = value
                            callback(value)
                        end
                        
                        function Input:Get()
                            return Input.Value
                        end
                        
                        return Input
                    end
                    
                    -- Color Picker
                    function Groupbox:AddColorPicker(colorConfig)
                        colorConfig = colorConfig or {}
                        local colorName = colorConfig.Name or "Color"
                        local flag = colorConfig.Flag or colorName
                        local default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
                        local callback = colorConfig.Callback or function() end
                        
                        local ColorPicker = {Value = default, Open = false, Type = "ColorPicker"}
                        Window.Flags[flag] = default
                        Window.Elements[flag] = ColorPicker
                        
                        local ColorFrame = Create("Frame", {
                            Name = colorName .. "Color",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 18),
                            ClipsDescendants = false,
                            Parent = GroupboxContent
                        })
                        
                        Create("TextLabel", {
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
                        
                        -- Color Picker Panel (in DropdownContainer)
                        local ColorPanel = Create("Frame", {
                            Name = "Panel",
                            BackgroundColor3 = Theme.GroupboxBackground,
                            Size = UDim2.new(0, 180, 0, 120),
                            ClipsDescendants = true,
                            Visible = false,
                            ZIndex = 100,
                            Parent = DropdownContainer
                        })
                        AddCorner(ColorPanel, 3)
                        AddStroke(ColorPanel, Theme.ElementBorder, 1)
                        
                        local ColorMain = Create("ImageButton", {
                            Name = "Main",
                            BackgroundColor3 = Color3.fromHSV(1, 1, 1),
                            Position = UDim2.new(0, 5, 0, 5),
                            Size = UDim2.new(1, -30, 1, -10),
                            AutoButtonColor = false,
                            ZIndex = 101,
                            Parent = ColorPanel
                        })
                        AddCorner(ColorMain, 3)
                        
                        Create("UIGradient", {
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
                            ZIndex = 101,
                            Parent = ColorMain
                        })
                        AddCorner(ColorMainOverlay, 3)
                        
                        Create("UIGradient", {
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
                            ZIndex = 102,
                            Parent = ColorMain
                        })
                        AddCorner(ColorMainCursor, 100)
                        AddStroke(ColorMainCursor, Color3.fromRGB(0, 0, 0), 1)
                        
                        local HueSlider = Create("ImageButton", {
                            Name = "Hue",
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Position = UDim2.new(1, -20, 0, 5),
                            Size = UDim2.new(0, 15, 1, -10),
                            AutoButtonColor = false,
                            ZIndex = 101,
                            Parent = ColorPanel
                        })
                        AddCorner(HueSlider, 3)
                        
                        Create("UIGradient", {
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
                            ZIndex = 102,
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
                            Window.Flags[flag] = ColorPicker.Value
                            callback(ColorPicker.Value)
                        end
                        
                        local function UpdatePanelPosition()
                            local displayPos = ColorDisplay.AbsolutePosition
                            local displaySize = ColorDisplay.AbsoluteSize
                            ColorPanel.Position = UDim2.new(0, displayPos.X - 150, 0, displayPos.Y + displaySize.Y + 2)
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
                            
                            if ColorPicker.Open then
                                UpdatePanelPosition()
                                ColorPanel.Visible = true
                            else
                                ColorPanel.Visible = false
                            end
                        end)
                        
                        function ColorPicker:Set(color)
                            H, S, V = color:ToHSV()
                            UpdateColor()
                        end
                        
                        function ColorPicker:Get()
                            return ColorPicker.Value
                        end
                        
                        UpdateColor()
                        return ColorPicker
                    end
                    
                    -- Keybind
                    function Groupbox:AddKeybind(keybindConfig)
                        keybindConfig = keybindConfig or {}
                        local keybindName = keybindConfig.Name or "Keybind"
                        local flag = keybindConfig.Flag or keybindName
                        local default = keybindConfig.Default or Enum.KeyCode.Unknown
                        local callback = keybindConfig.Callback or function() end
                        local changedCallback = keybindConfig.ChangedCallback or function() end
                        
                        local Keybind = {Value = default, Listening = false, Type = "Keybind"}
                        Window.Flags[flag] = default
                        Window.Elements[flag] = Keybind
                        
                        local KeybindFrame = Create("Frame", {
                            Name = keybindName .. "Keybind",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 18),
                            Parent = GroupboxContent
                        })
                        
                        Create("TextLabel", {
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
                                    if input.KeyCode == Enum.KeyCode.Escape then
                                        Keybind.Value = Enum.KeyCode.Unknown
                                        KeybindButton.Text = "None"
                                    else
                                        Keybind.Value = input.KeyCode
                                        KeybindButton.Text = input.KeyCode.Name
                                    end
                                    KeybindButton.TextColor3 = Theme.TextSecondary
                                    Keybind.Listening = false
                                    Window.Flags[flag] = Keybind.Value
                                    changedCallback(Keybind.Value)
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
                            Window.Flags[flag] = key
                            changedCallback(key)
                        end
                        
                        function Keybind:Get()
                            return Keybind.Value
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
                            TextWrapped = true,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            Parent = GroupboxContent
                        })
                        
                        function Label:Set(text)
                            LabelFrame.Text = text
                        end
                        
                        return Label
                    end
                    
                    -- Divider
                    function Groupbox:AddDivider()
                        return Create("Frame", {
                            Name = "Divider",
                            BackgroundColor3 = Theme.GroupboxBorder,
                            Size = UDim2.new(1, 0, 0, 1),
                            Parent = GroupboxContent
                        })
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
        
        if #Window.Tabs == 1 then
            SelectTab()
        end
        
        return Tab
    end
    
    function Window:SetToggleKey(key)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == key then
                MainFrame.Visible = not MainFrame.Visible
                DropdownContainer.Visible = MainFrame.Visible
            end
        end)
    end
    
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
        
        Create("TextLabel", {
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
        
        Create("TextLabel", {
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
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return SkeetLib
