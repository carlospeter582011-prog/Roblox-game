-- Pure server-side rules for elemental cloud habitat work assignments.
local Rules = {}
Rules.HABITATS = {
    air = { element = "Air", coins = 35, xp = 18, cooldown = 180 },
    water = { element = "Water", coins = 42, xp = 20, cooldown = 210 },
    nature = { element = "Nature", coins = 50, xp = 24, cooldown = 240 },
}
function Rules.eligible(habitatId, speciesId, inventory, catalog)
    local habitat = Rules.HABITATS[habitatId]
    local species = type(speciesId) == "string" and catalog[speciesId] or nil
    local count = type(inventory) == "table" and inventory[speciesId] or nil
    return habitat ~= nil and species ~= nil and species.element == habitat.element
        and type(count) == "number" and count == count and count >= 1 and count < math.huge
end
function Rules.reward(habitatId, speciesId, inventory, catalog, bond)
    if not Rules.eligible(habitatId, speciesId, inventory, catalog) then return nil end
    local h = Rules.HABITATS[habitatId]
    local points = type(bond) == "table" and bond[speciesId] or 0
    local bonus = type(points) == "number" and points == points and points >= 40 and points < math.huge and 1.1 or 1
    return math.floor(h.coins * bonus), h.xp
end
function Rules.ready(now, last, cooldown)
    return type(now) == "number" and now == now and now >= 0
        and type(cooldown) == "number" and cooldown > 0
        and (last == nil or (type(last) == "number" and last == last and now - last >= cooldown))
end
return Rules
