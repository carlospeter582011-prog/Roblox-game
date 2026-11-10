-- Pure capture eligibility policy. The server supplies character health and state.
local Rules = {}
function Rules.canCatch(health, isDead, hasRoot)
    return type(health) == "number" and health == health and health > 0
        and isDead == false and hasRoot == true
end
return Rules
