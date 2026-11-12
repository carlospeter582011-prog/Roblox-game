-- Pure, deterministic rules for the Cloud Nursery raising station.
-- Never trusts client input. All costs and outcomes are server-calculated.
local Rules = {}

-- Cost in Coins to advance one bond point on a companion.
function Rules.raiseCost(bondPoints)
    if type(bondPoints) ~= "number" or bondPoints ~= bondPoints or bondPoints < 0 then
        return 50
    end
    local level = 0
    if bondPoints >= 100 then level = 3
    elseif bondPoints >= 40 then level = 2
    elseif bondPoints >= 10 then level = 1
    end
    return 25 + level * 15
end

-- Returns true if the player can raise the given companion right now.
function Rules.canRaise(companionId, coins, bond, species, catalog)
    if type(companionId) ~= "string" or catalog[companionId] == nil then
        return false
    end
    if type(species) ~= "table" or type(species[companionId]) ~= "number" or species[companionId] < 1 then
        return false
    end
    local points = type(bond) == "table" and type(bond[companionId]) == "number" and bond[companionId] or 0
    if points ~= points or points < 0 or points >= 1000000 then
        return false
    end
    if type(coins) ~= "number" or coins ~= coins or coins < 0 or coins == math.huge then
        return false
    end
    return coins >= Rules.raiseCost(points)
end

-- Apply a successful raise: deduct cost, advance bond by 1 (capped).
-- Returns newCoins, newBondPoints or nil if invalid.
function Rules.applyRaise(companionId, coins, bond, species, catalog)
    if not Rules.canRaise(companionId, coins, bond, species, catalog) then
        return nil
    end
    local points = type(bond) == "table" and type(bond[companionId]) == "number" and bond[companionId] or 0
    local cost = Rules.raiseCost(points)
    local newCoins = coins - cost
    local newPoints = math.min(points + 1, 1000000)
    return newCoins, newPoints
end

return Rules
