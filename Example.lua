local SkeetLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nucleargotbeamed/Gamesense-UI-Library/refs/heads/main/Ye.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

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
    if self.DesyncSide == "Left" then
        return -self.DesyncAmount
    elseif self.DesyncSide == "Right" then
        return self.DesyncAmount
    elseif self.DesyncSide == "Jitter" then
        jitterState = not jitterState
        return jitterState and -self.DesyncAmount or self.DesyncAmount
    end
    return 0
end

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

local Window = SkeetLib:CreateWindow({
    Name = "Skeet.cc",
    Size = UDim2.new(0, 610, 0, 460)
})

Window:SetToggleKey(Enum.KeyCode.RightShift)

local RageTab = Window:CreateTab({Name = "Rage"})
local AimbotSubTab = RageTab:CreateSubTab({Name = "Aimbot"})
local AimbotColumn = AimbotSubTab:CreateColumn()
local TargetColumn = AimbotSubTab:CreateColumn()
local AimbotGroup = AimbotColumn:CreateGroupbox({Name = "Aimbot"})

AimbotGroup:AddToggle({Name="Enable Aimbot",Default=false,Callback=function(v)ConfigSystem.Settings.AimbotEnabled=v end})
AimbotGroup:AddToggle({Name="Silent Aim",Default=false,Callback=function(v)ConfigSystem.Settings.SilentAim=v end})
AimbotGroup:AddToggle({Name="Auto Shoot",Default=false,Callback=function(v)ConfigSystem.Settings.AutoShoot=v end})
AimbotGroup:AddSlider({Name="FOV",Min=0,Max=500,Default=100,Suffix="°",Callback=function(v)ConfigSystem.Settings.AimFOV=v end})
AimbotGroup:AddSlider({Name="Smoothness",Min=0,Max=1,Default=0,Increment=0.01,Callback=function(v)ConfigSystem.Settings.Smoothness=v end})

local TargetGroup = TargetColumn:CreateGroupbox({Name = "Targeting"})
TargetGroup:AddDropdown({Name="Target Part",Options={"Head","Torso","Random","Nearest"},Default="Head",Callback=function(v)ConfigSystem.Settings.TargetPart=v end})
TargetGroup:AddDropdown({Name="Priority",Options={"Distance","Health","FOV","Threat"},Default="Distance",Callback=function(v)ConfigSystem.Settings.TargetPriority=v end})
TargetGroup:AddToggle({Name="Wall Check",Default=true,Callback=function(v)ConfigSystem.Settings.WallCheck=v end})
TargetGroup:AddToggle({Name="Team Check",Default=true,Callback=function(v)ConfigSystem.Settings.TeamCheck=v end})
TargetGroup:AddKeybind({Name="Aim Key",Default=Enum.KeyCode.E,Callback=function()end,ChangedCallback=function(k)ConfigSystem.Settings.AimKey=k.Name end})

local AATab = Window:CreateTab({Name = "Anti-Aim"})
local AASubTab = AATab:CreateSubTab({Name = "Anti-Aim"})
local AAColumn = AASubTab:CreateColumn()
local DesyncColumn = AASubTab:CreateColumn()
local AAGroup = AAColumn:CreateGroupbox({Name = "Anti-Aim"})

AAGroup:AddToggle({Name="Enable Anti-Aim",Default=false,Callback=function(v)AntiAim.Enabled=v ConfigSystem.Settings.AAEnabled=v end})
AAGroup:AddToggle({Name="Body Yaw",Default=false,Callback=function(v)AntiAim.BodyEnabled=v ConfigSystem.Settings.BodyEnabled=v end})
AAGroup:AddDropdown({Name="Body Mode",Options={"Off","Static","Jitter","Spin","Random","Backwards"},Default="Off",Callback=function(v)AntiAim.BodyMode=v ConfigSystem.Settings.BodyMode=v end})
AAGroup:AddSlider({Name="Yaw Offset",Min=-180,Max=180,Default=0,Suffix="°",Callback=function(v)AntiAim.BodyOffset=v ConfigSystem.Settings.BodyOffset=v end})
AAGroup:AddSlider({Name="Static Yaw",Min=-180,Max=180,Default=0,Suffix="°",Callback=function(v)AntiAim.BodyYaw=v ConfigSystem.Settings.BodyYaw=v end})
AAGroup:AddSlider({Name="Jitter Range",Min=0,Max=180,Default=45,Suffix="°",Callback=function(v)AntiAim.JitterRange=v ConfigSystem.Settings.JitterRange=v end})
AAGroup:AddSlider({Name="Spin Speed",Min=1,Max=50,Default=10,Callback=function(v)AntiAim.SpinSpeed=v ConfigSystem.Settings.SpinSpeed=v end})

