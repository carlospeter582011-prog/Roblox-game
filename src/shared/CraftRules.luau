-- Pure, deterministic recipes. Crafting consumes duplicate clouds but never lifetime captures.
local Recipes = {
    wind_lasso = { species = { breeze = 3, cirrus = 1 }, coins = 25 },
    mist_gloves = { species = { drizzle = 3, mist = 2 }, coins = 40 },
    cloud_magnet = { species = { pebble = 4, gale = 2 }, coins = 65 },
}
local Craft = {}
Craft.Recipes = Recipes
function Craft.check(data, toolId, tools)
    if type(toolId) ~= "string" then return false, "Invalid recipe" end
    local recipe, tool = Recipes[toolId], tools[toolId]
    if not recipe or not tool or type(data) ~= "table" then return false, "Invalid recipe" end
    if type(data.ownedTools) ~= "table" or type(data.species) ~= "table" then return false, "Profile unavailable" end
    if data.ownedTools[toolId] then return false, "Already owned" end
    if type(data.captures) ~= "number" or data.captures < tool.unlockCatches then
        return false, "More catches required"
    end
    if type(data.coins) ~= "number" or data.coins ~= data.coins or data.coins < recipe.coins then
        return false, "Not enough Coins"
    end
    for speciesId, amount in pairs(recipe.species) do
        local count = data.species[speciesId]
        -- Keep one specimen of every ingredient species; never consume a last copy.
        if type(count) ~= "number" or count ~= count or count < amount + 1 then
            return false, "Keep one of each cloud; catch more " .. speciesId
        end
    end
    return true, recipe
end
function Craft.apply(data, toolId, tools)
    local ok, recipe = Craft.check(data, toolId, tools)
    if not ok then return false, recipe end
    -- All checks complete before mutation; caller must execute without yielding.
    for speciesId, amount in pairs(recipe.species) do
        data.species[speciesId] -= amount
    end
    data.coins -= recipe.coins
    data.ownedTools[toolId] = true
    return true, "Crafted " .. tools[toolId].name
end
return table.freeze(Craft)
