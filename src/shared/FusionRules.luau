-- Pure, server-authoritative duplicate cloud fusion rules.
-- Sacrifice two spare copies; keep one original and grant persistent bond mastery.
local Fusion = {}
Fusion.COST = 2
Fusion.BOND_GAIN = 20
function Fusion.canFuse(speciesId, species, catalog)
    if type(speciesId) ~= "string" or not catalog[speciesId] then return false end
    local count = type(species) == "table" and species[speciesId] or nil
    return type(count) == "number" and count == math.floor(count) and count >= 3 and count <= 1000000
end
function Fusion.apply(speciesId, species, bonds, catalog)
    if not Fusion.canFuse(speciesId, species, catalog) then return false end
    species[speciesId] -= Fusion.COST
    local old = type(bonds[speciesId]) == "number" and bonds[speciesId] or 0
    bonds[speciesId] = math.min(1000000, math.max(0, math.floor(old)) + Fusion.BOND_GAIN)
    return true, bonds[speciesId]
end
return Fusion
