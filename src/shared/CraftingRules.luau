-- Deterministic, server-authoritative crafting recipe policy.
-- This module does not grant items or mutate profiles. Transactions must be performed
-- by a server-side inventory service under the player's session lock.
local Crafting = {}
Crafting.Recipes = {
    breeze_lure = { costCoins = 80, materials = { air_essence = 3 }, output = "breeze_lure", quantity = 1 },
    storm_lure = { costCoins = 180, materials = { storm_essence = 4, air_essence = 2 }, output = "storm_lure", quantity = 1 },
    cloud_habitat = { costCoins = 300, materials = { air_essence = 6, nature_essence = 5 }, output = "cloud_habitat", quantity = 1 },
    sky_bridge = { costCoins = 220, materials = { earth_essence = 5, air_essence = 3 }, output = "sky_bridge", quantity = 1 },
}
local function safeCount(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
        and n >= 0 and n <= 1000000000 and n == math.floor(n)
end
function Crafting.canCraft(recipeId, coins, inventory)
    local recipe = type(recipeId) == "string" and Crafting.Recipes[recipeId] or nil
    if not recipe then return false, "unknown_recipe" end
    if not safeCount(coins) or type(inventory) ~= "table" then return false, "invalid_inventory" end
    if coins < recipe.costCoins then return false, "insufficient_coins" end
    for material, needed in pairs(recipe.materials) do
        if not safeCount(inventory[material]) then return false, "invalid_inventory" end
        if inventory[material] < needed then return false, "insufficient_materials" end
    end
    return true, "ok"
end
-- Produce a proposed immutable transaction. Caller must commit atomically and persist.
function Crafting.preview(recipeId, coins, inventory)
    local ok, reason = Crafting.canCraft(recipeId, coins, inventory)
    if not ok then return nil, reason end
    local recipe = Crafting.Recipes[recipeId]
    local remaining = {}
    for key, value in pairs(inventory) do
        if not safeCount(value) then return nil, "invalid_inventory" end
        remaining[key] = value
    end
    for material, needed in pairs(recipe.materials) do
        remaining[material] -= needed
    end
    return { coins = coins - recipe.costCoins, materials = remaining,
        output = recipe.output, quantity = recipe.quantity }, "ok"
end
return Crafting
