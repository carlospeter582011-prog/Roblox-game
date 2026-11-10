-- Small, temporary HUD toast for recycler results. The station itself is native 3D.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CloudRecyclerToast"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "Result"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.12)
label.Size = UDim2.new(0.84, 0, 0, 54)
label.BackgroundColor3 = Color3.fromRGB(28, 43, 70)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.TextWrapped = true
label.Visible = false
label.Parent = gui
local constraint = Instance.new("UITextSizeConstraint")
constraint.MaxTextSize = 22
constraint.MinTextSize = 12
constraint.Parent = label
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = label
local revision = 0
player:GetAttributeChangedSignal("RecyclerResult"):Connect(function()
    local message = player:GetAttribute("RecyclerResult")
    if type(message) ~= "string" or message == "" then return end
    revision += 1
    local current = revision
    label.Text = message
    label.Visible = true
    task.delay(3.5, function()
        if revision == current then label.Visible = false end
    end)
end)
