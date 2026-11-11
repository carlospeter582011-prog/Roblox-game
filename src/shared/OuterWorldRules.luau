-- Pure rules for the seven outer-world expeditions. Server never accepts a client-selected destination.
local WorldCatalog = require("./WorldCatalog")
local Rules = {}
local ids = { "sunset_dunes", "frost_spires", "bloom_gardens", "crystal_belt", "moonlit_isles", "stormheart_citadel", "lost_cloud_kingdom" }
function Rules.entries()
    local result = {}
    for index, id in ipairs(ids) do
        local world = WorldCatalog[id]
        result[index] = { id = id, name = world.name, requiredCatches = world.unlockCatches,
            x = 520 + (index - 1) * 180, z = 0, order = world.order }
    end
    return result
end
function Rules.canTravel(id, captures)
    local world = WorldCatalog[id]
    return world ~= nil and world.order >= 4 and world.order <= 10
        and type(captures) == "number" and captures == captures
        and captures ~= math.huge and captures >= world.unlockCatches
end
function Rules.canActivate(id, captures, distance, alive)
    return alive == true and type(distance) == "number" and distance == distance
        and distance >= 0 and distance <= 15 and Rules.canTravel(id, captures)
end
return Rules
