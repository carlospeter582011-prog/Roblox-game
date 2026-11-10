-- Compact accessible fusion result toast; only UI, never a world object.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "FusionFeedbackUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "FusionResult"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.12)
label.Size = UDim2.new(0.78, 0, 0, 48)
label.BackgroundColor3 = Color3.fromRGB(35, 31, 62)
label.BackgroundTransparency = 0.12
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.TextWrapped = true
label.Visible = false
label.Parent = gui
local constraint = Instance.new("UITextSizeConstraint")
constraint.MinTextSize = 12
constraint.MaxTextSize = 20
constraint.Parent = label
local counter = 0
player:GetAttributeChangedSignal("FusionFeedback"):Connect(function()
    counter += 1
    local token = counter
    label.Text = tostring(player:GetAttribute("FusionFeedback") or "")
    label.Visible = label.Text ~= ""
    task.delay(4, function()
        if counter == token then label.Visible = false end
    end)
end)
