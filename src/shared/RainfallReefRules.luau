-- Rainfall Reef is a fourth physically reachable 3D region in the starter Place.
-- Pure geometry/progression constants, shared by server construction and regression tests.
local Reef = {}
Reef.centerX = 460
Reef.floorY = 0
Reef.halfWidth = 55
Reef.halfDepth = 50
Reef.bridgeCenterX = 387
Reef.bridgeLength = 40
Reef.bridgeWidth = 14
Reef.unlockCatches = 25
function Reef.isOnWalkway(x, z)
    if type(x) ~= "number" or type(z) ~= "number" or x ~= x or z ~= z then return false end
    return x >= Reef.bridgeCenterX - Reef.bridgeLength / 2 and
        x <= Reef.bridgeCenterX + Reef.bridgeLength / 2 and math.abs(z) <= Reef.bridgeWidth / 2
end
function Reef.isInside(x, z)
    if type(x) ~= "number" or type(z) ~= "number" or x ~= x or z ~= z then return false end
    return math.abs(x - Reef.centerX) <= Reef.halfWidth and math.abs(z) <= Reef.halfDepth
end
function Reef.canTravel(captures)
    return type(captures) == "number" and captures == captures and
        captures < math.huge and captures >= Reef.unlockCatches
end
return Reef
