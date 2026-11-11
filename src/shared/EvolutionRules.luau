-- Pure evolution rules. No Roblox globals so unit tests can run them.
local Rules = {}

function Rules.canEvolve(recipeId, data, recipes, cloudCatalog)
    local recipe = recipes[recipeId]
    if not recipe or not data or type(data.species) ~= "table" then
        return false, "invalid"
    end
    if not cloudCatalog[recipe.fromSpecies] or not cloudCatalog[recipe.toSpecies] then
        return false, "unknown_species"
    end
    local have = data.species[recipe.fromSpecies] or 0
    if have < recipe.required then
        return false, "insufficient"
    end
    return true
end

-- Mutates data.species. Returns true, toSpecies on success.
function Rules.applyEvolve(data, recipeId, recipes, cloudCatalog)
    local ok, reason = Rules.canEvolve(recipeId, data, recipes, cloudCatalog)
    if not ok then
        return false, reason
    end
    local recipe = recipes[recipeId]
    data.species[recipe.fromSpecies] = data.species[recipe.fromSpecies] - recipe.required
    if data.species[recipe.fromSpecies] <= 0 then
        data.species[recipe.fromSpecies] = nil
    end
    data.species[recipe.toSpecies] = (data.species[recipe.toSpecies] or 0) + 1
    return true, recipe.toSpecies
end

return Rules
