-- Pure mutation rules. No Roblox globals.
local Mutations = {
    golden = { id = "golden", name = "Golden", coinMultiplier = 3, xpMultiplier = 2, weight = 4 },
    rainbow = { id = "rainbow", name = "Rainbow", coinMultiplier = 5, xpMultiplier = 3, weight = 2 },
    electric = { id = "electric", name = "Electric", coinMultiplier = 2.5, xpMultiplier = 2, weight = 3 },
    storm = { id = "storm", name = "Storm", coinMultiplier = 2, xpMultiplier = 1.5, weight = 5 },
}

Mutations.MUTATION_CHANCE = 0.08

function Mutations.roll(rng)
    if rng() > Mutations.MUTATION_CHANCE then return nil end
    local ids, total = {}, 0
    for id, m in pairs(Mutations) do
        if type(m) == "table" and type(m.weight) == "number" then
            table.insert(ids, id)
            total += m.weight
        end
    end
    if total <= 0 then return nil end
    table.sort(ids)
    local target = rng() * total
    local acc = 0
    for _, id in ipairs(ids) do
        acc += Mutations[id].weight
        if target < acc then return id end
    end
    return ids[#ids]
end

function Mutations.key(speciesId, mutationId)
    if not mutationId then return speciesId end
    return speciesId .. ":" .. mutationId
end

function Mutations.bonusCoins(base, mutationId)
    local m = Mutations[mutationId]
    return m and math.floor(base * m.coinMultiplier) or base
end

function Mutations.bonusXp(base, mutationId)
    local m = Mutations[mutationId]
    return m and math.floor(base * m.xpMultiplier) or base
end

return Mutations
