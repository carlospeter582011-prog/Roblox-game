-- 3D evolution altar: native Roblox Parts + ProximityPrompt. Server-authoritative.
-- No Canvas. Consumes duplicates to produce evolved species. Persists via existing profile.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local EvolutionCatalog = require(ReplicatedStorage:WaitForChild("EvolutionCatalog"))
local EvolutionRules = require(ReplicatedStorage:WaitForChild("EvolutionRules"))
local CloudCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local CatchRules = require(ReplicatedStorage:WaitForChild("CatchRules"))

local altar = Instance.new("Model")
altar.Name = "CloudEvolutionAltar3D"
altar.Parent = Workspace

local base = Instance.new("Part")
base.Name = "AltarBase"
base.Size = Vector3.new(8, 1, 8)
base.Position = Vector3.new(28, 1.5, -18)
base.Anchored = true
base.Color = Color3.fromRGB(140, 100, 220)
base.Material = Enum.Material.Marble
base.Parent = altar

local crystal = Instance.new("Part")
crystal.Name = "EvolutionCrystal"
crystal.Shape = Enum.PartType.Ball
crystal.Size = Vector3.new(4, 6, 4)
crystal.Position = Vector3.new(28, 5, -18)
crystal.Anchored = true
crystal.CanCollide = false
crystal.Material = Enum.Material.Neon
crystal.Color = Color3.fromRGB(200, 160, 255)
crystal.Parent = altar

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Evolve Cloud"
prompt.ObjectText = "Evolution Altar"
prompt.MaxActivationDistance = 10
prompt.HoldDuration = 0.8
prompt.RequiresLineOfSight = false
prompt.Parent = crystal

local lastEvolve = {}

prompt.Triggered:Connect(function(player)
    local profile = ProfileStore.Get(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not profile or not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - crystal.Position).Magnitude > 12 then return end
    local now = os.clock()
    if now - (lastEvolve[player] or -10) < 1.5 then return end
    lastEvolve[player] = now

    -- Evolve the first recipe the player qualifies for (deterministic order).
    local recipeIds = {}
    for id in pairs(EvolutionCatalog) do
        table.insert(recipeIds, id)
    end
    table.sort(recipeIds)
    for _, recipeId in ipairs(recipeIds) do
        local ok, toSpecies = EvolutionRules.applyEvolve(profile, recipeId, EvolutionCatalog, CloudCatalog)
        if ok then
            local recipe = EvolutionCatalog[recipeId]
            -- Update replicated counts for both species.
            if CatchRules.isAttributeSafe("SpeciesCount_" .. recipe.fromSpecies) then
                player:SetAttribute("SpeciesCount_" .. recipe.fromSpecies, profile.species[recipe.fromSpecies] or 0)
            end
            if CatchRules.isAttributeSafe("SpeciesCount_" .. toSpecies) then
                player:SetAttribute("SpeciesCount_" .. toSpecies, profile.species[toSpecies])
            end
            player:SetAttribute("EvolutionFeedback", "Evolved to " .. (CloudCatalog[toSpecies].name or toSpecies))
            return
        end
    end
    player:SetAttribute("EvolutionFeedback", "Need more duplicates to evolve")
end)

Players.PlayerRemoving:Connect(function(player) lastEvolve[player] = nil end)
