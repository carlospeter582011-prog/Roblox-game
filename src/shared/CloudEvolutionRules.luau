-- Pure cloud evolution domain rules. Server must own all inventory and currency.
-- Evolving consumes one spare specimen of the base species + coins, produces one evolved form.
-- Always preserve at least one of the base if the player has only one (protection).
local Rules = {}

local EVOLUTIONS = {
    breeze = { into = "gale", costCoins = 50, minBond = 10, minLevel = 2 },
    drizzle = { into = "monsoon", costCoins = 60, minBond = 10, minLevel = 2 },
    spring = { into = "blossom", costCoins = 40, minBond = 5, minLevel = 1 },
    pebble = { into = "geode", costCoins = 80, minBond = 20, minLevel = 3 },
    frost = { into = "glacier", costCoins = 70, minBond = 15, minLevel = 2 },
}

function Rules.canEvolve(speciesId, speciesCounts, coins, bondPoints, playerLevel, catalog)
    if type(speciesId) ~= "string" or not EVOLUTIONS[speciesId] then return false, "no_path" end
    local evo = EVOLUTIONS[speciesId]
    if not catalog or not catalog[evo.into] then return false, "missing_target" end
    local count = type(speciesCounts) == "table" and type(speciesCounts[speciesId]) == "number" and speciesCounts[speciesId] or 0
    if count < 2 then return false, "need_spare" end -- protect last specimen
    if type(coins) ~= "number" or coins < evo.costCoins or coins ~= coins then return false, "insufficient_coins" end
    if type(bondPoints) ~= "number" or bondPoints < evo.minBond then return false, "insufficient_bond" end
    if type(playerLevel) ~= "number" or playerLevel < evo.minLevel then return false, "level_too_low" end
    return true, evo
end

function Rules.applyEvolution(speciesId, speciesCounts, coins, bondPoints, playerLevel, catalog)
    local ok, evoOrReason = Rules.canEvolve(speciesId, speciesCounts, coins, bondPoints, playerLevel, catalog)
    if not ok then return nil, evoOrReason end
    local evo = evoOrReason
    local newCounts = {}
    for k, v in pairs(speciesCounts or {}) do newCounts[k] = v end
    newCounts[speciesId] = newCounts[speciesId] - 1
    newCounts[evo.into] = (newCounts[evo.into] or 0) + 1
    return {
        species = newCounts,
        coins = coins - evo.costCoins,
        evolvedTo = evo.into,
        consumed = speciesId,
    }
end

return Rules
