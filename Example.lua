-- Load the library (use your local version or paste it)
local SkeetLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nucleargotbeamed/Gamesense-UI-Library/refs/heads/main/Ye.lua"))()

-- If that doesn't work, the library might need to be loaded differently
-- Try this if the above fails:
-- local SkeetLib = require(script.Parent.SkeetLib) -- or however you have it

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ============ CONFIG SYSTEM ============
local ConfigSystem = {}
ConfigSystem.FolderName = "SkeetConfigs"
ConfigSystem.Settings = {}

local function CreateConfigFolder()
    if isfolder and not isfolder(ConfigSystem.FolderName) then
        makefolder(ConfigSystem.FolderName)
    end
end

function ConfigSystem:Save(name)
    CreateConfigFolder()
    if writefile then
        writefile(ConfigSystem.FolderName .. "/" .. name .. ".json", HttpService:JSONEncode(self.Settings))
        return true
    end
    return false
end

function ConfigSystem:Load(name)
    CreateConfigFolder()
    local path = ConfigSystem.FolderName .. "/" .. name .. ".json"
    if isfile and isfile(path) then
        self.Settings = HttpService:JSONDecode(readfile(path))
        return true
    end
    return false
end

function ConfigSystem:GetConfigs()
    CreateConfigFolder()
    local configs = {}
    if listfiles then
        for _, file in pairs(listfiles(ConfigSystem.FolderName)) do
            local name = file:match("([^/\\]+)%.json$")
            if name then table.insert(configs, name) end
        end
    end
    return #configs > 0 and configs or {"default"}
end

function ConfigSystem:Delete(name)
    local path = ConfigSystem.FolderName .. "/" .. name .. ".json"
    if isfile and isfile(path) and delfile then
        delfile(path)
        return true
    end
    return false
end

-- ============ ANTI-AIM SYSTEM ============
local AntiAim = {
    Enabled = false,
    BodyEnabled = false,
    HeadEnabled = false,
    DesyncEnabled = false,
    
    BodyMode = "Off",
    BodyYaw = 0,
    BodyOffset = 0,
    JitterRange = 45,
    SpinSpeed = 10,
    
    HeadMode = "Off",
    HeadPitch = 0,
    
    DesyncSide = "Left",
    DesyncAmount = 58
}

local spinAngle = 0
local jitterState = false

local function GetCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")
end

function AntiAim:GetBodyYaw(dt)
    local yaw = self.BodyOffset
    
    if self.BodyMode == "Off" then
        return 0
    elseif self.BodyMode == "Static" then
        yaw = yaw + self.BodyYaw
    elseif self.BodyMode == "Jitter" then
        jitterState = not jitterState
        yaw = yaw + (jitterState and self.JitterRange or -self.JitterRange)
    elseif self.BodyMode == "Spin" then
        spinAngle = (spinAngle + self.SpinSpeed * dt * 60) % 360
        yaw = yaw + spinAngle
    elseif self.BodyMode == "Random" then
        yaw = yaw + math.random(-180, 180)
    elseif self.BodyMode == "Backwards" then
        yaw = yaw + 180
    end
    
    return yaw
end

function AntiAim:GetDesyncOffset()
    if not self.DesyncEnabled then return 0 end
    if self.DesyncSide == "Left" then return -self.DesyncAmount
    elseif self.DesyncSide == "Right" then return self.DesyncAmount
    elseif self.DesyncSide == "Jitter" then
        jitterState = not jitterState
        return jitterState and -self.DesyncAmount or self.DesyncAmount
    end
    return 0
end

-- Anti-Aim Loop
RunService.Heartbeat:Connect(function(dt)
    if not AntiAim.Enabled or not AntiAim.BodyEnabled then return end
    
    local char, humanoid, rootPart = GetCharacter()
    if not rootPart or not humanoid or humanoid.Health <= 0 then return end
    
    local yaw = AntiAim:GetBodyYaw(dt) + AntiAim:GetDesyncOffset()
    local camera = workspace.CurrentCamera
    local camLook = camera.CFrame.LookVector
    local baseAngle = math.atan2(-camLook.X, -camLook.Z)
    local targetAngle = baseAngle + math.rad(yaw)
    
    rootPart.CFrame = CFrame.new(rootPart.CFrame.Position) * CFrame.Angles(0, targetAngle, 0)
end)

-- ============ CREATE WINDOW ============
local Window = SkeetLib:CreateWindow({
    Name = "Skeet.cc",
    Size = UDim2.new(0, 610, 0, 460)
})

