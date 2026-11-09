-- Compact tool picker.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local catalog = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local equip = ReplicatedStorage:WaitForChild("EquipCatchTool")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudToolPicker"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(80, 32)
button.Position = UDim2.new(0, 8, 1, -44)
button.Text = "Tools"
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.BackgroundColor3 = Color3.fromRGB(33, 85, 125)
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = gui
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 180)
panel.Position = UDim2.new(0, 8, 1, -230)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(24, 48, 81)
panel.Parent = gui
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 3)
layout.Parent = panel
local order = { "starter_net", "wind_lasso", "mist_gloves", "cloud_magnet", "golden_net" }
local rows = {}
for _, id in ipairs(order) do
    local tool = catalog[id]
    local row = Instance.new("TextButton")
    row.Name = id
    row.Size = UDim2.new(1, -6, 0, 32)
    row.TextSize = 13
    row.Font = Enum.Font.Gotham
    row.TextColor3 = Color3.new(1, 1, 1)
    row.BackgroundColor3 = Color3.fromRGB(45, 103, 139)
    row.Parent = panel
    row.Activated:Connect(function()
        if (player:GetAttribute("CloudCount") or 0) >= tool.unlockCatches then
            equip:FireServer(id)
            panel.Visible = false
        end
    end)
    rows[id] = row
end
local function refresh()
    local count = player:GetAttribute("CloudCount") or 0
    for id, row in pairs(rows) do
        local tool = catalog[id]
        local locked = count < tool.unlockCatches
        row.Text = tool.name .. (locked and (" | " .. tool.unlockCatches) or "")
    end
end
player:GetAttributeChangedSignal("CloudCount"):Connect(refresh)
button.Activated:Connect(function()
    refresh()
    panel.Visible = not panel.Visible
end)
refresh()
