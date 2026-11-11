-- Original native 3D Evolution Altar. Server-authoritative evolution using EvolutionRules.
-- No Canvas; ScreenGui not used here. Procedural Parts only; no external MeshIds.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local EvolutionRules = require(ReplicatedStorage:WaitForChild("EvolutionRules"))
local EvolutionCatalog = require(ReplicatedStorage:WaitForChild("EvolutionCatalog"))
local CloudCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))

local altar = Instance.new("Model")
altar.Name = "EvolutionAltar3D"
altar.Parent = workspace

local base = Instance.new("Part")
base.Name = "AltarBase"
base.Size = Vector3.new(8, 1, 8)
base.Position = Vector3.new(40, 12, 0)
base.Anchored = true
base.Material = Enum.Material.Marble
base.Color = Color3.fromRGB(220, 200, 255)
base.Parent = altar

local pillar = Instance.new("Part")
pillar.Name = "AltarPillar"
pillar.Size = Vector3.new(2, 6, 2)
pillar.Position = Vector3.new(40, 15, 0)
pillar.Anchored = true
pillar.Material = Enum.Material.Neon
pillar.Color = Color3.fromRGB(180, 140, 255)
pillar.Parent = altar

local orb = Instance.new("Part")
orb.Name = "AltarOrb"
orb.Shape = Enum.PartType.Ball
orb.Size = Vector3.new(3, 3, 3)
orb.Position = Vector3.new(40, 18.5, 0)
orb.Anchored = true
orb.Material = Enum.Material.Neon
orb.Color = Color3.fromRGB(255, 220, 255)
orb.Parent = altar

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Evolve Cloud"
prompt.ObjectText = "Evolution Altar"
prompt.HoldDuration = 1
prompt.MaxActivationDistance = 10
prompt.Parent = base

local function notify(player, text)
    -- Simple attribute for client HUD to display; no ScreenGui created here.
    player:SetAttribute("LastEvolutionMessage", text)
end

prompt.Triggered:Connect(function(player)
    local data = Profile.Get(player)
    if not data then
        notify(player, "Profile not ready")
        return
    end
    -- Prefer equipped companion if it has a path; otherwise first eligible.
    local chosenId = nil
    local companion = data.companionSpecies
    for id, path in pairs(EvolutionCatalog) do
        if path.sourceId == companion then
            local ok = EvolutionRules.canEvolve(data, id)
            if ok then
                chosenId = id
                break
            end
        end
    end
    if not chosenId then
        for id, _ in pairs(EvolutionCatalog) do
            local ok = EvolutionRules.canEvolve(data, id)
            if ok then
                chosenId = id
                break
            end
        end
    end
    if not chosenId then
        notify(player, "No eligible evolution available")
        return
    end
    local ok, path = EvolutionRules.applyEvolution(data, chosenId)
    if not ok then
        notify(player, tostring(path))
        return
    end
    -- Update attributes for HUD.
    player:SetAttribute("CloudCoins", data.coins)
    local sourceCount = data.species[path.sourceId] or 0
    local targetCount = data.species[path.targetId] or 0
    if sourceCount > 0 then
        player:SetAttribute("SpeciesCount_" .. path.sourceId, sourceCount)
    else
        player:SetAttribute("SpeciesCount_" .. path.sourceId, 0)
    end
    player:SetAttribute("SpeciesCount_" .. path.targetId, targetCount)
    local sourceName = CloudCatalog[path.sourceId] and CloudCatalog[path.sourceId].name or path.sourceId
    local targetName = CloudCatalog[path.targetId] and CloudCatalog[path.targetId].name or path.targetId
    notify(player, sourceName .. " evolved into " .. targetName .. "!")
    -- Force a save.
    Profile.Save(player)
end)

print("Evolution Altar 3D placed at (40, 12, 0)")
