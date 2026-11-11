-- Pure server-side building rules. Layouts are bounded, fixed-slot blueprints (no arbitrary CFrames).
local Rules = {}
Rules.MAX_SLOTS = 6
Rules.Buildings = table.freeze({
    breeze_habitat = { name = "Breeze Habitat", cost = 120, color = "Air" },
    crystal_garden = { name = "Crystal Garden", cost = 240, color = "Crystal" },
    storm_roost = { name = "Storm Roost", cost = 400, color = "Storm" },
})
local function integer(n, low, high)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
        and n == math.floor(n) and n >= low and n <= high
end
function Rules.sanitize(layout)
    local result = {}
    if type(layout) ~= "table" then return result end
    for slot = 1, Rules.MAX_SLOTS do
        local id = layout[slot]
        if type(id) == "string" and Rules.Buildings[id] then result[slot] = id end
    end
    return result
end
function Rules.purchase(layout, coins, slot, buildingId)
    if not integer(coins, 0, 1e12 - 1) or not integer(slot, 1, Rules.MAX_SLOTS) then
        return false, "Invalid purchase"
    end
    local building = type(buildingId) == "string" and Rules.Buildings[buildingId] or nil
    if not building then return false, "Unknown building" end
    if type(layout) ~= "table" or layout[slot] ~= nil then return false, "Slot occupied" end
    if coins < building.cost then return false, "Not enough Coins" end
    local updated = Rules.sanitize(layout)
    updated[slot] = buildingId
    return true, updated, coins - building.cost
end
return table.freeze(Rules)
