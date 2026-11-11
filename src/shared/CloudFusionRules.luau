-- Pure, deterministic recipes; the server selects the recipe, never the client.
local Rules = {}
Rules.Recipes = table.freeze({
    { id = "mist_weave", first = "breeze", second = "drizzle", result = "mist", coins = 60 },
    { id = "storm_weave", first = "gale", second = "thunder", result = "stormfront", coins = 180 },
    { id = "aurora_weave", first = "frost", second = "sunbeam", result = "aurora", coins = 250 },
    { id = "blossom_weave", first = "spring", second = "pollen", result = "blossom", coins = 90 },
    { id = "solar_weave", first = "ember", second = "sunbeam", result = "solar", coins = 220 },
})
function Rules.recipe(id)
    if type(id) ~= "string" then return nil end
    for _, recipe in ipairs(Rules.Recipes) do
        if recipe.id == id then return recipe end
    end
    return nil
end
function Rules.canFuse(data, id, catalog)
    local recipe = Rules.recipe(id)
    if not recipe or type(data) ~= "table" or type(data.species) ~= "table" or type(catalog) ~= "table" then
        return false, "Invalid recipe"
    end
    if not catalog[recipe.first] or not catalog[recipe.second] or not catalog[recipe.result] then
        return false, "Unavailable species"
    end
    local a, b = data.species[recipe.first], data.species[recipe.second]
    -- Preserve at least one of each parent cloud; no fractional or corrupt quantities.
    if type(a) ~= "number" or type(b) ~= "number" or a ~= math.floor(a) or b ~= math.floor(b)
        or a < 2 or b < 2 or a == math.huge or b == math.huge then
        return false, "Keep one of each parent; catch duplicates"
    end
    if type(data.coins) ~= "number" or data.coins ~= data.coins or data.coins < recipe.coins then
        return false, "Not enough Coins"
    end
    local output = data.species[recipe.result] or 0
    if type(output) ~= "number" or output ~= math.floor(output) or output < 0 or output >= 999999 then
        return false, "Collection limit"
    end
    return true, recipe
end
function Rules.apply(data, id, catalog)
    local ok, recipe = Rules.canFuse(data, id, catalog)
    if not ok then return false, recipe end
    data.species[recipe.first] -= 1
    data.species[recipe.second] -= 1
    data.species[recipe.result] = (data.species[recipe.result] or 0) + 1
    data.coins -= recipe.coins
    return true, recipe
end
return Rules
