-- Compact collection HUD.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Encyclopedia = require(ReplicatedStorage:WaitForChild("Encyclopedia"))
local Progress = require(ReplicatedStorage:WaitForChild("ProgressRules"))
local speciesCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local worldCatalog = require(ReplicatedStorage:WaitForChild("WorldCatalog"))
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CloudInventory"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(218, 94)
frame.Position = UDim2.new(1, -238, 0, 248)
frame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
frame.BackgroundTransparency = 0.35
frame.Visible = false
frame.Parent = gui
local toggle = Instance.new("TextButton")
toggle.Name = "CollectionToggle"
toggle.Size = UDim2.fromOffset(108, 34)
toggle.AnchorPoint = Vector2.new(1, 0)
toggle.Position = UDim2.new(1, -20, 0, 208)
toggle.BackgroundColor3 = Color3.fromRGB(33, 85, 125)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.Text = "Collection"
toggle.Parent = gui
toggle.Activated:Connect(function()
    frame.Visible = not frame.Visible
end)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -8, 1, -8)
label.Position = UDim2.new(0, 4, 0, 4)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Font = Enum.Font.Gotham
label.TextSize = 12
label.TextWrapped = true
label.Text = "Collection..."
label.Parent = frame
local function refresh()
    local total = player:GetAttribute("CloudCount") or 0
    local caught = Encyclopedia.fromAttributes(player:GetAttributes())
    local unique = Encyclopedia.uniqueCount(caught, speciesCatalog)
    local percent = Encyclopedia.completionPercent(caught, speciesCatalog)
    local _, nextWorld, remaining = Progress.status(total, worldCatalog)
    local worldLine = "All worlds unlocked (data only)"
    if nextWorld then
        worldLine = string.format("Next world: %s in %d catches (coming soon)", worldCatalog[nextWorld].name, remaining)
    end
    label.Text = string.format("Caught: %d\nSpecies: %d/%d (%d%%)\n%s", total, unique, Encyclopedia.size(speciesCatalog), percent, worldLine)
end
player.AttributeChanged:Connect(refresh)
refresh()
