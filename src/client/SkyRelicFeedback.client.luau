-- Small, transient HUD feedback for server-authoritative 3D forge prompts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gui = Instance.new("ScreenGui")
gui.Name = "SkyRelicFeedback"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "CraftResult"
label.AnchorPoint = Vector2.new(0.5, 1)
label.Position = UDim2.new(0.5, 0, 1, -90)
label.Size = UDim2.new(0.75, 0, 0, 52)
label.TextScaled = true
label.TextWrapped = true
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundColor3 = Color3.fromRGB(27, 63, 95)
label.Visible = false
label.Parent = gui
local generation = 0
ReplicatedStorage:WaitForChild("RelicCraftFeedback").OnClientEvent:Connect(function(ok, message)
    generation += 1
    local token = generation
    label.Text = tostring(message)
    label.BackgroundColor3 = ok and Color3.fromRGB(29, 110, 80) or Color3.fromRGB(124, 65, 56)
    label.Visible = true
    task.delay(3, function()
        if generation == token then label.Visible = false end
    end)
end)
