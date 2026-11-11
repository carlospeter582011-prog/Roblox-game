-- Pure, server-side rules for reusable sky updraft launchpads.
local Rules = {}
Rules.COOLDOWN = 8
Rules.MAX_DISTANCE = 15
Rules.VERTICAL_SPEED = 72
Rules.HORIZONTAL_SPEED = 26
function Rules.canLaunch(distance, now, lastUsed, alive)
    if not alive or type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return false end
    if type(lastUsed) == "number" and now - lastUsed < Rules.COOLDOWN then return false end
    return true
end
function Rules.velocity(directionX, directionZ)
    if type(directionX) ~= "number" or type(directionZ) ~= "number" then return 0, Rules.VERTICAL_SPEED, 0 end
    if directionX ~= directionX or directionZ ~= directionZ then return 0, Rules.VERTICAL_SPEED, 0 end
    local length = math.sqrt(directionX * directionX + directionZ * directionZ)
    if length < 0.001 or length == math.huge then return 0, Rules.VERTICAL_SPEED, 0 end
    return directionX / length * Rules.HORIZONTAL_SPEED, Rules.VERTICAL_SPEED, directionZ / length * Rules.HORIZONTAL_SPEED
end
return table.freeze(Rules)
