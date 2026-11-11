-- Native 3D companion training station. All spending and bond changes are server-owned.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CompanionTrainingRules"))
local CompanionRules = require(ReplicatedStorage:WaitForChild("CompanionRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local lastTraining = {}
local station = Instance.new("Model")
station.Name = "CompanionTrainingShrine3D"
local base = Instance.new("Part")
base.Name = "TrainingPedestal"
base.Anchored = true
base.Size = Vector3.new(7, 1.5, 7)
base.Material = Enum.Material.Slate
base.Color = Color3.fromRGB(91, 113, 151)
base.Parent = station
local orb = Instance.new("Part")
orb.Name = "BondOrb"
orb.Shape = Enum.PartType.Ball
orb.Anchored = true
orb.CanCollide = false
orb.Size = Vector3.new(3, 3, 3)
orb.Material = Enum.Material.Neon
orb.Color = Color3.fromRGB(126, 221, 244)
orb.Parent = station
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Train companion (75 Coins)"
prompt.ObjectText = "Bond Shrine"
prompt.MaxActivationDistance = 10
prompt.HoldDuration = 0.5
prompt.RequiresLineOfSight = false
prompt.Parent = base
station.Parent = workspace
local function positionStation()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if not spawn then return false end
    local at = spawn.Position + spawn.CFrame.RightVector * 13
    base.Position = at + Vector3.new(0, 0.75, 0)
    orb.Position = at + Vector3.new(0, 3, 0)
    return true
end
task.spawn(function()
    for _ = 1, 30 do
        if positionStation() then return end
        task.wait(1)
    end
    warn("Bond shrine could not locate a SpawnLocation; interactions disabled")
    prompt.Enabled = false
end)
prompt.Triggered:Connect(function(player)
    if not prompt.Enabled or not player:IsA("Player") or not player:GetAttribute("ProfileReady") then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 or (root.Position - base.Position).Magnitude > 12 then return end
    local data = Profile.Get(player)
    if not data then return end
    local speciesId = data.companionSpecies
    local owned = CompanionRules.owned(speciesId, data.species, Catalog)
    local points = owned and ((data.companionBond or {})[speciesId] or 0) or 0
    local now = os.clock()
    local proposal = Rules.propose(data.coins, points, owned, now, lastTraining[player])
    if not proposal then return end
    -- No yields between validation and mutation; only the server writes profile data.
    data.coins = proposal.coins
    data.companionBond = data.companionBond or {}
    data.companionBond[speciesId] = proposal.bond
    lastTraining[player] = proposal.at
    player:SetAttribute("CloudCoins", proposal.coins)
    player:SetAttribute("CompanionBondPoints", proposal.bond)
    player:SetAttribute("CompanionBondLevel", CompanionRules.bondLevel(proposal.bond))
end)
Players.PlayerRemoving:Connect(function(player) lastTraining[player] = nil end)
