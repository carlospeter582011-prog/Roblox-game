-- Pure server-side cooperative weather harmonizer rules.
local Rules = {}
Rules.WINDOW = 12
Rules.COOLDOWN = 75
Rules.BOOST_SECONDS = 25
Rules.MAX_DISTANCE = 16

local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

function Rules.canActivate(distance, alive, ready)
    return finite(distance) and distance >= 0 and distance <= Rules.MAX_DISTANCE
        and alive == true and ready == true
end

-- One player cannot occupy both roles; timestamps are monotonic os.clock values.
function Rules.complete(a, b, now)
    if type(a) ~= "table" or type(b) ~= "table" or not finite(now) then return false end
    if type(a.userId) ~= "number" or type(b.userId) ~= "number" or a.userId == b.userId then return false end
    if not finite(a.at) or not finite(b.at) or a.at > now or b.at > now then return false end
    return now - math.min(a.at, b.at) <= Rules.WINDOW
end

function Rules.cooldownReady(last, now)
    return finite(now) and (last == nil or (finite(last) and now >= last + Rules.COOLDOWN))
end

return Rules
