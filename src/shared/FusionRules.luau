-- Pure fusion rules. No Roblox globals. Consumes owned species counts to produce a result species.
-- Recipes are data-driven; expand without changing existing IDs.
local Rules = {}

-- Example recipes: two of the same base species of sufficient count can fuse into a themed result.
-- In production expand to elemental or rarity-based fusions.
Rules.RECIPES = {
    {
        id = "breeze_pair",
        inputs = { { speciesId = "breeze", count = 2 } },
        output = { speciesId = "gale", count = 1 },
        minCaptures = 10,
    },
    {
        id = "drizzle_pair",
        inputs = { { speciesId = "drizzle", count = 2 } },
        output = { speciesId = "monsoon", count = 1 },
        minCaptures = 15,
    },
    {
        id = "ember_pair",
        inputs = { { speciesId = "ember", count = 2 } },
        output = { speciesId = "inferno", count = 1 },
        minCaptures = 25,
    },
}

function Rules.findRecipe(recipeId)
    for _, recipe in ipairs(Rules.RECIPES) do
        if recipe.id == recipeId then
            return recipe
        end
    end
    return nil
end

-- Returns true if the player owns enough of each input and meets capture threshold.
function Rules.canFuse(data, recipe)
    if type(data) ~= "table" or type(recipe) ~= "table" then
        return false
    end
    if type(data.captures) ~= "number" or data.captures < (recipe.minCaptures or 0) then
        return false
    end
    if type(data.species) ~= "table" then
        return false
    end
    for _, input in ipairs(recipe.inputs or {}) do
        local owned = data.species[input.speciesId] or 0
        if type(owned) ~= "number" or owned < (input.count or 1) then
            return false
        end
    end
    return true
end

-- Mutates data: subtracts inputs, adds output. Returns true on success.
function Rules.applyFusion(data, recipe)
    if not Rules.canFuse(data, recipe) then
        return false
    end
    for _, input in ipairs(recipe.inputs) do
        data.species[input.speciesId] = (data.species[input.speciesId] or 0) - input.count
        if data.species[input.speciesId] <= 0 then
            data.species[input.speciesId] = nil
        end
    end
    local out = recipe.output
    data.species[out.speciesId] = (data.species[out.speciesId] or 0) + (out.count or 1)
    return true
end

return Rules
