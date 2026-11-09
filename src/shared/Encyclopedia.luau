-- Pure encyclopedia helpers. No Roblox globals.
-- Only ids that exist in the species catalog count, so mutation variant keys such as
-- "breeze:golden" or stale ids can never push completion past 100%.
local Encyclopedia = {}

local function catalogSize(catalog)
    local total = 0
    for _ in pairs(catalog or {}) do
        total += 1
    end
    return total
end

Encyclopedia.ATTRIBUTE_PREFIX = "SpeciesCount_"

-- Builds a species -> count map from a player's replicated attributes (name -> value). Uses the
-- prefix length rather than a hardcoded number; a miscount here once made the HUD show 0 species.
function Encyclopedia.fromAttributes(attributes)
    local map = {}
    local prefix = Encyclopedia.ATTRIBUTE_PREFIX
    for name, value in pairs(attributes or {}) do
        if type(name) == "string" and string.sub(name, 1, #prefix) == prefix and type(value) == "number" then
            map[string.sub(name, #prefix + 1)] = value
        end
    end
    return map
end

function Encyclopedia.size(catalog)
    return catalogSize(catalog)
end

-- Number of distinct catalog species caught at least once. With no catalog, counts every
-- positive entry (legacy behaviour).
function Encyclopedia.uniqueCount(speciesMap, catalog)
    local n = 0
    for id, count in pairs(speciesMap or {}) do
        if type(count) == "number" and count > 0 and (catalog == nil or catalog[id] ~= nil) then
            n += 1
        end
    end
    return n
end

function Encyclopedia.completionPercent(speciesMap, catalog)
    local total = catalogSize(catalog)
    if total == 0 then
        return 0
    end
    return math.floor(Encyclopedia.uniqueCount(speciesMap, catalog) * 100 / total)
end

-- Catalog ids not yet caught, sorted, for "still to find" lists.
function Encyclopedia.missing(speciesMap, catalog)
    local ids = {}
    for id in pairs(catalog or {}) do
        local count = speciesMap and speciesMap[id]
        if type(count) ~= "number" or count <= 0 then
            table.insert(ids, id)
        end
    end
    table.sort(ids)
    return ids
end

return Encyclopedia
