-- Pure server-side eligibility guards for cloud catches.
-- Keep checks independent of Roblox globals for regression testing.
local Rules = {}

function Rules.validDistance(distance)
    return type(distance) == "number" and distance == distance
        and distance >= 0 and distance < math.huge
end

function Rules.canCatch(alive, distance, radius, cooldownElapsed, cooldown)
    return alive == true
        and Rules.validDistance(distance)
        and Rules.validDistance(radius)
        and distance <= radius
        and Rules.validDistance(cooldownElapsed)
        and Rules.validDistance(cooldown)
        and cooldownElapsed >= cooldown
end

return Rules
