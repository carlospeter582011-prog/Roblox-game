-- Server-authoritative 3D Evolution Altar. Original Roblox Parts/Models only.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local EvolutionRules = require(ReplicatedStorage:WaitForChild("EvolutionRules"))
local CloudCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))

local world = Workspace:FindFirstChild("CatchACloudStarterIsland") or Workspace

local altar = Instance.new("Model")
altar.Name = "CloudEvolutionAltar3D"
altar.Parent = world

local base = Instance.new("Part")
base.Name = "AltarBase"
base.Size = Vector3.new(12, 2, 12)
base.Position = Vector3.new(40, 1, 40)
base.Anchored = true
base.Material = Enum.Material.Marble
base.Color = Color3.fromRGB(200, 180, 255)
base.Parent = altar

local pillar = Instance.new("Part")
pillar.Name = "AltarPillar"
pillar.Size = Vector3.new(4, 8, 4)
pillar.Position = Vector3.new(40, 6, 40)
pillar.Anchored = true
pillar.Material = Enum.Material.Neon
pillar.Color = Color3.fromRGB(180, 140, 255)
pillar.Parent = altar

local orb = Instance.new("Part")
orb.Name = "AltarOrb"
orb.Shape = Enum.PartType.Ball
orb.Size = Vector3.new(3, 3, 3)
orb.Position = Vector3.new(40, 11, 40)
orb.Anchored = true
orb.Material = Enum.Material.Glass
orb.Color = Color3.fromRGB(220, 180, 255)
orb.Transparency = 0.3
orb.Parent = altar

altar.PrimaryPart = base

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "EvolveCloud"
prompt.ActionText = "Evolve"
prompt.ObjectText = "Cloud Altar"
prompt.MaxActivationDistance = 14
prompt.HoldDuration = 0.6
prompt.RequiresLineOfSight = false
prompt.Parent = base

local COOLDOWN = 8
local lastUse = {}

prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local now = os.clock()
    if lastUse[player] and now - lastUse[player] < COOLDOWN then return end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - base.Position).Magnitude > 18 then return end

    local data = Profile.Get(player)
    if not data or not player:GetAttribute("ProfileReady") then return end

    -- Prefer equipped companion if evolvable, else first available.
    local targetId = data.companionSpecies
    if not EvolutionRules.EVOLUTIONS[targetId] then
        for id in pairs(EvolutionRules.EVOLUTIONS) do
            local can = EvolutionRules.canEvolve(id, data, CloudCatalog)
            if can then
                targetId = id
                break
            end
        end
    end

    local ok, resultOrReason = EvolutionRules.applyEvolve(targetId, data, CloudCatalog)
    if not ok then
        player:SetAttribute("EvolutionFeedback", "Cannot evolve: " .. tostring(resultOrReason))
        return
    end

    lastUse[player] = now
    -- Refresh attributes
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    for sid, count in pairs(data.species) do
        if type(sid) == "string" and not string.find(sid, ":") then
            player:SetAttribute("SpeciesCount_" .. sid, count)
        end
    end
    -- Clear zeroed
    local baseId = targetId
    if data.species[baseId] == nil then
        player:SetAttribute("SpeciesCount_" .. baseId, 0)
    end

    local resultId = resultOrReason
    local name = CloudCatalog[resultId] and CloudCatalog[resultId].name or resultId
    player:SetAttribute("EvolutionFeedback", "Evolved into " .. name .. "!")
    -- Persist via normal autosave / explicit if available
    if Profile.Save then
        task.spawn(Profile.Save, player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
