-- Pure server-side updraft rules. All values are studs/seconds; never trust a client launch request.
local Rules = {}
Rules.COOLDOWN = 8
Rules.MAX_DISTANCE = 14
Rules.VERTICAL_SPEED = 72
Rules.HORIZONTAL_SPEED = 24
function Rules.canLaunch(distance, alive, ready, now, last)
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if not alive or not ready then return false end
    if type(now) ~= "number" or now ~= now then return false end
    if last ~= nil and (type(last) ~= "number" or now - last < Rules.COOLDOWN) then return false end
    return true
end
function Rules.direction(x, z)
    local magnitude = math.sqrt(x * x + z * z)
    if magnitude < 0.001 then return 0, 0 end
    return x / magnitude, z / magnitude
end
return table.freeze(Rules)
