-- Atomic, non-yielding claim bookkeeping for server-owned cloud instances.
-- Call begin before any potentially yielding reward operation, finish afterward.
local Claims = {}
function Claims.begin(claims, id, active, instance)
    if type(id) ~= "string" or not instance or claims[id] or active[id] ~= instance then return false end
    claims[id] = true
    return true
end
function Claims.finish(claims, id)
    claims[id] = nil
end
return Claims
