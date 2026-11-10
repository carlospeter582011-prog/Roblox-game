-- Pure fall recovery rules. Region geometry is intentionally conservative.
local Rescue = {}
Rescue.FALL_Y = -55
Rescue.COOLDOWN = 6
Rescue.SPAWNS = {
    { x = 0, z = 0, y = 9, minX = -70, maxX = 75 },
    { x = 170, z = 0, y = 9, minX = 76, maxX = 235 },
    { x = 315, z = 0, y = 9, minX = 236, maxX = 390 },
}
function Rescue.destination(x, z)
    if type(x) ~= "number" or type(z) ~= "number" or x ~= x or z ~= z
        or math.abs(x) == math.huge or math.abs(z) == math.huge then return nil end
    local best, distance
    for _, spawn in ipairs(Rescue.SPAWNS) do
        local d = (x - spawn.x)^2 + (z - spawn.z)^2
        if not distance or d < distance then best, distance = spawn, d end
    end
    return best
end
function Rescue.canRecover(y, now, previous, alive, ready)
    return ready == true and alive == true and type(y) == "number"
        and y == y and y < Rescue.FALL_Y
        and type(now) == "number" and now == now and now >= 0
        and (previous == nil or (type(previous) == "number" and now - previous >= Rescue.COOLDOWN))
end
return table.freeze(Rescue)
