-- Compact tool picker.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local catalog = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local Progress = require(ReplicatedStorage:WaitForChild("ProgressRules"))
local Locale = require(ReplicatedStorage:WaitForChild("LocaleText"))
local function tr(key) return Locale.text(player:GetAttribute("UILanguage"), key) end
local equip = ReplicatedStorage:WaitForChild("EquipCatchTool")
local purchase = ReplicatedStorage:WaitForChild("PurchaseCatchTool")
local trainingPurchase = ReplicatedStorage:WaitForChild("PurchaseRangeTraining")
local companionRemote = ReplicatedStorage:WaitForChild("CycleCloudCompanion")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudToolPicker"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(80, 32)
button.Position = UDim2.new(0, 16, 0, 144)
button.Text = "Shop"
local languageButton = Instance.new("TextButton")
languageButton.Name = "LanguageToggle"
languageButton.Size = UDim2.fromOffset(64, 32)
languageButton.Position = UDim2.new(0, 104, 0, 144)
languageButton.Font = Enum.Font.GothamBold
languageButton.TextSize = 13
languageButton.TextColor3 = Color3.new(1, 1, 1)
languageButton.BackgroundColor3 = Color3.fromRGB(55, 77, 110)
languageButton.Parent = gui
languageButton.Activated:Connect(function()
    player:SetAttribute("UILanguage", player:GetAttribute("UILanguage") == "ar" and "en" or "ar")
end)
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
local companionButton = Instance.new("TextButton")
companionButton.Name = "CompanionPicker"
companionButton.LayoutOrder = 0
companionButton.Size = UDim2.new(1, -6, 0, 42)
companionButton.TextSize = 12
companionButton.TextWrapped = true
companionButton.Font = Enum.Font.GothamBold
companionButton.TextColor3 = Color3.new(1, 1, 1)
companionButton.BackgroundColor3 = Color3.fromRGB(92, 72, 145)
companionButton.Parent = panel
companionButton.Activated:Connect(function()
    companionRemote:FireServer()
end)
local function refreshCompanion()
    local id = player:GetAttribute("CompanionSpecies")
    companionButton.Text = id and id ~= "" and (tr("companion") .. ": " .. id .. " | " .. tr("switch")) or tr("catchFirst")
end
player:GetAttributeChangedSignal("CompanionSpecies"):Connect(refreshCompanion)
companionRemote.OnClientEvent:Connect(function(ok, message)
    companionButton.Text = tostring(message)
    task.delay(2, refreshCompanion)
end)
refreshCompanion()
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
    languageButton.Text = player:GetAttribute("UILanguage") == "ar" and "EN" or "عربي"
    if not panel.Visible then button.Text = tr("shop") end
    local count = player:GetAttribute("CloudCount") or 0
    local training = math.clamp(player:GetAttribute("RangeTraining") or 0, 0, 3)
    local costs = { 100, 250, 500 }
    local levels = { 2, 4, 6 }
    trainingButton.Text = training == 3 and (tr("maxRange") .. " (+6 studs)") or (tr("train") .. " +" .. ((training + 1) * 2) .. " | " .. Locale.number(costs[training + 1]) .. " " .. tr("coins") .. " | " .. tr("level") .. " " .. levels[training + 1])
    for id, row in pairs(rows) do
        local tool = catalog[id]
        local locked = count < tool.unlockCatches
        local selected = player:GetAttribute("EquippedCatchTool") == id
        local owned = id == "starter_net" or player:GetAttribute("OwnsTool_" .. id) == true
        row.Text = tool.name .. (id == "storm_vacuum" and " [3-cloud burst]" or (id == "cloud_magnet" and " [12-stud pull]" or "")) .. (locked and (" | " .. tool.unlockCatches .. " " .. tr("catches")) or (selected and (" | " .. tr("equipped")) or (owned and (" | " .. tr("equip")) or (" | " .. tr("buy") .. " " .. Locale.number(tool.priceCoins) .. " " .. tr("coins")))))
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
    task.delay(2, function() button.Text = tr("shop") end)
end)
purchase.OnClientEvent:Connect(function(ok, result)
    button.Text = ok and tr("purchased") or tostring(result)
    refresh()
    task.delay(2, function() button.Text = "Shop" end)
end)
player:GetAttributeChangedSignal("UILanguage"):Connect(function()
    refresh()
    refreshCompanion()
end)
button.Activated:Connect(function()
    refresh()
    panel.Visible = not panel.Visible
end)
refresh()
