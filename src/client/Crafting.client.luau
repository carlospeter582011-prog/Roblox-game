-- Client crafting HUD. ScreenGui only; no world geometry.
-- Requests craft via remote; server validates and applies via CraftingRules.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local craftRemote = ReplicatedStorage:WaitForChild("CraftRequest", 10)
if not craftRemote then
    return -- remote not present; skip UI
end

local screen = Instance.new("ScreenGui")
screen.Name = "CraftingGui"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "CraftingPanel"
frame.Size = UDim2.new(0, 280, 0, 220)
frame.Position = UDim2.new(0, 12, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 28)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Crafting"
title.TextColor3 = Color3.fromRGB(220, 240, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -50)
list.Position = UDim2.new(0, 8, 0, 38)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

-- Toggle button (left side, stacked with other HUD)
local toggle = Instance.new("TextButton")
toggle.Name = "CraftToggle"
toggle.Size = UDim2.new(0, 90, 0, 32)
toggle.Position = UDim2.new(0, 12, 0.5, 120)
toggle.BackgroundColor3 = Color3.fromRGB(40, 70, 110)
toggle.Text = "Craft"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 14
toggle.Font = Enum.Font.Gotham
toggle.Parent = screen

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 8)
tCorner.Parent = toggle

toggle.Activated:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Placeholder recipes; real data would come from remote or shared catalog replication
local placeholderRecipes = {
    { id = "wind_lasso_craft", label = "Wind Lasso (5 Air Essence + 40 Coins)" },
    { id = "mist_gloves_craft", label = "Mist Gloves (6 Water + 2 Air + 60 Coins)" },
}

for _, rec in ipairs(placeholderRecipes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 120)
    btn.Text = rec.label
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.TextWrapped = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = list
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn
    btn.Activated:Connect(function()
        craftRemote:FireServer(rec.id)
    end)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
end)
