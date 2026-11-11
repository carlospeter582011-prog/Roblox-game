-- Temporary player HUD feedback only; world scanner is actual 3D Roblox Parts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local event = ReplicatedStorage:WaitForChild("SkyObservatoryResult")
local gui = Instance.new("ScreenGui")
gui.Name = "SkyObservatoryHUD"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "ScanResult"
label.Size = UDim2.new(0.75, 0, 0, 44)
label.Position = UDim2.new(0.125, 0, 0.15, 0)
label.BackgroundTransparency = 0.2
label.BackgroundColor3 = Color3.fromRGB(24, 37, 66)
label.TextColor3 = Color3.fromRGB(240, 250, 255)
label.TextScaled = true
label.TextWrapped = true
label.Visible = false
label.Parent = gui
local limit = Instance.new("UITextSizeConstraint")
limit.MaxTextSize = 18
limit.Parent = label
local serial = 0
event.OnClientEvent:Connect(function(species, distance)
    serial += 1
    local current = serial
    if type(species) == "string" and type(distance) == "number" then
        label.Text = string.format("Observatory: %s cloud ~%d studs away", species, distance)
    else
        label.Text = "Observatory: no clouds nearby. Explore another island!"
    end
    label.Visible = true
    task.delay(5, function() if current == serial then label.Visible = false end end)
end)
