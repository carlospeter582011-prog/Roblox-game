-- Server-authoritative Cloud Evolution Altar. Original native Roblox 3D Parts/Model.
-- No external assets. Validates profile, health, distance, stock, coins, bond and cooldown.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local EvolutionRules = require(ReplicatedStorage:WaitForChild("EvolutionRules"))
local CloudCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local CatchRules = require(ReplicatedStorage:WaitForChild("CatchRules"))

local ALTAR_POS = Vector3.new(25, 5, 15) -- near starter island, not overlapping known stations
local COOLDOWN = 8 -- seconds per player
local lastUse = {}

local function createAltar()
    local model = Instance.new("Model")
    model.Name = "CloudEvolutionAltar"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(6, 1, 6)
    base.Position = ALTAR_POS
    base.Anchored = true
    base.Material = Enum.Material.Marble
    base.Color = Color3.fromRGB(220, 230, 255)
    base.Parent = model

    local pillar = Instance.new("Part")
    pillar.Name = "Pillar"
    pillar.Size = Vector3.new(2, 4, 2)
    pillar.Position = ALTAR_POS + Vector3.new(0, 2.5, 0)
    pillar.Anchored = true
    pillar.Material = Enum.Material.Neon
    pillar.Color = Color3.fromRGB(180, 140, 255)
    pillar.Parent = model

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Evolve Cloud"
    prompt.ObjectText = "Evolution Altar"
    prompt.HoldDuration = 0.8
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = pillar

    model.Parent = workspace
    return model, prompt
end

local altar, prompt = createAltar()

prompt.Triggered:Connect(function(player)
    local now = os.clock()
    if lastUse[player] and now - lastUse[player] < COOLDOWN then return end
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end
    if (hrp.Position - ALTAR_POS).Magnitude > 12 then return end

    local data = Profile.Get(player)
    if not data then return end

    -- Prefer equipped companion if it has a recipe, else first owned with recipe
    local inputId = data.companionSpecies
    if not EvolutionRules.getRecipe(inputId) then
        for id in pairs(data.species or {}) do
            if EvolutionRules.getRecipe(id) then inputId = id break end
        end
    end
    if not inputId or not EvolutionRules.getRecipe(inputId) then return end

    local ok, recipeOrErr = EvolutionRules.canEvolve(inputId, data.species, data.coins, data.companionBond, CloudCatalog)
    if not ok then
        return
    end

    local newSpecies, newCoins, outputId = EvolutionRules.apply(inputId, data.species, data.coins, data.companionBond, CloudCatalog)
    if not newSpecies then return end

    data.species = newSpecies
    data.coins = newCoins
    player:SetAttribute("CloudCoins", data.coins)
    if CatchRules.isAttributeSafe("SpeciesCount_" .. inputId) then
        player:SetAttribute("SpeciesCount_" .. inputId, data.species[inputId] or 0)
    end
    if CatchRules.isAttributeSafe("SpeciesCount_" .. outputId) then
        player:SetAttribute("SpeciesCount_" .. outputId, data.species[outputId] or 0)
    end
    lastUse[player] = now
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
