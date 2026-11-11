-- Pure, server-owned three-beacon exploration rules. No Roblox services.
local Rules = {}
Rules.ORDER = {"meadow", "eastwind", "ridge"}
Rules.DURATION = 180
Rules.COOLDOWN = 300
Rules.COINS = 180
Rules.XP = 90
function Rules.next(index, beacon, startedAt, now)
    if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > 3 then return nil end
    if type(now) ~= "number" or now ~= now or now == math.huge then return nil end
    if type(startedAt) ~= "number" or startedAt ~= startedAt or now < startedAt or now - startedAt > Rules.DURATION then return nil end
    if beacon ~= Rules.ORDER[index] then return nil end
    return index + 1
end
function Rules.canStart(now, availableAt)
    return type(now) == "number" and now == now and now < math.huge
        and type(availableAt) == "number" and now >= availableAt
end
return table.freeze(Rules)
