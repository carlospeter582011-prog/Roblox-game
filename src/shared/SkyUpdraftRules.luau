-- Pure rules for server-authoritative sky updraft travel. No Roblox globals.
local Rules = {}
Rules.COOLDOWN = 8
Rules.MAX_DISTANCE = 13
Rules.STATIONS = {
    meadow = { x = 65, y = 2, z = 65, unlock = 0, horizontal = 55, vertical = 62 },
    eastwind = { x = 188, y = 2, z = 30, unlock = 20, horizontal = 65, vertical = 68 },
    ridge = { x = 330, y = 2, z = -27, unlock = 60, horizontal = 75, vertical = 74 },
}
local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function Rules.canLaunch(id, distance, captures, elapsed, profileReady, alive)
    local station = type(id) == "string" and Rules.STATIONS[id] or nil
    if not station then return false, "unknown" end
    if profileReady ~= true or alive ~= true then return false, "unavailable" end
    if not finite(distance) or distance < 0 or distance > Rules.MAX_DISTANCE then return false, "distance" end
    if not finite(captures) or captures < station.unlock then return false, "locked" end
    if not finite(elapsed) or elapsed < Rules.COOLDOWN then return false, "cooldown" end
    return true, station
end
return Rules
