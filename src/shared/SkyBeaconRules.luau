-- Pure server-side rules for session checkpoint activation.
local Rules = {}
Rules.MAX_DISTANCE = 14
Rules.POSITIONS = {
    meadow = {x = 0, y = 3, z = -25},
    eastwind = {x = 170, y = 3, z = 25},
    ridge = {x = 315, y = 3, z = 25},
}
function Rules.canActivate(id, distance, alive, profileReady)
    if not Rules.POSITIONS[id] or alive ~= true or profileReady ~= true then return false end
    return type(distance) == "number" and distance == distance
        and distance >= 0 and distance <= Rules.MAX_DISTANCE and distance < math.huge
end
function Rules.spawnPosition(id)
    return Rules.POSITIONS[id] or Rules.POSITIONS.meadow
end
return table.freeze(Rules)
