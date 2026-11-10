-- Pure server-authoritative harvest rules for repeatable island production.
local Rules = {}
Rules.GROW_SECONDS = 120
Rules.TREES = {
    meadow = { requiredCatches = 0, coins = 18, xp = 8 },
    eastwind = { requiredCatches = 20, coins = 42, xp = 18 },
    ridge = { requiredCatches = 60, coins = 85, xp = 35 },
}
function Rules.canHarvest(id, catches, distance, alive, ready, now, last)
    local tree = type(id) == "string" and Rules.TREES[id] or nil
    if not tree or alive ~= true or ready ~= true then return false end
    if type(catches) ~= "number" or catches ~= catches or catches < tree.requiredCatches then return false end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > 14 then return false end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return false end
    if last ~= nil then
        if type(last) ~= "number" or last ~= last or last > now then return false end
        if now - last < Rules.GROW_SECONDS then return false end
    end
    return true
end
return Rules
