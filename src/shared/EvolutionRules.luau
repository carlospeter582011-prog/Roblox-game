-- Pure evolution rules for Catch a Cloud. Server must validate ownership, stock, coins and cooldowns.
-- No Roblox globals. Outputs are existing catalog species; consumes one input copy.
local Rules = {}

-- Fixed recipes: inputSpecies -> { output = string, minCount = number, costCoins = number, bondRequired = number }
Rules.RECIPES = {
    breeze = { output = "gale", minCount = 5, costCoins = 80, bondRequired = 0 },
    drizzle = { output = "mist", minCount = 4, costCoins = 60, bondRequired = 0 },
    pebble = { output = "pebbleflow", minCount = 5, costCoins = 70, bondRequired = 0 },
    spring = { output = "blossom", minCount = 4, costCoins = 90, bondRequired = 1 },
    thunder = { output = "stormfront", minCount = 3, costCoins = 150, bondRequired = 1 },
}

function Rules.getRecipe(inputId)
    return type(inputId) == "string" and Rules.RECIPES[inputId] or nil
end

function Rules.canEvolve(inputId, species, coins, companionBond, catalog)
    local recipe = Rules.getRecipe(inputId)
    if not recipe or not catalog[recipe.output] then return false, "Unknown evolution" end
    local count = type(species) == "table" and type(species[inputId]) == "number" and species[inputId] or 0
    if count < recipe.minCount then return false, "Need at least " .. recipe.minCount .. " " .. inputId end
    if type(coins) ~= "number" or coins < recipe.costCoins then return false, "Need " .. recipe.costCoins .. " coins" end
    local bond = type(companionBond) == "table" and type(companionBond[inputId]) == "number" and companionBond[inputId] or 0
    if bond < recipe.bondRequired then return false, "Bond level too low" end
    return true, recipe
end

-- Apply mutation to a copy of species/coins. Returns newSpecies, newCoins, outputId or nil.
function Rules.apply(inputId, species, coins, companionBond, catalog)
    local ok, recipeOrErr = Rules.canEvolve(inputId, species, coins, companionBond, catalog)
    if not ok then return nil, recipeOrErr end
    local recipe = recipeOrErr
    local newSpecies = {}
    for k, v in pairs(species or {}) do newSpecies[k] = v end
    newSpecies[inputId] = (newSpecies[inputId] or 0) - 1
    if newSpecies[inputId] <= 0 then newSpecies[inputId] = nil end
    newSpecies[recipe.output] = (newSpecies[recipe.output] or 0) + 1
    return newSpecies, coins - recipe.costCoins, recipe.output
end

return Rules
