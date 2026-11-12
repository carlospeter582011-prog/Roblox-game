-- Cloud Nursery: server-owned 3D raising station.
-- Players interact via ProximityPrompt to spend Coins and advance companion Bond.
-- All validation and mutation happen on the server; no client authority.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NurseryRules = require(ReplicatedStorage.Shared.NurseryRules)
local CompanionRules = require(ReplicatedStorage.Shared.CompanionRules)
local ProfileStore = require(script.Parent.ProfileStore)

local STATION_POSITION = Vector3.new(-20, 5, 25)
local MAX_DISTANCE = 12
local COOLDOWN = 4

local lastUse = {}

local function createNursery()
    local model = Instance.new("Model")
    model.Name = "CloudNursery"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(8, 1, 8)
    base.Position = STATION_POSITION
    base.Anchored = true
    base.Material = Enum.Material.Marble
    base.Color = Color3.fromRGB(220, 240, 255)
    base.Parent = model

    local canopy = Instance.new("Part")
    canopy.Name = "Canopy"
    canopy.Size = Vector3.new(7, 0.4, 7)
    canopy.Position = STATION_POSITION + Vector3.new(0, 4, 0)
    canopy.Anchored = true
    canopy.Material = Enum.Material.SmoothPlastic
    canopy.Color = Color3.fromRGB(180, 220, 255)
    canopy.Transparency = 0.3
    canopy.Parent = model

    for i = 1, 4 do
        local post = Instance.new("Part")
        post.Name = "Post" .. i
        post.Size = Vector3.new(0.6, 4, 0.6)
        local angle = (i - 1) * math.pi / 2
        post.Position = STATION_POSITION + Vector3.new(math.cos(angle) * 3, 2, math.sin(angle) * 3)
        post.Anchored = true
        post.Material = Enum.Material.Wood
        post.Color = Color3.fromRGB(160, 140, 110)
        post.Parent = model
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Raise Companion"
    prompt.ObjectText = "Cloud Nursery"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = MAX_DISTANCE
    prompt.Parent = base

    model.PrimaryPart = base
    model.Parent = workspace
    return model, prompt
end

local nursery, prompt = createNursery()

prompt.Triggered:Connect(function(player)
    local now = os.clock()
    if lastUse[player] and now - lastUse[player] < COOLDOWN then
        return
    end
    lastUse[player] = now

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - STATION_POSITION).Magnitude > MAX_DISTANCE + 2 then
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local profile = ProfileStore.Get(player)
    if not profile or not profile.data then
        return
    end

    local companionId = profile.data.companionSpecies
    if type(companionId) ~= "string" or companionId == "" then
        return
    end

    local coins = profile.data.coins or 0
    local bond = profile.data.companionBond or {}
    local species = profile.data.species or {}

    local catalog = require(ReplicatedStorage.Shared.CloudCatalog)
    if not NurseryRules.canRaise(companionId, coins, bond, species, catalog) then
        return
    end

    local newCoins, newPoints = NurseryRules.applyRaise(companionId, coins, bond, species, catalog)
    if not newCoins then
        return
    end

    profile.data.coins = newCoins
    if type(profile.data.companionBond) ~= "table" then
        profile.data.companionBond = {}
    end
    profile.data.companionBond[companionId] = newPoints

    -- Replicate updated attributes if the existing system expects them.
    player:SetAttribute("Coins", newCoins)
    player:SetAttribute("CompanionBond_" .. companionId, newPoints)
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
