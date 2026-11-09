-- Mobile and desktop catch button. Server decides whether a catch succeeds.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RequestCloudCatch")
local folder = Workspace:WaitForChild("CatchableClouds")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudCatchHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Name = "CatchButton"
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(1, -20, 1, -35)
button.Size = UDim2.fromOffset(155, 60)
button.BackgroundColor3 = Color3.fromRGB(71, 137, 230)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Text = "Catch Cloud"
button.Parent = gui
local message = Instance.new("TextLabel")
message.Size = UDim2.new(0.8, 0, 0, 42)
message.Position = UDim2.new(0.1, 0, 0.08, 0)
message.BackgroundTransparency = 0.3
message.TextScaled = true
message.Text = "Find a glowing cloud and get close!"
message.Parent = gui
button.Activated:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local nearest, distance = nil, math.huge
    for _, cloud in folder:GetChildren() do
        if cloud:IsA("BasePart") then
            local d = (root.Position - cloud.Position).Magnitude
            if d < distance then nearest, distance = cloud, d end
        end
    end
    if nearest then
        remote:FireServer(nearest:GetAttribute("CloudId"))
    else
        message.Text = "No clouds nearby yet."
    end
end)
remote.OnClientEvent:Connect(function(success, text)
    message.Text = text
    if success then button.Text = "Catch Another" end
end)

local questLabel=Instance.new("TextLabel")
questLabel.Name="QuestTracker"
questLabel.Size=UDim2.new(0.75,0,0,54)
questLabel.Position=UDim2.new(0.125,0,0.16,0)
questLabel.BackgroundColor3=Color3.fromRGB(24,53,91)
questLabel.BackgroundTransparency=0.15
questLabel.TextColor3=Color3.fromRGB(245,250,255)
questLabel.TextScaled=true
questLabel.Parent=gui
local function refreshQuest()
    if not player:GetAttribute("Quest_first_breeze") then
        questLabel.Text="Story: Catch your first Breeze Cloud"
    elseif not player:GetAttribute("Quest_three_clouds") then
        questLabel.Text="Story: Catch 3 clouds ("..tostring(player:GetAttribute("CloudCount") or 0).."/3)"
    else
        questLabel.Text="Chapter 1 complete! More adventures ahead."
    end
end
for _,attribute in ipairs({"Quest_first_breeze","Quest_three_clouds","CloudCount"}) do
    player:GetAttributeChangedSignal(attribute):Connect(refreshQuest)
end
refreshQuest()
