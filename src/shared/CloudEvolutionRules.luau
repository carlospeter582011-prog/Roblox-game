-- Pure evolution rules. No client-controlled currency, recipe or inventory changes.
local Rules = {}
Rules.Recipes = {
    { id = "breeze_to_gale", source = "breeze", result = "gale", copies = 2, bond = 10, coins = 120 },
    { id = "drizzle_to_mistveil", source = "drizzle", result = "mistveil", copies = 2, bond = 10, coins = 150 },
    { id = "thunder_to_stormfront", source = "thunder", result = "stormfront", copies = 2, bond = 40, coins = 320 },
}
local function integer(n, max)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
        and n >= 0 and n <= max and n == math.floor(n)
end
function Rules.canEvolve(data, recipe, catalog)
    if type(data) ~= "table" or type(recipe) ~= "table" or type(catalog) ~= "table" then return false, "Invalid request" end
    local known = false
    for _, entry in ipairs(Rules.Recipes) do
        if entry == recipe then known = true break end
    end
    if not known or not catalog[recipe.source] or not catalog[recipe.result] then return false, "Unknown evolution" end
    if type(data.species) ~= "table" or type(data.companionBond) ~= "table" then return false, "Inventory unavailable" end
    local count = data.species[recipe.source]
    local bond = data.companionBond[recipe.source] or 0
    local resultCount = data.species[recipe.result] or 0
    if not integer(count, 1000000) or not integer(resultCount, 1000000) or not integer(bond, 1000000)
        or not integer(data.coins, 1000000000) then return false, "Invalid profile values" end
    if count < recipe.copies then return false, "Keep one cloud and catch duplicates" end
    if bond < recipe.bond then return false, "Raise companion bond first" end
    if data.coins < recipe.coins then return false, "Not enough Coins" end
    if resultCount >= 1000000 then return false, "Collection limit reached" end
    return true, "Ready"
end
function Rules.apply(data, recipe, catalog)
    local ok, reason = Rules.canEvolve(data, recipe, catalog)
    if not ok then return false, reason end
    -- No yield between checks and mutations; all fields are server-owned.
    data.species[recipe.source] -= 1
    data.species[recipe.result] = (data.species[recipe.result] or 0) + 1
    data.coins -= recipe.coins
    return true, recipe.result
end
return Rules
