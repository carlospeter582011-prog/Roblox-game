-- Accessible fusion feedback; world altar itself is native 3D geometry.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SkyFusionFeedback"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local notice = Instance.new("TextLabel")
notice.Name = "FusionNotice"
notice.AnchorPoint = Vector2.new(0.5, 0)
notice.Position = UDim2.new(0.5, 0, 0, 18)
notice.Size = UDim2.new(0.82, 0, 0, 48)
notice.TextScaled = true
notice.TextWrapped = true
notice.Font = Enum.Font.GothamBold
notice.BackgroundColor3 = Color3.fromRGB(30, 58, 91)
notice.TextColor3 = Color3.fromRGB(244, 251, 255)
notice.Visible = false
notice.Parent = gui
local constraint = Instance.new("UITextSizeConstraint")
constraint.MaxTextSize = 18
constraint.MinTextSize = 10
constraint.Parent = notice
local version = 0
player:GetAttributeChangedSignal("LastFusionResult"):Connect(function()
    version += 1
    local current = version
    notice.Text = tostring(player:GetAttribute("LastFusionResult") or "")
    notice.Visible = true
    task.delay(3, function()
        if current == version then notice.Visible = false end
    end)
end)
