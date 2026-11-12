-- Server-owned skyway routing; pure rules for automated regression coverage.
local Rules = {}
Rules.COOLDOWN = 8
Rules.MAX_DISTANCE = 15
Rules.routes = table.freeze({
    meadow_to_outlook = { from = { 72, 2, 30 }, to = { 145, 5, 30 } },
    outlook_to_ridge = { from = { 199, 2, -30 }, to = { 285, 5, -30 } },
    ridge_to_meadow = { from = { 330, 2, 22 }, to = { 0, 5, 22 } },
})
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.canLaunch(routeId, distance, now, lastLaunch, ready)
    if not Rules.routes[routeId] or ready ~= true then return false end
    if not finite(distance) or distance < 0 or distance > Rules.MAX_DISTANCE then return false end
    if not finite(now) or not finite(lastLaunch) or now < 0 then return false end
    return now - lastLaunch >= Rules.COOLDOWN
end
return table.freeze(Rules)
