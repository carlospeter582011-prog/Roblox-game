-- Pure, server-authoritative rules for restorative sky wells.
local Rules = {}
Rules.COOLDOWN = 90
Rules.MAX_DISTANCE = 14
Rules.HEAL_FRACTION = 0.35

function Rules.canUse(distance, health, maxHealth, elapsed, ready)
    if ready ~= true then return false end
    for _, n in ipairs({distance, health, maxHealth, elapsed}) do
        if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then return false end
    end
    return distance >= 0 and distance <= Rules.MAX_DISTANCE
        and maxHealth > 0 and maxHealth <= 100000
        and health > 0 and health < maxHealth
        and elapsed >= Rules.COOLDOWN
end

function Rules.healedHealth(health, maxHealth)
    if type(health) ~= "number" or type(maxHealth) ~= "number" then return nil end
    if health ~= health or maxHealth ~= maxHealth or health == math.huge or health == -math.huge or maxHealth == math.huge or maxHealth == -math.huge then return nil end
    if maxHealth <= 0 or maxHealth > 100000 or health <= 0 or health >= maxHealth then return nil end
    return math.min(maxHealth, health + math.max(1, math.floor(maxHealth * Rules.HEAL_FRACTION)))
end
return table.freeze(Rules)
