-- Gamesense UI Library Example
-- This demonstrates how to use the Gamesense UI Library

-- Load the UI library
local Gamesense = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/gamesense-ui/main/gamesense_ui_library.lua"))()

-- Initialize the UI
Gamesense:Init()

-- Create tabs
local legitTab = Gamesense:CreateTab("Legit")
local rageTab = Gamesense:CreateTab("Rage")
local visualsTab = Gamesense:CreateTab("Visuals")
local miscTab = Gamesense:CreateTab("Misc")
local skinsTab = Gamesense:CreateTab("Skins")
local configTab = Gamesense:CreateTab("Config")

-- LEGIT TAB COMPONENTS
-- Aimbot Section
Gamesense:CreateButton(legitTab, "Aimbot", function()
    print("Aimbot clicked")
end)

Gamesense:CreateToggle(legitTab, "Enable Aimbot", false, function(state)
    print("Aimbot:", state)
end)

Gamesense:CreateSlider(legitTab, "Smoothness", 1, 100, 50, function(value)
    print("Smoothness:", value)
end)

Gamesense:CreateSlider(legitTab, "FOV", 1, 360, 90, function(value)
    print("FOV:", value)
end)

Gamesense:CreateToggle(legitTab, "Visible Check", true, function(state)
    print("Visible Check:", state)
end)

Gamesense:CreateToggle(legitTab, "Team Check", true, function(state)
    print("Team Check:", state)
end)

Gamesense:CreateKeybind(legitTab, "Aimbot Key", Enum.KeyCode.E, function(key)
    print("Aimbot Key set to:", key.Name)
end)

-- RAGE TAB COMPONENTS
Gamesense:CreateToggle(rageTab, "Enable Ragebot", false, function(state)
    print("Ragebot:", state)
end)

Gamesense:CreateToggle(rageTab, "Auto Shoot", false, function(state)
    print("Auto Shoot:", state)
end)

Gamesense:CreateToggle(rageTab, "Auto Scope", false, function(state)
    print("Auto Scope:", state)
end)

Gamesense:CreateSlider(rageTab, "Hitchance", 0, 100, 80, function(value)
    print("Hitchance:", value)
end)

Gamesense:CreateSlider(rageTab, "Damage", 0, 100, 30, function(value)
    print("Minimum Damage:", value)
end)

Gamesense:CreateToggle(rageTab, "Body Aim", false, function(state)
    print("Body Aim:", state)
end)

Gamesense:CreateToggle(rageTab, "Silent Aim", true, function(state)
    print("Silent Aim:", state)
end)

-- VISUALS TAB COMPONENTS
Gamesense:CreateToggle(visualsTab, "Enable ESP", false, function(state)
    print("ESP:", state)
end)

Gamesense:CreateToggle(visualsTab, "Box ESP", false, function(state)
    print("Box ESP:", state)
end)

Gamesense:CreateToggle(visualsTab, "Name ESP", true, function(state)
    print("Name ESP:", state)
end)

Gamesense:CreateToggle(visualsTab, "Health ESP", true, function(state)
    print("Health ESP:", state)
end)

Gamesense:CreateToggle(visualsTab, "Skeleton ESP", false, function(state)
    print("Skeleton ESP:", state)
end)

Gamesense:CreateSlider(visualsTab, "ESP Distance", 100, 5000, 2000, function(value)
    print("ESP Distance:", value)
end)

Gamesense:CreateToggle(visualsTab, "Chams", false, function(state)
    print("Chams:", state)
end)

Gamesense:CreateButton(visualsTab, "Reset Visuals", function()
    print("Reset Visuals clicked")
end)

-- MISC TAB COMPONENTS
Gamesense:CreateToggle(miscTab, "Bunny Hop", false, function(state)
    print("Bunny Hop:", state)
end)

Gamesense:CreateToggle(miscTab, "Auto Jump", false, function(state)
    print("Auto Jump:", state)
end)

Gamesense:CreateToggle(miscTab, "Auto Strafe", false, function(state)
    print("Auto Strafe:", state)
end)

Gamesense:CreateToggle(miscTab, "Radar Hack", false, function(state)
    print("Radar Hack:", state)
end)

Gamesense:CreateToggle(miscTab, "No Flash", false, function(state)
    print("No Flash:", state)
end)

Gamesense:CreateToggle(miscTab, "No Smoke", false, function(state)
    print("No Smoke:", state)
end)

Gamesense:CreateKeybind(miscTab, "Panic Key", Enum.KeyCode.Insert, function(key)
    print("Panic Key set to:", key.Name)
end)

Gamesense:CreateSlider(miscTab, "Viewmodel FOV", 50, 150, 90, function(value)
    print("Viewmodel FOV:", value)
end)

-- SKINS TAB COMPONENTS
Gamesense:CreateButton(skinsTab, "Load Skins", function()
    print("Load Skins clicked")
end)

Gamesense:CreateToggle(skinsTab, "Auto Update", true, function(state)
    print("Auto Update Skins:", state)
end)

Gamesense:CreateButton(skinsTab, "Refresh Inventory", function()
    print("Refresh Inventory clicked")
end)

Gamesense:CreateButton(skinsTab, "Save Config", function()
    print("Save Skin Config clicked")
end)

-- CONFIG TAB COMPONENTS
Gamesense:CreateButton(configTab, "Save Config", function()
    print("Save Config clicked")
end)

Gamesense:CreateButton(configTab, "Load Config", function()
    print("Load Config clicked")
end)

Gamesense:CreateButton(configTab, "Reset Config", function()
    print("Reset Config clicked")
end)

Gamesense:CreateButton(configTab, "Export Config", function()
    print("Export Config clicked")
end)

Gamesense:CreateButton(configTab, "Import Config", function()
    print("Import Config clicked")
end)

-- Toggle UI with Insert key
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        Gamesense:Toggle()
    end
end)

print("Gamesense UI Loaded Successfully!")
print("Press INSERT to toggle the UI")
