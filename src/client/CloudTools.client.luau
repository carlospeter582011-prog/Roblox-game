-- Compact tool picker.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local catalog = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local Progress = require(ReplicatedStorage:WaitForChild("ProgressRules"))
local equip = ReplicatedStorage:WaitForChild("EquipCatchTool")
local purchase = ReplicatedStorage:WaitForChild("PurchaseCatchTool")
local trainingPurchase = ReplicatedStorage:WaitForChild("PurchaseRangeTraining")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudToolPicker"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(80, 32)
button.Position = UDim2.new(0, 16, 0, 144)
button.Text = "Shop"
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.BackgroundColor3 = Color3.fromRGB(33, 85, 125)
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = gui
-- Scrolls so all tools fit on a small touch screen.
local panel = Instance.new("ScrollingFrame")
panel.Size = UDim2.new(0, 230, 0, 215)
panel.Position = UDim2.new(0, 16, 0, 184)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(24, 48, 81)
panel.CanvasSize = UDim2.new(0, 0, 0, 0)
panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
panel.ScrollBarThickness = 6
panel.Parent = gui
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 3)
layout.Parent = panel
local order = Progress.sortedByUnlock(catalog) -- every tool, in unlock order
local rows = {}
local trainingButton = Instance.new("TextButton")
trainingButton.Name = "RangeTraining"
trainingButton.LayoutOrder = -1
trainingButton.Size = UDim2.new(1, -6, 0, 42)
trainingButton.TextSize = 12
trainingButton.TextWrapped = true
trainingButton.Font = Enum.Font.GothamBold
trainingButton.TextColor3 = Color3.new(1, 1, 1)
trainingButton.BackgroundColor3 = Color3.fromRGB(42, 119, 88)
trainingButton.Parent = panel
trainingButton.Activated:Connect(function()
    trainingPurchase:FireServer()
end)
for _, id in ipairs(order) do
    local tool = catalog[id]
    local row = Instance.new("TextButton")
    row.Name = id
    row.LayoutOrder = tool.unlockCatches + 1
    row.Size = UDim2.new(1, -6, 0, 32)
    row.TextSize = 13
    row.Font = Enum.Font.Gotham
    row.TextColor3 = Color3.new(1, 1, 1)
    row.BackgroundColor3 = Color3.fromRGB(45, 103, 139)
    row.Parent = panel
    row.Activated:Connect(function()
        if (player:GetAttribute("CloudCount") or 0) < tool.unlockCatches then return end
        if id == "starter_net" or player:GetAttribute("OwnsTool_" .. id) then
            equip:FireServer(id)
            button.Text = tool.name
            panel.Visible = false
        else
            purchase:FireServer(id)
        end
    end)
    rows[id] = row
end
local function refresh()
    local count = player:GetAttribute("CloudCount") or 0
    local training = math.clamp(player:GetAttribute("RangeTraining") or 0, 0, 3)
    local costs = { 100, 250, 500 }
    local levels = { 2, 4, 6 }
    trainingButton.Text = training == 3 and "Range Training MAX (+6 studs)" or ("Train Range +" .. ((training + 1) * 2) .. " | " .. costs[training + 1] .. " coins | Lv " .. levels[training + 1])
    for id, row in pairs(rows) do
        local tool = catalog[id]
        local locked = count < tool.unlockCatches
        local selected = player:GetAttribute("EquippedCatchTool") == id
        local owned = id == "starter_net" or player:GetAttribute("OwnsTool_" .. id) == true
        row.Text = tool.name .. (id == "storm_vacuum" and " [3-cloud burst]" or (id == "cloud_magnet" and " [12-stud pull]" or "")) .. (locked and (" | " .. tool.unlockCatches .. " catches") or (selected and " | Equipped" or (owned and " | Equip" or (" | Buy " .. tool.priceCoins .. " coins"))))
        row.BackgroundColor3 = selected and Color3.fromRGB(36, 133, 95) or (locked and Color3.fromRGB(55, 66, 83) or Color3.fromRGB(45, 103, 139))
    end
end
player:GetAttributeChangedSignal("CloudCount"):Connect(refresh)
player:GetAttributeChangedSignal("EquippedCatchTool"):Connect(refresh)
player:GetAttributeChangedSignal("CloudCoins"):Connect(refresh)
player:GetAttributeChangedSignal("RangeTraining"):Connect(refresh)
player:GetAttributeChangedSignal("CloudLevel"):Connect(refresh)
for _, id in ipairs(order) do
    player:GetAttributeChangedSignal("OwnsTool_" .. id):Connect(refresh)
end
trainingPurchase.OnClientEvent:Connect(function(ok, result)
    button.Text = tostring(result)
    refresh()
    task.delay(2, function() button.Text = "Shop" end)
end)
purchase.OnClientEvent:Connect(function(ok, result)
    button.Text = ok and "Purchased!" or tostring(result)
    refresh()
    task.delay(2, function() button.Text = "Shop" end)
end)
button.Activated:Connect(function()
    refresh()
    panel.Visible = not panel.Visible
end)
refresh()
