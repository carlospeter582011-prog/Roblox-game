-- Pure elemental objectives for the three existing boss trials.
-- Only server-owned species counts are considered. Variant keys never count twice.
local Objectives = {}
Objectives.allowed = {
    meadow = { Air = true, Water = true },
    eastwind = { Air = true, Light = true },
    ridge = { Storm = true, Fire = true },
}
local function safeCount(value)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge or value < 0 then return 0 end
    return math.floor(value)
end
function Objectives.snapshot(species, catalog)
    local result = {}
    if type(species) ~= "table" or type(catalog) ~= "table" then return result end
    for id, entry in pairs(catalog) do
        if type(id) == "string" and type(entry) == "table" then
            result[id] = safeCount(species[id])
        end
    end
    return result
end
function Objectives.progress(bossId, initial, current, catalog, goal)
    local allowed = Objectives.allowed[bossId]
    if not allowed or type(initial) ~= "table" or type(current) ~= "table" or type(catalog) ~= "table"
        or type(goal) ~= "number" or goal < 1 then return 0 end
    local total = 0
    for id, entry in pairs(catalog) do
        if type(entry) == "table" and allowed[entry.element] then
            total += math.max(0, safeCount(current[id]) - safeCount(initial[id]))
        end
    end
    return math.min(goal, total)
end
function Objectives.label(bossId)
    if bossId == "meadow" then return "Air/Water" end
    if bossId == "eastwind" then return "Air/Light" end
    if bossId == "ridge" then return "Storm/Fire" end
    return "Unknown"
end
return Objectives
