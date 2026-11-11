-- First-time elemental field discoveries reward exploring different cloud families.
-- Uses the existing saved species collection: no extra flags or migration.
local Rules = {}
local REWARD_COINS, REWARD_XP = 35, 20

function Rules.firstElementReward(speciesId, owned, catalog)
    if type(speciesId) ~= "string" or type(owned) ~= "table" or type(catalog) ~= "table" then return 0, 0 end
    local target = catalog[speciesId]
    if type(target) ~= "table" or type(target.element) ~= "string" or target.element == "" then return 0, 0 end
    for id, entry in pairs(catalog) do
        if type(entry) == "table" and entry.element == target.element then
            local count = owned[id]
            if type(count) == "number" and count == count and count >= 1 and count < math.huge then
                return 0, 0
            end
        end
    end
    return REWARD_COINS, REWARD_XP
end
return Rules
