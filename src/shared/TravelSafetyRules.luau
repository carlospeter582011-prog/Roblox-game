-- Server-only travel guard shared with unit tests. Never trust client-supplied positions.
local Rules = {}
function Rules.canTravel(catches, required, distance, health, elapsed)
    if type(catches) ~= "number" or catches ~= catches or catches < 0 then return false end
    if type(required) ~= "number" or required < 0 then return false end
    if type(distance) ~= "number" or distance ~= distance or distance > 15 or distance < 0 then return false end
    if type(health) ~= "number" or health ~= health or health <= 0 then return false end
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < 2 then return false end
    return catches >= required
end
return table.freeze(Rules)
