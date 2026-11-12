-- Server-only exclusive cloud reservation. A unique token prevents stale handlers
-- from releasing a claim belonging to a newer catch operation.
local Claims = {}
function Claims.new()
    local busy = {}
    local guard = {}
    function guard:claim(id)
        if type(id) ~= "string" or #id == 0 or #id > 24 or busy[id] ~= nil then
            return nil
        end
        local token = {}
        busy[id] = token
        return token
    end
    function guard:release(id, token)
        if type(id) ~= "string" or token == nil or busy[id] ~= token then
            return false
        end
        busy[id] = nil
        return true
    end
    function guard:isClaimed(id)
        return busy[id] ~= nil
    end
    return guard
end
return Claims
