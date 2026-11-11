-- Pure, deterministic nearest-cloud scanner; no client-selected target or rewards.
local Rules = {}
Rules.COOLDOWN = 30
Rules.RADIUS = 180
function Rules.canScan(now, last)
    return type(now) == "number" and now == now and now < math.huge
        and (last == nil or (type(last) == "number" and now - last >= Rules.COOLDOWN))
end
function Rules.nearest(origin, candidates, radius)
    if type(origin) ~= "table" or type(candidates) ~= "table" then return nil end
    local best, bestDistance
    radius = type(radius) == "number" and math.clamp(radius, 1, Rules.RADIUS) or Rules.RADIUS
    for _, item in ipairs(candidates) do
        if type(item) == "table" and type(item.id) == "string" and type(item.species) == "string"
            and type(item.x) == "number" and type(item.z) == "number"
            and item.x == item.x and item.z == item.z
            and math.abs(item.x) < 100000 and math.abs(item.z) < 100000 then
            local dx, dz = item.x - origin.x, item.z - origin.z
            local d = math.sqrt(dx * dx + dz * dz)
            if d <= radius and (not bestDistance or d < bestDistance or
                (d == bestDistance and item.id < best.id)) then
                best, bestDistance = item, d
            end
        end
    end
    return best, bestDistance
end
return Rules
