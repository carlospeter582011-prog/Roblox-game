-- Touch and keyboard glide control, available after five catches.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RequestCloudGlide")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudGlideControls"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Name = "Glide"
button.Size = UDim2.fromOffset(96, 42)
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(1, -14, 1, -175)
button.Text = "GLIDE"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(35, 97, 145)
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
local function update()
    local captures = player:GetAttribute("Caught") or player:GetAttribute("Captures") or 0
    button.Visible = captures >= 5
    button.Text = player:GetAttribute("CloudGliding") and "GLIDING" or "GLIDE"
end
button.Activated:Connect(function() remote:FireServer() end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then remote:FireServer() end
end)
player.AttributeChanged:Connect(update)
update()