-- Set toggle key
Window:SetToggleKey(Enum.KeyCode.RightShift)

-- ============ RAGE TAB ============
local RageTab = Window:CreateTab({Name = "Rage"})

-- Aimbot SubTab
local AimbotSubTab = RageTab:CreateSubTab({Name = "Aimbot"})

local AimbotColumn = AimbotSubTab:CreateColumn()
local TargetColumn = AimbotSubTab:CreateColumn()

-- Aimbot Groupbox
local AimbotGroup = AimbotColumn:CreateGroupbox({Name = "Aimbot"})

AimbotGroup:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.AimbotEnabled = value
        print("Aimbot:", value)
    end
})

AimbotGroup:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.SilentAim = value
    end
})

AimbotGroup:AddToggle({
    Name = "Auto Shoot",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.AutoShoot = value
    end
})

AimbotGroup:AddSlider({
    Name = "FOV",
    Min = 0,
    Max = 500,
    Default = 100,
    Suffix = "°",
    Callback = function(value)
        ConfigSystem.Settings.AimFOV = value
    end
})

AimbotGroup:AddSlider({
    Name = "Smoothness",
    Min = 0,
    Max = 1,
    Default = 0,
    Increment = 0.01,
    Callback = function(value)
        ConfigSystem.Settings.Smoothness = value
    end
})

-- Targeting Groupbox
local TargetGroup = TargetColumn:CreateGroupbox({Name = "Targeting"})

TargetGroup:AddDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "Random", "Nearest"},
    Default = "Head",
    Callback = function(value)
        ConfigSystem.Settings.TargetPart = value
    end
})

TargetGroup:AddDropdown({
    Name = "Priority",
    Options = {"Distance", "Health", "FOV", "Threat"},
    Default = "Distance",
    Callback = function(value)
        ConfigSystem.Settings.TargetPriority = value
    end
})

TargetGroup:AddToggle({
    Name = "Wall Check",
    Default = true,
    Callback = function(value)
        ConfigSystem.Settings.WallCheck = value
    end
})

TargetGroup:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(value)
        ConfigSystem.Settings.TeamCheck = value
    end
})

TargetGroup:AddKeybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.E,
    Callback = function(holding)
        if holding then
            print("Aim key held")
        end
    end,
    ChangedCallback = function(key)
        ConfigSystem.Settings.AimKey = key.Name
    end
})

-- ============ ANTI-AIM TAB ============
local AATab = Window:CreateTab({Name = "Anti-Aim"})

local AASubTab = AATab:CreateSubTab({Name = "Anti-Aim"})

local AAColumn = AASubTab:CreateColumn()
local DesyncColumn = AASubTab:CreateColumn()

-- Anti-Aim Main
local AAGroup = AAColumn:CreateGroupbox({Name = "Anti-Aim"})

AAGroup:AddToggle({
    Name = "Enable Anti-Aim",
    Default = false,
    Callback = function(value)
        AntiAim.Enabled = value
        ConfigSystem.Settings.AAEnabled = value
    end
})

AAGroup:AddDivider()
AAGroup:AddLabel({Text = "Body Settings"})

AAGroup:AddToggle({
    Name = "Body Yaw",
    Default = false,
    Callback = function(value)
        AntiAim.BodyEnabled = value
        ConfigSystem.Settings.BodyEnabled = value
    end
})

AAGroup:AddDropdown({
    Name = "Body Mode",
    Options = {"Off", "Static", "Jitter", "Spin", "Random", "Backwards"},
    Default = "Off",
    Callback = function(value)
        AntiAim.BodyMode = value
        ConfigSystem.Settings.BodyMode = value
    end
})

AAGroup:AddSlider({
    Name = "Yaw Offset",
    Min = -180,
    Max = 180,
    Default = 0,
    Suffix = "°",
    Callback = function(value)
        AntiAim.BodyOffset = value
        ConfigSystem.Settings.BodyOffset = value
    end
})

AAGroup:AddSlider({
    Name = "Static Yaw",
    Min = -180,
    Max = 180,
    Default = 0,
    Suffix = "°",
    Callback = function(value)
        AntiAim.BodyYaw = value
        ConfigSystem.Settings.BodyYaw = value
    end
})

AAGroup:AddSlider({
    Name = "Jitter Range",
    Min = 0,
    Max = 180,
    Default = 45,
    Suffix = "°",
    Callback = function(value)
        AntiAim.JitterRange = value
        ConfigSystem.Settings.JitterRange = value
    end
})

