-- Pure evolution rules for Catch a Cloud. No Roblox globals.
-- Evolution consumes duplicate base species + Coins to grant a higher-tier catalog species.
local Rules = {}

-- Hard-coded safe chains using existing catalog species. Expand as needed.
Rules.EVOLUTIONS = {
    breeze = { result = "gale", requiredCount = 5, coinCost = 40, xpReward = 20 },
    drizzle = { result = "monsoon", requiredCount = 4, coinCost = 50, xpReward = 25 },
    mist = { result = "mistveil", requiredCount = 4, coinCost = 45, xpReward = 22 },
    sunbeam = { result = "solar", requiredCount = 3, coinCost = 60, xpReward = 30 },
    thunder = { result = "stormfront", requiredCount = 3, coinCost = 80, xpReward = 40 },
    frost = { result = "glacier", requiredCount = 3, coinCost = 70, xpReward = 35 },
    ember = { result = "emberglow", requiredCount = 3, coinCost = 75, xpReward = 38 },
    pebble = { result = "pebbleflow", requiredCount = 5, coinCost = 35, xpReward = 18 },
}

local function isSafeCount(n)
    return type(n) == "number" and n == n and n >= 0 and n < 100000
end

function Rules.canEvolve(speciesId, data, catalog)
    if type(speciesId) ~= "string" or type(data) ~= "table" or type(catalog) ~= "table" then
        return false, "invalid_input"
    end
    local evo = Rules.EVOLUTIONS[speciesId]
    if not evo or not catalog[speciesId] or not catalog[evo.result] then
        return false, "no_evolution"
    end
    local count = data.species and data.species[speciesId] or 0
    if not isSafeCount(count) or count < evo.requiredCount then
        return false, "insufficient_species"
    end
    local coins = data.coins or 0
    if not isSafeCount(coins) or coins < evo.coinCost then
        return false, "insufficient_coins"
    end
    return true, evo
end

-- Mutates data in place on success. Caller must own the profile and persist.
function Rules.applyEvolve(speciesId, data, catalog)
    local ok, evoOrReason = Rules.canEvolve(speciesId, data, catalog)
    if not ok then
        return false, evoOrReason
    end
    local evo = evoOrReason
    data.species = data.species or {}
    data.species[speciesId] = (data.species[speciesId] or 0) - evo.requiredCount
    if data.species[speciesId] <= 0 then
        data.species[speciesId] = nil
    end
    data.species[evo.result] = (data.species[evo.result] or 0) + 1
    data.coins = (data.coins or 0) - evo.coinCost
    data.xp = (data.xp or 0) + evo.xpReward
    return true, evo.result, evo.xpReward
end

return Rules
