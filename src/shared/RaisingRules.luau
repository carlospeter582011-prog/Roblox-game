-- Pure cloud raising / care rules. No Roblox globals.
-- Used for feeding caught clouds to increase bond and prepare for evolution/fusion.
local Rules = {}

Rules.FEED_COST = 25
Rules.BOND_PER_FEED = 10
Rules.MAX_BOND = 1000
Rules.EVOLUTION_BOND = 500

function Rules.canFeed(coins, bond)
    return type(coins) == "number" and coins >= Rules.FEED_COST
        and type(bond) == "number" and bond >= 0 and bond < Rules.MAX_BOND
end

function Rules.applyFeed(data, speciesId)
    if not data or type(data.coins) ~= "number" or type(data.companionBond) ~= "table" then
        return false, "invalid_data"
    end
    local current = data.companionBond[speciesId] or 0
    if not Rules.canFeed(data.coins, current) then
        return false, "cannot_feed"
    end
    data.coins -= Rules.FEED_COST
    data.companionBond[speciesId] = math.min(Rules.MAX_BOND, current + Rules.BOND_PER_FEED)
    return true, data.companionBond[speciesId]
end

function Rules.canEvolve(bond)
    return type(bond) == "number" and bond >= Rules.EVOLUTION_BOND
end

return Rules
