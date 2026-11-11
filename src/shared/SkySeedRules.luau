-- Pure, server-side rules for the repeatable Sky Seed mobility loop.
local Rules = {}
Rules.maxSeeds = 6
Rules.cost = 3
Rules.boostSeconds = 25
Rules.cooldownSeconds = 60
Rules.pickupDistance = 13
Rules.shrineDistance = 15
Rules.speedBonus = 7
local function valid(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.canPickup(count, distance, ready, alive)
    return valid(count) and count >= 0 and count < Rules.maxSeeds
        and valid(distance) and distance >= 0 and distance <= Rules.pickupDistance
        and ready == true and alive == true
end
function Rules.canRedeem(count, distance, ready, alive, now, nextAllowed)
    return valid(count) and count >= Rules.cost and count <= Rules.maxSeeds
        and valid(distance) and distance >= 0 and distance <= Rules.shrineDistance
        and ready == true and alive == true and valid(now) and valid(nextAllowed)
        and now >= nextAllowed
end
return Rules
