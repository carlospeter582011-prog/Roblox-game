-- Pure server-side recipes for turning spare clouds into permanent catching tools.
-- Each recipe consumes ONLY duplicates and cannot bypass catch progression.
local Recipes = {
    wind_lasso = { coins = 20, ingredients = { breeze = 2 } },
    mist_gloves = { coins = 35, ingredients = { drizzle = 2, mist = 1 } },
    cloud_magnet = { coins = 60, ingredients = { breeze = 2, cirrus = 1 } },
    golden_net = { coins = 100, ingredients = { sunbeam = 2, breeze = 2 } },
    storm_vacuum = { coins = 180, ingredients = { thunder = 1, drizzle = 2 } },
}
local Rules = {}
Rules.Recipes = Recipes

function Rules.canCraft(data, toolId, tools)
    local recipe, tool = Recipes[toolId], tools[toolId]
    if not recipe or not tool or type(data) ~= "table" then return false, "Unknown recipe" end
    if type(data.ownedTools) ~= "table" or type(data.species) ~= "table" then return false, "Profile unavailable" end
    if data.ownedTools[toolId] then return false, "Already owned" end
    if type(data.captures) ~= "number" or data.captures < tool.unlockCatches then return false, "More catches required" end
    if type(data.coins) ~= "number" or data.coins ~= data.coins or data.coins < recipe.coins then return false, "Not enough Coins" end
    for id, amount in pairs(recipe.ingredients) do
        local count = data.species[id]
        if type(count) ~= "number" or count ~= count or count < amount + 1 or count ~= math.floor(count) then
            return false, "Keep one of each cloud"
        end
    end
    return true, "Ready"
end

function Rules.craft(data, toolId, tools)
    local ok, reason = Rules.canCraft(data, toolId, tools)
    if not ok then return false, reason end
    local recipe = Recipes[toolId]
    -- All validation completes before any mutation; no yield in transaction.
    for id, amount in pairs(recipe.ingredients) do data.species[id] -= amount end
    data.coins -= recipe.coins
    data.ownedTools[toolId] = true
    return true, "Crafted " .. tools[toolId].name
end
return Rules
