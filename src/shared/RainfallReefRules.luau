-- Pure spatial and progression rules for the first Rainfall Reef region.
local Rules = {}
Rules.centerX = 455
Rules.centerZ = 0
Rules.width = 110
Rules.depth = 110
Rules.bridgeStart = 365
Rules.bridgeEnd = 401
Rules.beacons = {
    { id = "reef_north", x = 432, z = -31 },
    { id = "reef_east", x = 484, z = -18 },
    { id = "reef_south", x = 462, z = 30 },
}
function Rules.onReef(x, z)
    return type(x) == "number" and type(z) == "number"
        and x == x and z == z and math.abs(x) < math.huge and math.abs(z) < math.huge
        and math.abs(x - Rules.centerX) <= Rules.width / 2
        and math.abs(z - Rules.centerZ) <= Rules.depth / 2
end
function Rules.bridgeConnects()
    -- Ridge ends at x=370; reef begins at x=400. Walkway must overlap both.
    return Rules.bridgeStart <= 370 and Rules.bridgeEnd >= 400
end
function Rules.canActivate(distance, ready, alive)
    return ready == true and alive == true and type(distance) == "number"
        and distance == distance and distance >= 0 and distance <= 13
end
return Rules
