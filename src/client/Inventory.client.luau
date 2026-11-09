-- Compact collection HUD.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CloudInventory"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 70)
frame.Position = UDim2.new(0, 8, 0.5, -35)
frame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
frame.BackgroundTransparency = 0.35
frame.Parent = gui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -8, 1, -8)
label.Position = UDim2.new(0, 4, 0, 4)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Font = Enum.Font.Gotham
label.TextSize = 12
label.Text = "Collection..."
label.Parent = frame
local function refresh()
    local total = player:GetAttribute("CloudCount") or 0
    local unique = 0
    for name, value in pairs(player:GetAttributes()) do
        if string.sub(name, 1, 12) == "SpeciesCount_" and type(value) == "number" and value > 0 then
            unique += 1
        end
    end
    label.Text = string.format("Caught: %d\nUnique: %d", total, unique)
end
player.AttributeChanged:Connect(refresh)
refresh()
