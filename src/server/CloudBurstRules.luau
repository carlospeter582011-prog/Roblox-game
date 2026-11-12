-- Pure post-yield burst safety: no stale target, dead character, or distant rewards.
local Rules = {}
function Rules.canReward(activeTarget, target, characterReady, health, distance, normalRange, magnetRange)
    return activeTarget == target and target ~= nil and characterReady == true
        and type(health) == "number" and health > 0 and health < math.huge
        and type(distance) == "number" and distance >= 0 and distance < math.huge
        and (normalRange == true or magnetRange == true)
end
return Rules
