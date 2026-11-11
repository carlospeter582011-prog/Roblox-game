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
-- Validate and preview a whole crafting queue without mutating balances or items.
-- A failed step rejects the entire queue; callers must still commit under a session lock.
function Crafting.previewBatch(requests, coins, materials, ownedItems)
    if type(requests) ~= "table" or #requests == 0 or #requests > 20 then
        return nil, "invalid_batch"
    end
    if not safeCount(coins) or type(materials) ~= "table" or type(ownedItems) ~= "table" then
        return nil, "invalid_inventory"
    end
    local remaining = {}
    local outputs = {}
    for id, count in pairs(materials) do
        if type(id) ~= "string" or not safeCount(count) then return nil, "invalid_inventory" end
        remaining[id] = count
    end
    for id, count in pairs(ownedItems) do
        if type(id) ~= "string" or not safeCount(count) then return nil, "invalid_inventory" end
        outputs[id] = count
    end
    local total = 0
    for index = 1, #requests do
        local request = requests[index]
        if type(request) ~= "table" or type(request.recipeId) ~= "string"
            or not safeCount(request.quantity) or request.quantity < 1 or request.quantity > 100 then
            return nil, "invalid_request"
        end
        total += request.quantity
        if total > 100 then return nil, "batch_limit" end
        local recipe = Crafting.Recipes[request.recipeId]
        if not recipe then return nil, "unknown_recipe" end
        local charge = recipe.costCoins * request.quantity
        if coins < charge then return nil, "insufficient_coins" end
        for material, count in pairs(recipe.materials) do
            local needed = count * request.quantity
            if not safeCount(remaining[material]) then return nil, "invalid_inventory" end
            if remaining[material] < needed then return nil, "insufficient_materials" end
        end
        local gained = recipe.quantity * request.quantity
        local old = outputs[recipe.output] or 0
        if not safeCount(old + gained) then return nil, "output_overflow" end
        coins -= charge
        for material, count in pairs(recipe.materials) do
            remaining[material] -= count * request.quantity
        end
        outputs[recipe.output] = old + gained
    end
    return { coins = coins, materials = remaining, items = outputs }, "ok"
end
return Crafting
