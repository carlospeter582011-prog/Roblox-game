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
-- Apply a bounded reward and its cooldown in one non-yielding profile mutation.
-- The caller must durably save the whole profile before acknowledging success.
function Rules.applyReward(data, id, now)
    if type(data) ~= "table" or type(data.observatoryCooldowns) ~= "table" then return false end
    local station = type(id) == "string" and Rules.stations[id] or nil
    if not station or type(data.coins) ~= "number" or type(data.xp) ~= "number" then return false end
    if data.coins ~= data.coins or data.xp ~= data.xp or data.coins < 0 or data.xp < 0 then return false end
    if data.coins == math.huge or data.xp == math.huge or data.coins + station.coins > 1000000000 or data.xp + station.xp > 1000000000 then return false end
    if not Rules.canObserve(id, data.captures, 0, now, data.observatoryCooldowns[id] or 0, true) then return false end
    data.coins += station.coins
    data.xp += station.xp
    data.observatoryCooldowns[id] = now + Rules.COOLDOWN
    return true, station.coins, station.xp
end

function Rules.reward(id)
    local station = type(id) == "string" and Rules.stations[id] or nil
    if not station then return nil end
    return station.coins, station.xp
end
return Rules