local DesyncGroup = DesyncColumn:CreateGroupbox({Name = "Desync"})
DesyncGroup:AddToggle({Name="Enable Desync",Default=false,Callback=function(v)AntiAim.DesyncEnabled=v ConfigSystem.Settings.DesyncEnabled=v end})
DesyncGroup:AddDropdown({Name="Desync Side",Options={"Left","Right","Jitter"},Default="Left",Callback=function(v)AntiAim.DesyncSide=v ConfigSystem.Settings.DesyncSide=v end})
DesyncGroup:AddSlider({Name="Desync Amount",Min=0,Max=58,Default=58,Suffix="°",Callback=function(v)AntiAim.DesyncAmount=v ConfigSystem.Settings.DesyncAmount=v end})

local FakeLagGroup = DesyncColumn:CreateGroupbox({Name = "Fake Lag"})
FakeLagGroup:AddToggle({Name="Enable Fake Lag",Default=false,Callback=function(v)ConfigSystem.Settings.FakeLag=v end})
FakeLagGroup:AddSlider({Name="Choke Amount",Min=1,Max=14,Default=7,Suffix=" ticks",Callback=function(v)ConfigSystem.Settings.ChokeAmount=v end})

local VisualsTab = Window:CreateTab({Name = "Visuals"})
local ESPSubTab = VisualsTab:CreateSubTab({Name = "ESP"})
local ESPColumn = ESPSubTab:CreateColumn()
local WorldColumn = ESPSubTab:CreateColumn()
local ESPGroup = ESPColumn:CreateGroupbox({Name = "Player ESP"})

ESPGroup:AddToggle({Name="Enable ESP",Default=false,Callback=function(v)ConfigSystem.Settings.ESPEnabled=v end})
ESPGroup:AddToggle({Name="Box ESP",Default=false,Callback=function(v)ConfigSystem.Settings.BoxESP=v end})
ESPGroup:AddToggle({Name="Name ESP",Default=false,Callback=function(v)ConfigSystem.Settings.NameESP=v end})
ESPGroup:AddToggle({Name="Health Bar",Default=false,Callback=function(v)ConfigSystem.Settings.HealthBar=v end})
ESPGroup:AddToggle({Name="Tracers",Default=false,Callback=function(v)ConfigSystem.Settings.Tracers=v end})
ESPGroup:AddSlider({Name="Max Distance",Min=100,Max=2000,Default=500,Suffix=" studs",Callback=function(v)ConfigSystem.Settings.ESPDistance=v end})

local WorldGroup = WorldColumn:CreateGroupbox({Name = "World"})
WorldGroup:AddToggle({Name="Fullbright",Default=false,Callback=function(v)ConfigSystem.Settings.Fullbright=v local l=game:GetService("Lighting") if v then l.Brightness=2 l.ClockTime=14 l.FogEnd=100000 l.GlobalShadows=false else l.Brightness=1 l.GlobalShadows=true end end})
WorldGroup:AddToggle({Name="No Fog",Default=false,Callback=function(v)ConfigSystem.Settings.NoFog=v game:GetService("Lighting").FogEnd=v and 100000 or 1000 end})
WorldGroup:AddSlider({Name="Time of Day",Min=0,Max=24,Default=12,Increment=0.5,Suffix="h",Callback=function(v)ConfigSystem.Settings.TimeOfDay=v game:GetService("Lighting").ClockTime=v end})

local MiscTab = Window:CreateTab({Name = "Misc"})
local MiscSubTab = MiscTab:CreateSubTab({Name = "Movement"})
local MovementColumn = MiscSubTab:CreateColumn()
local PlayerColumn = MiscSubTab:CreateColumn()
local MovementGroup = MovementColumn:CreateGroupbox({Name = "Movement"})

local speedEnabled=false
local speedValue=50

MovementGroup:AddToggle({Name="Speed Hack",Default=false,Callback=function(v)speedEnabled=v ConfigSystem.Settings.Speed=v local c=LocalPlayer.Character if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").WalkSpeed=v and speedValue or 16 end end})
MovementGroup:AddSlider({Name="Speed Value",Min=16,Max=200,Default=50,Callback=function(v)speedValue=v ConfigSystem.Settings.SpeedValue=v if speedEnabled then local c=LocalPlayer.Character if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").WalkSpeed=v end end end})
MovementGroup:AddToggle({Name="Infinite Jump",Default=false,Callback=function(v)ConfigSystem.Settings.InfiniteJump=v end})

local PlayerGroup = PlayerColumn:CreateGroupbox({Name = "Player"})
PlayerGroup:AddToggle({Name="Noclip",Default=false,Callback=function(v)ConfigSystem.Settings.Noclip=v end})
PlayerGroup:AddSlider({Name="Jump Power",Min=50,Max=200,Default=50,Callback=function(v)ConfigSystem.Settings.JumpPower=v local c=LocalPlayer.Character if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").JumpPower=v end end})

UserInputService.JumpRequest:Connect(function()
    if ConfigSystem.Settings.InfiniteJump then
        local c=LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    if ConfigSystem.Settings.Noclip then
        local c=LocalPlayer.Character
        if c then
            for _,p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end
    end
end)

Window:Notify({Title="Welcome",Message="Skeet UI loaded! Press RightShift to toggle.",Duration=5})
print("Skeet UI Loaded Successfully!")
print("Press RightShift to toggle menu")
