-- Pure target selection for a player-operated discovery beacon.
local Rules = {}
Rules.MAX_DISTANCE = 220
Rules.COOLDOWN = 35
Rules.DURATION = 14
function Rules.choose(candidates, owned, origin)
    if type(candidates) ~= "table" or type(owned) ~= "table" or type(origin) ~= "table" then return nil end
    if type(origin.x) ~= "number" or type(origin.z) ~= "number" then return nil end
    local best, score
    for _, cloud in ipairs(candidates) do
        if type(cloud) == "table" and type(cloud.id) == "string" and type(cloud.species) == "string"
            and type(cloud.x) == "number" and type(cloud.z) == "number" then
            local dx, dz = cloud.x - origin.x, cloud.z - origin.z
            local d2 = dx*dx + dz*dz
            if d2 == d2 and d2 <= Rules.MAX_DISTANCE*Rules.MAX_DISTANCE then
                -- Prioritize genuinely undiscovered species, then proximity.
                local rank = ((owned[cloud.species] or 0) > 0 and 1 or 0) * (Rules.MAX_DISTANCE*Rules.MAX_DISTANCE + 1) + d2
                if not score or rank < score or (rank == score and cloud.id < best.id) then
                    best, score = cloud, rank
                end
            end
        end
    end
    return best
end
function Rules.canActivate(distance, elapsed, ready, alive)
    return ready == true and alive == true and type(distance) == "number"
        and distance == distance and distance >= 0 and distance <= 14
        and type(elapsed) == "number" and elapsed == elapsed and elapsed >= Rules.COOLDOWN
end
return Rules
