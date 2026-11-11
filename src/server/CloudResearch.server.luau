-- Original 3D observatory: permanent research upgrades purchased with Coins.
local Players = game:GetService("Players")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Research = require(game:GetService("ReplicatedStorage"):WaitForChild("CloudResearchRules"))
local model = Instance.new("Model")
model.Name = "CloudResearchObservatory3D"
local platform = Instance.new("Part")
platform.Name = "ResearchPlatform"
platform.Size = Vector3.new(12, 2, 12)
platform.Position = Vector3.new(-48, 2, 35)
platform.Anchored = true
platform.Material = Enum.Material.Slate
platform.Color = Color3.fromRGB(85, 109, 155)
platform.Parent = model
local dome = Instance.new("Part")
dome.Name = "SkyLens"
dome.Shape = Enum.PartType.Ball
dome.Size = Vector3.new(6, 6, 6)
dome.Position = Vector3.new(-48, 7, 35)
dome.Anchored = true
dome.CanCollide = false
dome.Material = Enum.Material.Glass
dome.Color = Color3.fromRGB(116, 204, 239)
dome.Parent = model
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Buy research"
prompt.ObjectText = "Cloud Observatory"
prompt.MaxActivationDistance = 12
prompt.HoldDuration = 0.5
prompt.RequiresLineOfSight = false
prompt.Parent = platform
model.Parent = workspace
local lastAttempt = {}
prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local now = os.clock()
    if now - (lastAttempt[player] or -100) < 1.5 then return end
    lastAttempt[player] = now
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 or (root.Position - platform.Position).Magnitude > 15 then return end
    if player:GetAttribute("ProfileReady") ~= true then return end
    local ok, message = Profile.BuyCloudResearch(player)
    player:SetAttribute("ResearchFeedback", message)
end)
Players.PlayerRemoving:Connect(function(player) lastAttempt[player] = nil end)
