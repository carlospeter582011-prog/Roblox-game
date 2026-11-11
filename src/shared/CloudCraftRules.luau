-- Pure, server-authoritative crafting transaction rules. No Roblox globals.
-- This module does not grant items: callers must persist the returned profile under
-- an owned session lock before acknowledging success.
local Craft = {}
Craft.recipes = {
    breeze_charm = { cost = 80, ingredients = { breeze = 3 }, product = "breeze_charm" },
    rain_lantern = { cost = 130, ingredients = { drizzle = 2, mist = 2 }, product = "rain_lantern" },
    storm_compass = { cost = 280, ingredients = { thunder = 2, gale = 2 }, product = "storm_compass" },
    frost_totem = { cost = 260, ingredients = { frost = 3 }, product = "frost_totem" },
    aurora_prism = { cost = 550, ingredients = { aurora = 2, rainbow = 2 }, product = "aurora_prism" },
}
local function integer(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge and n >= 0 and n == math.floor(n) and n <= 1000000000
end
function Craft.preview(profile, recipeId)
    if type(recipeId) ~= "string" or #recipeId > 40 then return nil, "invalid_recipe" end
    local recipe = Craft.recipes[recipeId]
    if not recipe then return nil, "unknown_recipe" end
    if type(profile) ~= "table" or type(profile.species) ~= "table"
        or type(profile.craftedItems) ~= "table" or not integer(profile.coins) then
        return nil, "invalid_profile"
    end
    if profile.coins < recipe.cost then return nil, "insufficient_coins" end
    if not integer(profile.craftedItems[recipe.product] or 0)
        or profile.craftedItems[recipe.product] >= 1000000 then
        return nil, "inventory_full"
    end
    for id, required in pairs(recipe.ingredients) do
        local count = profile.species[id]
        if not integer(count) or count <= required then
            -- Keep one living specimen of every consumed species.
            return nil, "insufficient_duplicates"
        end
    end
    local species = table.clone(profile.species)
    for id, required in pairs(recipe.ingredients) do
        species[id] -= required
    end
    local items = table.clone(profile.craftedItems)
    items[recipe.product] = (items[recipe.product] or 0) + 1
    return { coins = profile.coins - recipe.cost, species = species, craftedItems = items }, nil
end
return Craft
