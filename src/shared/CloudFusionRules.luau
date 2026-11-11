-- Server-authoritative fusion contract. Pure Luau, independent of Roblox globals.
-- This prepares a safe duplicate-cloud sink; no UI or profile mutation is wired yet.
local Rules = {}
local MAX_WALLET = 999999999999
local COST = { Common = 50, Uncommon = 125, Rare = 300, Epic = 750, Legendary = 1500, Mythic = 3000, Secret = 6000 }
local function count(v)
    return type(v) == "number" and v == v and v ~= math.huge and v >= 0 and v <= 100000 and math.floor(v) == v
end
local function wallet(v)
    return type(v) == "number" and v == v and v ~= math.huge and v >= 0 and v <= MAX_WALLET and math.floor(v) == v
end
function Rules.preview(first, second, species, coins, catalog)
    if type(first) ~= "string" or type(second) ~= "string" or first == second then
        return { ok = false, reason = "distinct_species_required" }
    end
    if type(catalog) ~= "table" or type(species) ~= "table" then
        return { ok = false, reason = "invalid_inventory" }
    end
    local a, b = catalog[first], catalog[second]
    if not a or not b or a.id ~= first or b.id ~= second then
        return { ok = false, reason = "unknown_species" }
    end
    if a.element ~= b.element or type(a.element) ~= "string" then
        return { ok = false, reason = "element_mismatch" }
    end
    local ca, cb = species[first], species[second]
    if not count(ca) or not count(cb) or ca < 2 or cb < 2 then
        return { ok = false, reason = "duplicates_required" }
    end
    if not wallet(coins) then return { ok = false, reason = "invalid_wallet" } end
    local cost = math.max(COST[a.rarity] or 300, COST[b.rarity] or 300)
    if coins < cost then return { ok = false, reason = "insufficient_coins", cost = cost } end
    -- Deterministic output is the rarer ingredient (lexicographic tiebreak);
    -- fusion improves its bond without generating an uncatalogued species.
    local rarity = { Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5, Mythic=6, Secret=7 }
    local ra, rb = rarity[a.rarity] or 0, rarity[b.rarity] or 0
    local output = ra > rb and first or rb > ra and second or (first < second and first or second)
    return { ok = true, cost = cost, output = output, element = a.element }
end
function Rules.apply(first, second, species, coins, catalog)
    local p = Rules.preview(first, second, species, coins, catalog)
    if not p.ok then return p end
    local inventory = {}
    for id, amount in pairs(species) do inventory[id] = amount end
    inventory[first] -= 1
    inventory[second] -= 1
    -- One new output offsets two consumed duplicates: no net species creation.
    if not count(inventory[p.output]) or inventory[p.output] >= 100000 then
        return { ok = false, reason = "inventory_limit" }
    end
    inventory[p.output] += 1
    return { ok = true, cost = p.cost, output = p.output, coins = coins - p.cost, species = inventory }
end
return Rules
