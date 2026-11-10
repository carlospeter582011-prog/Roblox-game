-- Pure server-side rules for repeatable Sky Forge training recipes.
local Forge = {}
Forge.Recipes = {
    spark = { name = "Spark Focus", cost = 60, xp = 25, catches = 5 },
    gale = { name = "Gale Focus", cost = 180, xp = 85, catches = 25 },
    tempest = { name = "Tempest Focus", cost = 450, xp = 230, catches = 75 },
}
local function integer(value)
    return type(value) == "number" and value == value and value ~= math.huge
        and value ~= -math.huge and value >= 0 and value == math.floor(value)
end
function Forge.validate(recipeId, coins, catches)
    if type(recipeId) ~= "string" then return false, "Invalid recipe" end
    local recipe = Forge.Recipes[recipeId]
    if not recipe then return false, "Invalid recipe" end
    if not integer(coins) or not integer(catches) then return false, "Invalid profile" end
    if catches < recipe.catches then return false, "Requires " .. recipe.catches .. " catches" end
    if coins < recipe.cost then return false, "Need " .. recipe.cost .. " Coins" end
    return true, recipe
end
return Forge
