-- Pure policy for cooperative sky-well healing; the server owns all inputs.
local Rules = {}
Rules.RADIUS = 17
Rules.HEAL_RADIUS = 20
Rules.COOLDOWN = 120
Rules.HEAL_FRACTION = 0.35
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.eligible(distance, health, maxHealth, now, lastUse)
    if not finite(distance) or distance < 0 or distance > Rules.RADIUS then return false end
    if not finite(health) or not finite(maxHealth) or maxHealth <= 0 or health <= 0 or health > maxHealth then return false end
    if not finite(now) or now < 0 then return false end
    if lastUse ~= nil then
        if not finite(lastUse) or now < lastUse or now - lastUse < Rules.COOLDOWN then return false end
    end
    return health < maxHealth
end
function Rules.healAmount(health, maxHealth)
    if not finite(health) or not finite(maxHealth) or health <= 0 or maxHealth <= 0 or health >= maxHealth then return 0 end
    return math.max(0, math.min(maxHealth - health, math.ceil(maxHealth * Rules.HEAL_FRACTION)))
end
function Rules.allyEligible(distance, health, maxHealth)
    return finite(distance) and distance >= 0 and distance <= Rules.HEAL_RADIUS
        and Rules.healAmount(health, maxHealth) > 0
end
return table.freeze(Rules)
