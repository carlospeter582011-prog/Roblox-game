-- Pure, server-authoritative validation for reusable sky updraft launch pads.
local Rules = {}
local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function Rules.canLaunch(distance, health, now, previous, cooldown)
    if not (finite(distance) and finite(health) and finite(now) and finite(cooldown)) then return false end
    if distance < 0 or distance > 13 or health <= 0 or cooldown < 1 then return false end
    if previous ~= nil then
        if not finite(previous) or now < previous or now - previous < cooldown then return false end
    end
    return true
end
function Rules.velocity(x, z, horizontal, vertical)
    if not (finite(x) and finite(z) and finite(horizontal) and finite(vertical)) then return nil end
    if horizontal < 0 or horizontal > 90 or vertical < 15 or vertical > 120 then return nil end
    local magnitude = math.sqrt(x*x + z*z)
    if not finite(magnitude) or magnitude < 0.001 then return nil end
    return x/magnitude*horizontal, vertical, z/magnitude*horizontal
end
return table.freeze(Rules)
