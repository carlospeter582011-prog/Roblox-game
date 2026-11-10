-- Compact, temporary crafting feedback for touch and desktop.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("SkyCraftingResult")
local gui = Instance.new("ScreenGui")
gui.Name = "SkyCraftingFeedback"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.78, 0, 0, 48)
label.Position = UDim2.new(0.11, 0, 0.77, 0)
label.BackgroundTransparency = 0.2
label.BackgroundColor3 = Color3.fromRGB(20, 34, 54)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.TextWrapped = true
label.Visible = false
label.Parent = gui
local sequence = 0
remote.OnClientEvent:Connect(function(ok, message)
    sequence += 1
    local current = sequence
    label.Text = tostring(message)
    label.TextColor3 = ok and Color3.fromRGB(150, 255, 185) or Color3.fromRGB(255, 193, 170)
    label.Visible = true
    task.delay(3, function()
        if sequence == current then label.Visible = false end
    end)
end)
