-- Server-owned companion training economy. Pure calculations; no client-provided prices.
local Rules = {}
Rules.MAX_BOND = 1000000
Rules.TRAINING_GAIN = 8
Rules.COOLDOWN = 45
local function integer(value, max)
    return type(value) == "number" and value == value and value ~= math.huge
        and value ~= -math.huge and value >= 0 and value <= max
        and value == math.floor(value)
end
function Rules.price(points)
    if not integer(points, Rules.MAX_BOND) then return nil end
    return 35 + math.min(165, math.floor(points / 40) * 5)
end
function Rules.train(coins, speciesId, species, bond, catalog)
    if not integer(coins, 1000000000000) then return nil, "Invalid wallet" end
    if type(speciesId) ~= "string" or not catalog[speciesId]
        or type(species) ~= "table" or not integer(species[speciesId], 1000000000)
        or species[speciesId] < 1 then return nil, "Equip an owned cloud" end
    if type(bond) ~= "table" then return nil, "Invalid bond data" end
    local points = bond[speciesId] or 0
    local cost = Rules.price(points)
    if not cost then return nil, "Invalid bond data" end
    if points >= Rules.MAX_BOND then return nil, "Bond is maxed" end
    if coins < cost then return nil, "Need " .. cost .. " Coins" end
    return { coins = coins - cost, points = math.min(Rules.MAX_BOND, points + Rules.TRAINING_GAIN), cost = cost }
end
return table.freeze(Rules)
