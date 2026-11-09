-- Simple collection HUD. Shows unique species caught and total captures.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CloudInventory"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0, 10, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
frame.BackgroundTransparency = 0.3
frame.Parent = gui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 1, -10)
label.Position = UDim2.new(0, 5, 0, 5)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.Text = "Collection loading..."
label.Parent = frame
local function refresh()
    local total = player:GetAttribute("CloudCount") or 0
    local unique = 0
    for name, value in pairs(player:GetAttributes()) do
        if string.sub(name, 1, 12) == "SpeciesCount_" and type(value) == "number" and value > 0 then
            unique += 1
        end
    end
    label.Text = string.format("Caught: %d\nUnique species: %d\nCoins: %d\nLevel: %d", total, unique, player:GetAttribute("CloudCoins") or 0, player:GetAttribute("CloudLevel") or 1)
end
player.AttributeChanged:Connect(refresh)
refresh()
