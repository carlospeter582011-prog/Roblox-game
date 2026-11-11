-- Native 3D sanctuary for donating duplicate clouds. All inventory and rewards are server authoritative.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local altar = Instance.new("Model")
altar.Name = "CloudSanctuary3D"
altar.Parent = Workspace
local base = Instance.new("Part")
base.Name = "OfferingPedestal"
base.Anchored = true
base.Size = Vector3.new(9, 2, 9)
base.Position = Vector3.new(12, 5, -15)
base.Material = Enum.Material.Slate
base.Color = Color3.fromRGB(112, 141, 174)
base.Parent = altar
local orb = Instance.new("Part")
orb.Name = "SanctuaryBeacon"
orb.Shape = Enum.PartType.Ball
orb.Size = Vector3.new(3, 3, 3)
orb.Anchored = true
orb.CanCollide = false
orb.Material = Enum.Material.Glass
orb.Color = Color3.fromRGB(139, 218, 246)
orb.Position = base.Position + Vector3.new(0, 3, 0)
orb.Parent = altar
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Offer duplicate cloud"
prompt.ObjectText = "Cloud Sanctuary"
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false
prompt.Parent = base
local last = {}
prompt.Triggered:Connect(function(player)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - base.Position).Magnitude > 14 then return end
    local now = os.clock()
    if now - (last[player] or -100) < 2 then return end
    last[player] = now
    local ok, speciesId, coins, xp = ProfileStore.OfferDuplicate(player)
    if ok then
        player:SetAttribute("LastSanctuaryOffering", speciesId)
        player:SetAttribute("LastSanctuaryReward", "+" .. coins .. " Coins / +" .. xp .. " XP")
    end
end)
Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
