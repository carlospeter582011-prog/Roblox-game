-- Server-authoritative deterministic fusion recipes. No random paid outcomes.
-- Only spare copies can be consumed: the last copy of each input species is protected.
local Rules = {}
Rules.recipes = {
    mist_weave = { id = "mist_weave", name = "Mist Weave", inputs = { breeze = 2, drizzle = 2 }, output = "mist", coins = 80 },
    storm_charge = { id = "storm_charge", name = "Storm Charge", inputs = { breeze = 3, thunder = 1 }, output = "gale", coins = 180 },
    dawn_bloom = { id = "dawn_bloom", name = "Dawn Bloom", inputs = { spring = 2, sunbeam = 1 }, output = "autumn", coins = 120 },
}
local function validCount(n)
    return type(n) == "number" and n == n and n >= 0 and n < math.huge and n == math.floor(n)
end
function Rules.canFuse(data, recipeId, catalog)
    local recipe = type(recipeId) == "string" and Rules.recipes[recipeId] or nil
    if not recipe or type(data) ~= "table" or type(data.species) ~= "table" or type(catalog) ~= "table" then
        return false, "Invalid recipe"
    end
    if not catalog[recipe.output] then return false, "Unknown result" end
    if not validCount(data.coins) or data.coins < recipe.coins then return false, "Not enough Coins" end
    for speciesId, needed in pairs(recipe.inputs) do
        local count = data.species[speciesId]
        if not catalog[speciesId] or not validCount(count) or count <= needed then
            return false, "Keep one of every ingredient cloud"
        end
    end
    local resultCount = data.species[recipe.output] or 0
    if not validCount(resultCount) or resultCount >= 100000 then return false, "Collection limit" end
    return true, recipe
end
function Rules.apply(data, recipeId, catalog)
    local ok, recipe = Rules.canFuse(data, recipeId, catalog)
    if not ok then return false, recipe end
    -- No yields between validation and mutation: atomic within one Luau task.
    for speciesId, needed in pairs(recipe.inputs) do
        data.species[speciesId] -= needed
    end
    data.species[recipe.output] = (data.species[recipe.output] or 0) + 1
    data.coins -= recipe.coins
    return true, recipe.output
end
return table.freeze(Rules)