AAGroup:AddSlider({
    Name = "Spin Speed",
    Min = 1,
    Max = 50,
    Default = 10,
    Callback = function(value)
        AntiAim.SpinSpeed = value
        ConfigSystem.Settings.SpinSpeed = value
    end
})

-- Desync
local DesyncGroup = DesyncColumn:CreateGroupbox({Name = "Desync"})

DesyncGroup:AddToggle({
    Name = "Enable Desync",
    Default = false,
    Callback = function(value)
        AntiAim.DesyncEnabled = value
        ConfigSystem.Settings.DesyncEnabled = value
    end
})

DesyncGroup:AddDropdown({
    Name = "Desync Side",
    Options = {"Left", "Right", "Jitter"},
    Default = "Left",
    Callback = function(value)
        AntiAim.DesyncSide = value
        ConfigSystem.Settings.DesyncSide = value
    end
})

DesyncGroup:AddSlider({
    Name = "Desync Amount",
    Min = 0,
    Max = 58,
    Default = 58,
    Suffix = "°",
    Callback = function(value)
        AntiAim.DesyncAmount = value
        ConfigSystem.Settings.DesyncAmount = value
    end
})

-- Fake Lag
local FakeLagGroup = DesyncColumn:CreateGroupbox({Name = "Fake Lag"})

FakeLagGroup:AddToggle({
    Name = "Enable Fake Lag",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.FakeLag = value
    end
})

FakeLagGroup:AddSlider({
    Name = "Choke Amount",
    Min = 1,
    Max = 14,
    Default = 7,
    Suffix = " ticks",
    Callback = function(value)
        ConfigSystem.Settings.ChokeAmount = value
    end
})

-- ============ VISUALS TAB ============
local VisualsTab = Window:CreateTab({Name = "Visuals"})

local ESPSubTab = VisualsTab:CreateSubTab({Name = "ESP"})

local ESPColumn = ESPSubTab:CreateColumn()
local WorldColumn = ESPSubTab:CreateColumn()

-- ESP
local ESPGroup = ESPColumn:CreateGroupbox({Name = "Player ESP"})

ESPGroup:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.ESPEnabled = value
    end
})

ESPGroup:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.BoxESP = value
    end
})

ESPGroup:AddColorPicker({
    Name = "Box Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ConfigSystem.Settings.BoxColor = {color.R * 255, color.G * 255, color.B * 255}
    end
})

ESPGroup:AddToggle({
    Name = "Name ESP",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.NameESP = value
    end
})

ESPGroup:AddToggle({
    Name = "Health Bar",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.HealthBar = value
    end
})

ESPGroup:AddToggle({
    Name = "Tracers",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.Tracers = value
    end
})

ESPGroup:AddSlider({
    Name = "Max Distance",
    Min = 100,
    Max = 2000,
    Default = 500,
    Suffix = " studs",
    Callback = function(value)
        ConfigSystem.Settings.ESPDistance = value
    end
})

-- World
local WorldGroup = WorldColumn:CreateGroupbox({Name = "World"})

WorldGroup:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.Fullbright = value
        local lighting = game:GetService("Lighting")
        if value then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
        else
            lighting.Brightness = 1
            lighting.GlobalShadows = true
        end
    end
})

WorldGroup:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.NoFog = value
        game:GetService("Lighting").FogEnd = value and 100000 or 1000
    end
})

WorldGroup:AddSlider({
    Name = "Time of Day",
    Min = 0,
    Max = 24,
    Default = 12,
    Increment = 0.5,
    Suffix = "h",
    Callback = function(value)
        ConfigSystem.Settings.TimeOfDay = value
        game:GetService("Lighting").ClockTime = value
    end
})

WorldGroup:AddColorPicker({
    Name = "Ambient Color",
    Default = Color3.fromRGB(127, 127, 127),
    Callback = function(color)
        game:GetService("Lighting").Ambient = color
    end
})

-- ============ MISC TAB ============
local MiscTab = Window:CreateTab({Name = "Misc"})

local MiscSubTab = MiscTab:CreateSubTab({Name = "Movement"})

local MovementColumn = MiscSubTab:CreateColumn()
local PlayerColumn = MiscSubTab:CreateColumn()

-- Movement
local MovementGroup = MovementColumn:CreateGroupbox({Name = "Movement"})

local speedEnabled = false
local speedValue = 50

MovementGroup:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        ConfigSystem.Settings.Speed = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = value and speedValue or 16
        end
    end
})

