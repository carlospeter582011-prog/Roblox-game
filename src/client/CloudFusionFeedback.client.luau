-- Mobile-friendly feedback for the server-owned 3D fusion altar.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CloudFusionFeedbackGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "FusionStatus"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.new(0.5, 0, 0, 52)
label.Size = UDim2.new(0.88, 0, 0, 58)
label.BackgroundColor3 = Color3.fromRGB(27, 49, 83)
label.BackgroundTransparency = 0.12
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 15
label.Font = Enum.Font.GothamBold
label.TextWrapped = true
label.Visible = false
label.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = label
local sequence = 0
player:GetAttributeChangedSignal("CloudFusionFeedback"):Connect(function()
    local message = player:GetAttribute("CloudFusionFeedback")
    if type(message) ~= "string" or message == "" then return end
    sequence += 1
    local current = sequence
    label.Text = message
    label.Visible = true
    task.delay(4, function()
        if current == sequence then label.Visible = false end
    end)
end)
