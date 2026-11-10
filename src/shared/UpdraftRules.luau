-- Pure, server-side rules for reusable 3D updraft travel pads.
local Rules = {}
Rules.COOLDOWN = 8
Rules.MAX_DISTANCE = 15
Rules.VERTICAL_SPEED = 42
Rules.HORIZONTAL_SPEED = 36
local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function Rules.canLaunch(distance, now, last, ready, alive)
    if not ready or not alive or not finite(distance) or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if not finite(now) or now < 0 then return false end
    if last ~= nil and (not finite(last) or now < last or now - last < Rules.COOLDOWN) then return false end
    return true
end
-- Return scalar components; the Roblox runtime applies a direction vector.
function Rules.launchSpeeds(directionX, directionZ)
    if not finite(directionX) or not finite(directionZ) then return nil end
    local length = math.sqrt(directionX * directionX + directionZ * directionZ)
    if not finite(length) or length < 0.001 then return nil end
    return directionX / length * Rules.HORIZONTAL_SPEED, Rules.VERTICAL_SPEED, directionZ / length * Rules.HORIZONTAL_SPEED
end
return table.freeze(Rules)
