-- Pure evolution rules for Catch a Cloud. No Roblox globals.
-- Players can evolve owned species by spending duplicate catches and coins
-- for a higher-stage form that is added to the collection.
local Rules = {}

Rules.EVOLVE_COST_COINS = 100
Rules.EVOLVE_MIN_COUNT = 5
Rules.EVOLVED_SUFFIX = "_evolved"

function Rules.canEvolve(speciesId, count, coins)
    if type(speciesId) ~= "string" or #speciesId == 0 or #speciesId > 40 then
        return false
    end
    if type(count) ~= "number" or count < Rules.EVOLVE_MIN_COUNT then
        return false
    end
    if type(coins) ~= "number" or coins < Rules.EVOLVE_COST_COINS then
        return false
    end
    -- Prevent evolving an already evolved form for this simple system.
    if string.find(speciesId, Rules.EVOLVED_SUFFIX, 1, true) then
        return false
    end
    return true
end

function Rules.evolvedId(speciesId)
    return speciesId .. Rules.EVOLVED_SUFFIX
end

-- Mutates data: spends coins and one unit of the base species, awards the evolved form.
-- Returns true on success.
function Rules.applyEvolve(data, speciesId)
    if not Rules.canEvolve(speciesId, data.species[speciesId] or 0, data.coins or 0) then
        return false
    end
    data.coins -= Rules.EVOLVE_COST_COINS
    data.species[speciesId] = data.species[speciesId] - 1
    local evolved = Rules.evolvedId(speciesId)
    data.species[evolved] = (data.species[evolved] or 0) + 1
    data.xp += 50
    return true
end

return Rules
