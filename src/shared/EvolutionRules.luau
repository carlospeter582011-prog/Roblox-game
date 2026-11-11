-- Pure evolution eligibility and application. No Roblox globals.
local CloudCatalog = require(script.Parent:WaitForChild("CloudCatalog"))
local EvolutionCatalog = require(script.Parent:WaitForChild("EvolutionCatalog"))

local Rules = {}

function Rules.canEvolve(data, pathId)
    local path = EvolutionCatalog[pathId]
    if not path or not data or type(data.species) ~= "table" then
        return false, "Invalid path or profile"
    end
    local source = CloudCatalog[path.sourceId]
    local target = CloudCatalog[path.targetId]
    if not source or not target then
        return false, "Unknown species"
    end
    local owned = math.floor(tonumber(data.species[path.sourceId]) or 0)
    if owned < path.minCatches then
        return false, "Need at least " .. path.minCatches .. " " .. source.name
    end
    if data.coins < path.evolutionCostCoins then
        return false, "Need " .. path.evolutionCostCoins .. " coins"
    end
    if path.minBond > 0 then
        local bond = 0
        if data.companionSpecies == path.sourceId and type(data.companionBond) == "table" then
            bond = math.floor(tonumber(data.companionBond[path.sourceId]) or 0)
        end
        if bond < path.minBond then
            return false, "Need bond " .. path.minBond .. " on " .. source.name
        end
    end
    return true, path
end

-- Mutates data in place on success. Consumes 1 source, adds 1 target, pays coins.
-- Returns true, new counts or false, reason.
function Rules.applyEvolution(data, pathId)
    local ok, pathOrReason = Rules.canEvolve(data, pathId)
    if not ok then
        return false, pathOrReason
    end
    local path = pathOrReason
    data.species[path.sourceId] = (data.species[path.sourceId] or 0) - 1
    if data.species[path.sourceId] <= 0 then
        data.species[path.sourceId] = nil
    end
    data.species[path.targetId] = (data.species[path.targetId] or 0) + 1
    data.coins = data.coins - path.evolutionCostCoins
    return true, path
end

return Rules
