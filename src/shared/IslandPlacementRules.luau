-- Server-authoritative island placement contract. Pure Luau for CI.
-- Coordinates are integer studs on a local island grid, never client CFrames.
local Rules = {}
Rules.MAX_ITEMS = 64
Rules.MAX_COORD = 24
Rules.CATALOG = {
    cloud_perch = { cost = 80, half = 2, unlock = 0 },
    windmill = { cost = 250, half = 3, unlock = 20 },
    crystal_garden = { cost = 420, half = 3, unlock = 50 },
    weather_station = { cost = 800, half = 4, unlock = 100 },
}
local function integer(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge and n == math.floor(n)
end
function Rules.validate(item)
    if type(item) ~= "table" or type(item.id) ~= "string" or not Rules.CATALOG[item.id] then return false, "unknown_item" end
    if not integer(item.x) or not integer(item.z) or math.abs(item.x) > Rules.MAX_COORD or math.abs(item.z) > Rules.MAX_COORD then
        return false, "invalid_coordinates"
    end
    if not integer(item.rotation) or item.rotation < 0 or item.rotation > 3 then return false, "invalid_rotation" end
    local half = Rules.CATALOG[item.id].half
    if math.abs(item.x) + half > Rules.MAX_COORD or math.abs(item.z) + half > Rules.MAX_COORD then return false, "outside_island" end
    return true
end
function Rules.overlaps(a, b)
    local aa, bb = Rules.CATALOG[a.id], Rules.CATALOG[b.id]
    return math.abs(a.x - b.x) < aa.half + bb.half + 1
        and math.abs(a.z - b.z) < aa.half + bb.half + 1
end
function Rules.sanitize(raw)
    local items = {}
    if type(raw) ~= "table" then return items end
    for _, item in ipairs(raw) do
        if #items >= Rules.MAX_ITEMS then break end
        local valid = Rules.validate(item)
        if valid then
            local candidate = { id = item.id, x = item.x, z = item.z, rotation = item.rotation }
            local blocked = false
            for _, placed in ipairs(items) do
                if Rules.overlaps(candidate, placed) then blocked = true break end
            end
            if not blocked then table.insert(items, candidate) end
        end
    end
    return items
end
function Rules.place(items, request, coins, catches)
    local ok, reason = Rules.validate(request)
    if not ok then return nil, reason end
    if type(items) ~= "table" or #items >= Rules.MAX_ITEMS then return nil, "capacity" end
    local def = Rules.CATALOG[request.id]
    if not integer(coins) or coins < def.cost then return nil, "insufficient_coins" end
    if not integer(catches) or catches < def.unlock then return nil, "locked" end
    local current = Rules.sanitize(items)
    if #current ~= #items then return nil, "invalid_layout" end
    for _, placed in ipairs(current) do
        if Rules.overlaps(request, placed) then return nil, "overlap" end
    end
    table.insert(current, { id = request.id, x = request.x, z = request.z, rotation = request.rotation })
    return { items = current, remainingCoins = coins - def.cost }
end
return Rules
