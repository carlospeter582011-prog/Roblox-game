-- Pure launch validation for native 3D sky-current pads.
local Rules = {}
Rules.COOLDOWN = 12
Rules.MAX_DISTANCE = 16
Rules.MAX_SPEED = 105
function Rules.canLaunch(distance, health, now, readyAt)
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if type(health) ~= "number" or health ~= health or health <= 0 then return false end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return false end
    if type(readyAt) ~= "number" or readyAt ~= readyAt then return false end
    return now >= readyAt
end
function Rules.velocity(dx, dz)
    if type(dx) ~= "number" or type(dz) ~= "number" or dx ~= dx or dz ~= dz then return nil end
    local magnitude = math.sqrt(dx * dx + dz * dz)
    if magnitude < 1 or magnitude > 500 then return nil end
    return dx / magnitude * 65, 76, dz / magnitude * 65
end
return table.freeze(Rules)
