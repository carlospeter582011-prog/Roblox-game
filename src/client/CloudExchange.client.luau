local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("CloudExchangeFeedback")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudExchangeNotice"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "Notice"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.12)
label.Size = UDim2.new(0.85, 0, 0, 48)
label.BackgroundColor3 = Color3.fromRGB(25, 40, 75)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.TextWrapped = true
label.Visible = false
label.Parent = gui
local serial = 0
remote.OnClientEvent:Connect(function(message)
    if type(message) ~= "string" then return end
    serial += 1
    local current = serial
    label.Text = message
    label.Visible = true
    task.delay(3, function() if current == serial then label.Visible = false end end)
end)