MovementGroup:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(value)
        speedValue = value
        ConfigSystem.Settings.SpeedValue = value
        if speedEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
            end
        end
    end
})

MovementGroup:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.InfiniteJump = value
    end
})

MovementGroup:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.Fly = value
        -- Fly implementation would go here
    end
})

MovementGroup:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(value)
        ConfigSystem.Settings.FlySpeed = value
    end
})

MovementGroup:AddKeybind({
    Name = "Fly Toggle",
    Default = Enum.KeyCode.F,
    Callback = function(holding)
        -- Toggle fly
    end
})

-- Player
local PlayerGroup = PlayerColumn:CreateGroupbox({Name = "Player"})

PlayerGroup:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(value)
        ConfigSystem.Settings.Noclip = value
    end
})

PlayerGroup:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(value)
        ConfigSystem.Settings.JumpPower = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = value
        end
    end
})

PlayerGroup:AddSlider({
    Name = "Gravity",
    Min = 50,
    Max = 400,
    Default = 196,
    Callback = function(value)
        workspace.Gravity = value
        ConfigSystem.Settings.Gravity = value
    end
})

PlayerGroup:AddButton({
    Name = "Reset Character",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").Health = 0
        end
    end
})

PlayerGroup:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if ConfigSystem.Settings.InfiniteJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip Handler
RunService.Stepped:Connect(function()
    if ConfigSystem.Settings.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ============ CONFIG TAB ============
local ConfigTab = Window:CreateTab({Name = "Config"})

local ConfigSubTab = ConfigTab:CreateSubTab({Name = "Configs"})

local SaveColumn = ConfigSubTab:CreateColumn()
local LoadColumn = ConfigSubTab:CreateColumn()

-- Save
local SaveGroup = SaveColumn:CreateGroupbox({Name = "Save Configuration"})

local configName = "default"

SaveGroup:AddInput({
    Name = "Config Name",
    Default = "default",
    Placeholder = "Enter config name...",
    Callback = function(text)
        configName = text
    end
})

SaveGroup:AddButton({
    Name = "Save Config",
    Callback = function()
        if configName ~= "" then
            if ConfigSystem:Save(configName) then
                Window:Notify({
                    Title = "Config Saved",
                    Message = "Successfully saved config: " .. configName,
                    Duration = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Message = "Failed to save config (no file system)",
                    Duration = 3
                })
            end
        end
    end
})

SaveGroup:AddButton({
    Name = "Delete Config",
    Callback = function()
        if ConfigSystem:Delete(configName) then
            Window:Notify({
                Title = "Config Deleted",
                Message = "Deleted config: " .. configName,
                Duration = 3
            })
        end
    end
})

SaveGroup:AddDivider()
SaveGroup:AddLabel({Text = "Configs are saved locally"})

-- Load
local LoadGroup = LoadColumn:CreateGroupbox({Name = "Load Configuration"})

local ConfigDropdown = LoadGroup:AddDropdown({
    Name = "Select Config",
    Options = ConfigSystem:GetConfigs(),
    Default = "default",
    Callback = function(value)
        configName = value
    end
})

LoadGroup:AddButton({
    Name = "Load Config",
    Callback = function()
        if ConfigSystem:Load(configName) then
            Window:Notify({
                Title = "Config Loaded",
                Message = "Successfully loaded config: " .. configName,
                Duration = 3
            })
            -- Apply settings here - you'd need to store references to UI elements
        else
            Window:Notify({
                Title = "Error",
                Message = "Failed to load config",
                Duration = 3
            })
        end
    end
})

LoadGroup:AddButton({
    Name = "Refresh List",
    Callback = function()
        ConfigDropdown:Refresh(ConfigSystem:GetConfigs())
        Window:Notify({
            Title = "Refreshed",
            Message = "Config list refreshed",
            Duration = 2
        })
    end
})

-- UI Settings
local UIGroup = LoadColumn:CreateGroupbox({Name = "UI Settings"})

UIGroup:AddKeybind({
    Name = "Menu Toggle",
    Default = Enum.KeyCode.RightShift,
    ChangedCallback = function(key)
        Window:SetToggleKey(key)
    end
})

UIGroup:AddColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(114, 137, 218),
    Callback = function(color)
        -- Would need to update theme
    end
})

-- ============ NOTIFICATIONS ============
Window:Notify({
    Title = "Welcome",
    Message = "Skeet UI loaded! Press RightShift to toggle.",
    Duration = 5
})

print("Skeet UI Loaded Successfully!")
print("Press RightShift to toggle menu")
