-- Pure server-side rules for spending earned Coins on companion bonding.
-- Training never grants a companion or changes species ownership.
local Rules = {}
Rules.COST = 75
Rules.POINTS = 4
Rules.MAX_BOND = 100
Rules.MAX_DISTANCE = 14
function Rules.evaluate(data, catalog, distance, ready)
    if ready ~= true or type(data) ~= "table" then return false, "Profile unavailable" end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE then
        return false, "Move closer to the academy"
    end
    local id = data.companionSpecies
    if type(id) ~= "string" or not catalog[id] or type(data.species) ~= "table"
        or type(data.species[id]) ~= "number" or data.species[id] < 1 then
        return false, "Equip a cloud you own"
    end
    local points = type(data.companionBond) == "table" and data.companionBond[id] or 0
    if type(points) ~= "number" or points ~= points or points < 0 or points == math.huge then
        return false, "Invalid bond"
    end
    if points >= Rules.MAX_BOND then return false, "Companion bond fully trained" end
    if type(data.coins) ~= "number" or data.coins ~= data.coins or data.coins < Rules.COST or data.coins == math.huge then
        return false, "Need 75 Coins"
    end
    return true, id, math.min(Rules.MAX_BOND, math.floor(points) + Rules.POINTS)
end
return Rules
