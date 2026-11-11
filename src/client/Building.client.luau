-- Compact building shop UI for mobile portrait and desktop. Left-side stacked.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("PlaceBuilding")
local BuildingCatalog = require(ReplicatedStorage:WaitForChild("BuildingCatalog"))

local gui = Instance.new("ScreenGui")
gui.Name = "BuildingGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "BuildButton"
button.Size = UDim2.new(0, 100, 0, 36)
button.Position = UDim2.new(0, 10, 0.4, 0)
button.Text = "Build"
button.TextSize = 14
button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local panel = Instance.new("Frame")
panel.Name = "BuildPanel"
panel.Size = UDim2.new(0, 180, 0, 200)
panel.Position = UDim2.new(0, 10, 0.45, 0)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
panel.BackgroundTransparency = 0.2
panel.Visible = false
panel.Parent = gui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 4)
list.Parent = panel

local function refresh()
    for _, child in ipairs(panel:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for id, item in pairs(BuildingCatalog) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.Text = item.name .. " (" .. item.costCoins .. ")"
        btn.TextSize = 12
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = panel
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            -- Simple place in front of player; server validates bounds and cost.
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local root = char.HumanoidRootPart
            local look = root.CFrame.LookVector
            local pos = root.Position + look * 8 + Vector3.new(0, 2, 0)
            remote:FireServer(id, { x = pos.X, y = pos.Y, z = pos.Z })
            panel.Visible = false
        end)
    end
end

button.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then refresh() end
end)

-- Responsive: on small screens the panel stays compact and left-aligned.
