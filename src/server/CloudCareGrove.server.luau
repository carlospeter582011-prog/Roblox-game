-- Original native 3D Cloud Care Grove; no client remotes or imported assets.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudCareRules"))
local lastCare = {}
local grove = Instance.new("Model")
grove.Name = "CloudCareGrove"
grove.Parent = workspace
local pedestal = Instance.new("Part")
pedestal.Name = "CarePedestal"
pedestal.Size = Vector3.new(7, 2, 7)
pedestal.Position = Vector3.new(17, 8, -15)
pedestal.Anchored = true
pedestal.Material = Enum.Material.SmoothPlastic
pedestal.Color = Color3.fromRGB(144, 205, 225)
pedestal.Parent = grove
local halo = Instance.new("Part")
halo.Name = "CareHalo"
halo.Shape = Enum.PartType.Ball
halo.Size = Vector3.new(3, 3, 3)
halo.Position = pedestal.Position + Vector3.new(0, 3, 0)
halo.Anchored = true
halo.CanCollide = false
halo.Material = Enum.Material.Neon
halo.Color = Color3.fromRGB(162, 239, 199)
halo.Parent = grove
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Care for companion (45 Coins)"
prompt.ObjectText = "Cloud Care Grove"
prompt.MaxActivationDistance = 10
prompt.HoldDuration = 0.7
prompt.RequiresLineOfSight = false
prompt.Parent = pedestal
prompt.Triggered:Connect(function(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 or (root.Position - pedestal.Position).Magnitude > 13 then return end
    local now = os.time()
    local elapsed = now - (lastCare[player] or (now - Rules.COOLDOWN))
    local ok, reason = Profile.CareForCompanion(player, elapsed)
    if ok then lastCare[player] = now end
    player:SetAttribute("CloudCareStatus", ok and "Companion cared for!" or reason)
end)
Players.PlayerRemoving:Connect(function(player) lastCare[player] = nil end)
