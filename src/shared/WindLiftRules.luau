-- Pure server-side rules for reusable 3D wind lift pads.
local Rules = {}
Rules.COOLDOWN = 4
Rules.HORIZONTAL_SPEED = 32
Rules.UP_SPEED = 58
Rules.MAX_DISTANCE = 12
function Rules.canLaunch(now, previous, distance, alive)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return false end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if alive ~= true then return false end
    if previous ~= nil then
        if type(previous) ~= "number" or previous ~= previous then return false end
        if now - previous < Rules.COOLDOWN then return false end
    end
    return true
end
return Rules
