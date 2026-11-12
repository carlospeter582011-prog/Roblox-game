-- Pure, server-authoritative duplicate fusion recipes. No random outcomes or Robux.
local Rules = {}
Rules.recipes = {
    mistweave = { a = "breeze", b = "drizzle", result = "mist", coins = 80 },
    thunderhead = { a = "gale", b = "thunder", result = "stormfront", coins = 180 },
    sunflare = { a = "ember", b = "sunbeam", result = "solar", coins = 220 },
}
local MAX_COINS = 1000000000
local MAX_COPIES = 1000000
local function validCount(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
        and n >= 0 and n <= MAX_COPIES and n == math.floor(n)
end
function Rules.preview(profile, recipeId, catalog)
    local recipe = type(recipeId) == "string" and Rules.recipes[recipeId] or nil
    if not recipe or type(profile) ~= "table" or type(profile.species) ~= "table"
        or type(catalog) ~= "table" then return nil, "Invalid recipe" end
    if not catalog[recipe.a] or not catalog[recipe.b] or not catalog[recipe.result] then
        return nil, "Species unavailable"
    end
    local coins = profile.coins
    if not validCount(coins) or coins > MAX_COINS then return nil, "Invalid wallet" end
    local a = profile.species[recipe.a] or 0
    local b = profile.species[recipe.b] or 0
    local output = profile.species[recipe.result] or 0
    if not validCount(a) or not validCount(b) or not validCount(output) then return nil, "Invalid inventory" end
    if a < 2 or b < 2 then return nil, "Keep one of each ingredient" end
    if coins < recipe.coins then return nil, "Not enough Coins" end
    if output >= MAX_COPIES then return nil, "Collection full" end
    return { a = recipe.a, b = recipe.b, result = recipe.result, cost = recipe.coins }
end
function Rules.apply(profile, recipeId, catalog)
    local plan, err = Rules.preview(profile, recipeId, catalog)
    if not plan then return false, err end
    profile.species[plan.a] -= 1
    profile.species[plan.b] -= 1
    profile.species[plan.result] = (profile.species[plan.result] or 0) + 1
    profile.coins -= plan.cost
    return true, plan
end
return Rules
