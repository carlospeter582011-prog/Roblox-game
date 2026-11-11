-- Original native Roblox 3D Cloud Habitat station.
-- Players interact via ProximityPrompt to spend Coins for companion Bond.
-- All validation and rewards are server-authoritative. No client remotes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HabitatRules = require(ReplicatedStorage:WaitForChild("HabitatRules"))
local ProfileStore = require(script.Parent.ProfileStore)
local CompanionRules = require(ReplicatedStorage:WaitForChild("CompanionRules"))

local STATION_POSITION = Vector3.new(40, 12, 30) -- near starter island, adjust as needed

local function createHabitatModel()
    local model = Instance.new("Model")
    model.Name = "CloudHabitatStation"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(14, 1, 14)
    base.Position = STATION_POSITION
    base.Anchored = true
    base.Material = Enum.Material.Grass
    base.Color = Color3.fromRGB(120, 200, 140)
    base.Parent = model

    local pool = Instance.new("Part")
    pool.Name = "NurturePool"
    pool.Size = Vector3.new(8, 0.4, 8)
    pool.Position = STATION_POSITION + Vector3.new(0, 0.7, 0)
    pool.Anchored = true
    pool.Material = Enum.Material.Neon
    pool.Color = Color3.fromRGB(100, 220, 255)
    pool.Transparency = 0.3
    pool.Parent = model

    for i = 1, 4 do
        local pillar = Instance.new("Part")
        pillar.Name = "Pillar" .. i
        pillar.Size = Vector3.new(1.2, 6, 1.2)
        local angle = (i - 1) * math.pi / 2
        pillar.Position = STATION_POSITION + Vector3.new(math.cos(angle) * 5, 3.5, math.sin(angle) * 5)
        pillar.Anchored = true
        pillar.Material = Enum.Material.Slate
        pillar.Color = Color3.fromRGB(180, 180, 200)
        pillar.Parent = model
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Nurture Companion"
    prompt.ObjectText = "Cloud Habitat"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 10
    prompt.Parent = pool

    model.PrimaryPart = base
    model.Parent = workspace
    return model, prompt
end

local habitat, prompt = createHabitatModel()

local lastUse = {}
local sessionUses = {}

prompt.Triggered:Connect(function(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - STATION_POSITION).Magnitude > 12 then
        return
    end

    local profile = ProfileStore.Get(player)
    if not profile then return end

    local now = os.time()
    local ok, reason = HabitatRules.canUse(
        profile.coins,
        profile.companionSpecies,
        profile.species,
        profile.companionBond,
        lastUse[player.UserId],
        now,
        sessionUses[player.UserId] or 0
    )
    if not ok then
        return
    end

    local newCoins, newBond = HabitatRules.apply(profile.coins, profile.companionBond, profile.companionSpecies)
    profile.coins = newCoins
    profile.companionBond = profile.companionBond or {}
    profile.companionBond[profile.companionSpecies] = newBond

    lastUse[player.UserId] = now
    sessionUses[player.UserId] = (sessionUses[player.UserId] or 0) + 1

    player:SetAttribute("CloudCoins", profile.coins)
    player:SetAttribute("CompanionBondPoints", newBond)
    player:SetAttribute("CompanionBondLevel", CompanionRules.bondLevel(newBond))

    ProfileStore.Save(player)
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player.UserId] = nil
    sessionUses[player.UserId] = nil
end)
