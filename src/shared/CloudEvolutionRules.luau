-- Pure evolution rules. No Roblox globals. Catalogs passed in so tests can exercise them.
local Rules = {}

-- Deterministic recipes: consume one of parent, spend coins, grant one of result.
-- All IDs must exist in the provided catalog. Coins must be positive integers.
Rules.RECIPES = {
    {
        id = "breeze_to_cirrus",
        parent = "breeze",
        result = "cirrus",
        coinCost = 40,
        minCaptures = 5,
    },
    {
        id = "drizzle_to_mist",
        parent = "drizzle",
        result = "mist",
        coinCost = 35,
        minCaptures = 4,
    },
    {
        id = "pebble_to_pebbleflow",
        parent = "pebble",
        result = "pebbleflow",
        coinCost = 50,
        minCaptures = 6,
    },
    {
        id = "spring_to_blossom",
        parent = "spring",
        result = "blossom",
        coinCost = 45,
        minCaptures = 5,
    },
    {
        id = "frost_to_glacier",
        parent = "frost",
        result = "glacier",
        coinCost = 120,
        minCaptures = 10,
    },
}

function Rules.findRecipe(recipeId)
    if type(recipeId) ~= "string" then return nil end
    for _, recipe in ipairs(Rules.RECIPES) do
        if recipe.id == recipeId then return recipe end
    end
    return nil
end

-- Returns true, nil on success; false, reason otherwise. Mutates data on success.
function Rules.canEvolve(data, recipe, catalog)
    if type(data) ~= "table" or type(recipe) ~= "table" or type(catalog) ~= "table" then
        return false, "invalid_args"
    end
    if not catalog[recipe.parent] or not catalog[recipe.result] then
        return false, "unknown_species"
    end
    local owned = data.species and data.species[recipe.parent] or 0
    if type(owned) ~= "number" or owned < 1 then
        return false, "missing_parent"
    end
    if type(data.coins) ~= "number" or data.coins < recipe.coinCost then
        return false, "insufficient_coins"
    end
    if type(data.captures) ~= "number" or data.captures < recipe.minCaptures then
        return false, "insufficient_captures"
    end
    return true
end

function Rules.applyEvolution(data, recipe, catalog)
    local ok, reason = Rules.canEvolve(data, recipe, catalog)
    if not ok then return false, reason end
    data.species[recipe.parent] = data.species[recipe.parent] - 1
    if data.species[recipe.parent] <= 0 then
        data.species[recipe.parent] = nil
    end
    data.species[recipe.result] = (data.species[recipe.result] or 0) + 1
    data.coins = data.coins - recipe.coinCost
    return true, recipe.result
end

return Rules
