-- Pure building placement rules. No Roblox globals. Catalog passed in or required separately in Roblox.
local Rules = {}

-- Starter island approximate bounds (from StarterWorld).
Rules.ISLAND_BOUNDS = { minX = -40, maxX = 40, minZ = -40, maxZ = 40, minY = 10, maxY = 30 }
Rules.MAX_BUILDINGS = 50

function Rules.canPlace(catalog, data, buildingId, position)
    local item = catalog and catalog[buildingId]
    if not item then return false, "Unknown building" end
    if not data or type(data.coins) ~= "number" then return false, "No profile" end
    if data.coins < item.costCoins then return false, "Not enough coins" end
    local count = 0
    if type(data.buildings) == "table" then
        for _ in pairs(data.buildings) do count += 1 end
    end
    if count >= Rules.MAX_BUILDINGS then return false, "Island is full" end
    if type(position) ~= "table" or type(position.x) ~= "number" or type(position.y) ~= "number" or type(position.z) ~= "number" then
        return false, "Invalid position"
    end
    if position.x < Rules.ISLAND_BOUNDS.minX or position.x > Rules.ISLAND_BOUNDS.maxX or
       position.z < Rules.ISLAND_BOUNDS.minZ or position.z > Rules.ISLAND_BOUNDS.maxZ or
       position.y < Rules.ISLAND_BOUNDS.minY or position.y > Rules.ISLAND_BOUNDS.maxY then
        return false, "Outside island bounds"
    end
    return true, item
end

function Rules.place(catalog, data, buildingId, position)
    local ok, itemOrErr = Rules.canPlace(catalog, data, buildingId, position)
    if not ok then return false, itemOrErr end
    data.coins -= itemOrErr.costCoins
    data.buildings = data.buildings or {}
    table.insert(data.buildings, { id = buildingId, x = position.x, y = position.y, z = position.z, rot = 0 })
    return true, itemOrErr
end

return Rules
