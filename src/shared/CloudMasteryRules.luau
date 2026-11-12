-- Pure companion mastery rules: earned only from server-validated catches.
local Rules = {}
local MAX_XP = 1000000
function Rules.level(xp)
    if type(xp) ~= "number" or xp ~= xp or xp < 0 or xp == math.huge or xp == -math.huge then return 1 end
    return math.min(10, 1 + math.floor(math.sqrt(math.min(xp, MAX_XP) / 20)))
end
function Rules.gain(current, id, species, catalog)
    if type(id) ~= "string" or not catalog[id] or type(species) ~= "table"
        or type(species[id]) ~= "number" or species[id] ~= species[id]
        or species[id] < 1 or species[id] == math.huge or species[id] == -math.huge then return nil end
    local safe = type(current) == "number" and current == current and current >= 0
        and current <= MAX_XP and current ~= math.huge and math.floor(current) or 0
    return math.min(MAX_XP, safe + 5)
end
function Rules.bonusXp(base, xp)
    if type(base) ~= "number" or base ~= base or base < 0 or base > 100000 or base == math.huge then return 0 end
    return math.floor(base * (Rules.level(xp) - 1) * 0.01)
end
return Rules
