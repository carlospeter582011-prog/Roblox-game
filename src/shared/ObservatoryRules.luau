-- Pure rules for repeatable sky-observatory expeditions.
-- The server owns timestamps, proximity, rewards and profile mutation.
local Rules = {}
Rules.COOLDOWN = 180
Rules.DISTANCE = 13
Rules.stations = {
    meadow = {name = "Meadow Starwatch", x = -42, z = -42, catches = 0, coins = 20, xp = 15},
    eastwind = {name = "Eastwind Windscope", x = 182, z = -30, catches = 12, coins = 35, xp = 25},
    ridge = {name = "Thunderhead Stormscope", x = 325, z = -28, catches = 35, coins = 60, xp = 45},
}
function Rules.canObserve(id, catches, distance, now, nextAllowed, ready)
    local station = type(id) == "string" and Rules.stations[id] or nil
    if not station or ready ~= true then return false end
    if type(catches) ~= "number" or catches ~= catches or catches < station.catches then return false end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance == math.huge or distance > Rules.DISTANCE then return false end
    if type(now) ~= "number" or now ~= now or now < 0 or now == math.huge then return false end
    if type(nextAllowed) ~= "number" or nextAllowed ~= nextAllowed then return false end
    return now >= nextAllowed
end
function Rules.reward(id)
    local station = type(id) == "string" and Rules.stations[id] or nil
    if not station then return nil end
    return station.coins, station.xp
end
return Rules
