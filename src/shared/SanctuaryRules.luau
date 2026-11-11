-- Pure server-side offering policy. Keep the final specimen of every species.
local Rules = {}
function Rules.preview(speciesId, owned, catalog)
    if type(speciesId) ~= "string" or #speciesId > 48 or type(owned) ~= "table" or type(catalog) ~= "table" then return nil end
    local species = catalog[speciesId]
    local count = owned[speciesId]
    if not species or type(count) ~= "number" or count ~= math.floor(count) or count < 2 then return nil end
    local base = species.baseRewardCoins
    if type(base) ~= "number" or base ~= base or base <= 0 then return nil end
    -- Offering is a small, predictable sink for duplicate clouds, not an infinite currency exploit.
    return math.min(300, math.floor(base * 1.5)), math.min(120, math.floor(base * 0.5))
end
return table.freeze(Rules)
