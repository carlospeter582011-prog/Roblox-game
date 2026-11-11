-- Pure evolution rules for Catch a Cloud. No Roblox globals.
-- Deterministic, server-authoritative proposals only.
local Catalog = require("./CloudCatalog")

local Rules = {}

-- Example paths: base species evolves into a rarer one after thresholds.
-- In production expand to full tree; these are launch-compatible starters.
Rules.Paths = {
    breeze = { into = "cirrus", minCopies = 5, coinCost = 50, xpRequired = 100 },
    drizzle = { into = "mistveil", minCopies = 5, coinCost = 60, xpRequired = 120 },
    mist = { into = "tide", minCopies = 4, coinCost = 55, xpRequired = 110 },
    spring = { into = "blossom", minCopies = 6, coinCost = 40, xpRequired = 80 },
    thunder = { into = "stormfront", minCopies = 3, coinCost = 150, xpRequired = 300 },
    frost = { into = "glacier", minCopies = 3, coinCost = 140, xpRequired = 280 },
    ember = { into = "emberglow", minCopies = 3, coinCost = 160, xpRequired = 320 },
    sunbeam = { into = "solar", minCopies = 4, coinCost = 100, xpRequired = 200 },
}

function Rules.canEvolve(speciesId, copies, coins, playerXp)
    local path = Rules.Paths[speciesId]
    if not path or not Catalog[speciesId] or not Catalog[path.into] then
        return false, "invalid_path"
    end
    if type(copies) ~= "number" or copies < path.minCopies then
        return false, "insufficient_copies"
    end
    if type(coins) ~= "number" or coins < path.coinCost then
        return false, "insufficient_coins"
    end
    if type(playerXp) ~= "number" or playerXp < path.xpRequired then
        return false, "insufficient_xp"
    end
    return true, path
end

function Rules.proposeEvolution(speciesId, copies, coins, playerXp)
    local ok, pathOrReason = Rules.canEvolve(speciesId, copies, coins, playerXp)
    if not ok then
        return { ok = false, reason = pathOrReason }
    end
    local path = pathOrReason
    return {
        ok = true,
        consumeCopies = path.minCopies,
        consumeCoins = path.coinCost,
        resultSpecies = path.into,
        -- preserve remaining copies of base; result gets 1
    }
end

return Rules
