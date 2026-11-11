-- Pure evolution rules for Catch a Cloud. No Roblox globals.
-- Species evolve to a higher form after reaching a catch threshold of the base species.
-- Evolved forms must exist in the catalog; evolution is server-authoritative and idempotent.
local Rules = {}

-- Stable evolution recipes: baseId -> { evolvedId, threshold }
Rules.RECIPES = {
    breeze = { evolvedId = "gale", threshold = 10 },
    drizzle = { evolvedId = "monsoon", threshold = 8 },
    mist = { evolvedId = "mistveil", threshold = 12 },
    sunbeam = { evolvedId = "solar", threshold = 6 },
    frost = { evolvedId = "glacier", threshold = 7 },
    ember = { evolvedId = "emberglow", threshold = 5 },
    pebble = { evolvedId = "geode", threshold = 15 },
    spring = { evolvedId = "blossom", threshold = 9 },
}

function Rules.getRecipe(speciesId)
    return Rules.RECIPES[speciesId]
end

-- Returns the evolved species id if the current count of base meets or exceeds threshold, else nil.
-- Does not mutate; caller decides how to record the evolution.
function Rules.checkEvolution(speciesId, currentCount)
    local recipe = Rules.getRecipe(speciesId)
    if not recipe or type(currentCount) ~= "number" or currentCount < 0 or currentCount ~= currentCount then
        return nil
    end
    if currentCount >= recipe.threshold then
        return recipe.evolvedId
    end
    return nil
end

-- Applies evolution if eligible: increments the evolved species count by 1 (once per eligibility check),
-- returns the evolvedId or nil. Mutates data.species. Safe to call after every catch of base.
function Rules.tryEvolve(data, speciesId)
    if type(data) ~= "table" or type(data.species) ~= "table" then
        return nil
    end
    local count = data.species[speciesId] or 0
    local evolvedId = Rules.checkEvolution(speciesId, count)
    if evolvedId then
        -- Record that this evolution has been claimed to prevent repeated awards on every subsequent catch.
        data.evolutions = data.evolutions or {}
        if not data.evolutions[speciesId] then
            data.evolutions[speciesId] = true
            data.species[evolvedId] = (data.species[evolvedId] or 0) + 1
            return evolvedId
        end
    end
    return nil
end

return Rules
