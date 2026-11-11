-- Pure, server-owned duplicate cloud exchange economy rules.
local Rules = {}
function Rules.quote(speciesId, owned, catalog)
    if type(speciesId) ~= "string" or #speciesId > 40 then return nil end
    local entry = catalog[speciesId]
    if not entry or type(owned) ~= "table" then return nil end
    local count = owned[speciesId]
    if type(count) ~= "number" or count ~= count or count == math.huge or count < 3 then return nil end
    local base = entry.baseRewardCoins
    if type(base) ~= "number" or base ~= base or base < 1 or base == math.huge then return nil end
    -- Keep one permanent specimen; exchange two duplicates for predictable rewards.
    return 2, math.clamp(math.floor(base * 2), 10, 500), math.clamp(math.floor(base / 2), 5, 100)
end
return Rules
