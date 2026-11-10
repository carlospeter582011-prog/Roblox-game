-- Pure, deterministic companion selection. Never trust client-reported ownership.
local Rules = {}
function Rules.owned(speciesId, species, catalog)
    return type(speciesId) == "string" and #speciesId <= 48
        and catalog[speciesId] ~= nil and type(species) == "table"
        and type(species[speciesId]) == "number" and species[speciesId] >= 1
end
function Rules.sortedOwned(species, catalog)
    local ids = {}
    for id in pairs(catalog) do
        if Rules.owned(id, species, catalog) then table.insert(ids, id) end
    end
    table.sort(ids)
    return ids
end
function Rules.next(current, species, catalog)
    local ids = Rules.sortedOwned(species, catalog)
    if #ids == 0 then return nil end
    for i, id in ipairs(ids) do
        if id == current then return ids[i % #ids + 1] end
    end
    return ids[1]
end
return Rules
