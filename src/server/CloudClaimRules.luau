-- Server-only claim guard: a catch must reserve its cloud before any yielding save.
-- Roblox event handlers may overlap while ProfileStore writes to DataStore.
local Claims = {}
function Claims.new()
    local busy = {}
    local guard = {}
    function guard:claim(id)
        if type(id) ~= "string" or busy[id] then return false end
        busy[id] = true
        return true
    end
    function guard:release(id)
        busy[id] = nil
    end
    function guard:isClaimed(id)
        return busy[id] == true
    end
    return guard
end
return Claims
