-- Pure progression helpers for unlock-by-catches catalogs (tools and worlds). No Roblox globals.
local Progress = {}

-- Ids of a catalog sorted by unlock threshold, then by `order` if present, then by id, so the
-- result is deterministic. Entries need a numeric unlockCatches.
function Progress.sortedByUnlock(catalog)
    local ids = {}
    for id, entry in pairs(catalog) do
        if type(entry) == "table" and type(entry.unlockCatches) == "number" then
            table.insert(ids, id)
        end
    end
    table.sort(ids, function(a, b)
        local ea, eb = catalog[a], catalog[b]
        if ea.unlockCatches ~= eb.unlockCatches then
            return ea.unlockCatches < eb.unlockCatches
        end
        local oa, ob = ea.order or 0, eb.order or 0
        if oa ~= ob then
            return oa < ob
        end
        return a < b
    end)
    return ids
end

function Progress.isUnlocked(captures, id, catalog)
    local entry = catalog[id]
    return entry ~= nil and type(captures) == "number" and captures >= entry.unlockCatches
end

-- Returns unlockedIds (in unlock order), nextId (or nil when everything is unlocked) and
-- remaining (catches still needed for nextId, 0 when none).
function Progress.status(captures, catalog)
    local count = (type(captures) == "number" and captures == captures and captures >= 0) and captures or 0
    local unlocked = {}
    local nextId, remaining = nil, 0
    for _, id in ipairs(Progress.sortedByUnlock(catalog)) do
        local threshold = catalog[id].unlockCatches
        if count >= threshold then
            table.insert(unlocked, id)
        else
            nextId, remaining = id, threshold - count
            break
        end
    end
    return unlocked, nextId, remaining
end

return Progress
