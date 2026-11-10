-- Pure, deterministic island habitat production rules. No Roblox services or client trust.
-- A production job is only a proposal until a server-owned profile transaction commits it.
local Rules = {}
Rules.MAX_OFFLINE_SECONDS = 8 * 60 * 60
Rules.MAX_JOBS = 12
Rules.RECIPES = table.freeze({
    breeze_nest = table.freeze({ interval = 120, yield = 3, maxStored = 240, costCoins = 100, element = "Air" }),
    rain_garden = table.freeze({ interval = 180, yield = 5, maxStored = 300, costCoins = 200, element = "Water" }),
    storm_turbine = table.freeze({ interval = 300, yield = 12, maxStored = 480, costCoins = 500, element = "Storm" }),
    blossom_orchard = table.freeze({ interval = 240, yield = 7, maxStored = 350, costCoins = 300, element = "Nature" }),
})
local function whole(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
        and n >= 0 and n == math.floor(n)
end
function Rules.canBuild(recipeId, coins, count, ownedSpecies, catalog)
    local recipe = type(recipeId) == "string" and Rules.RECIPES[recipeId]
    if not recipe then return false, "unknown_recipe" end
    if not whole(coins) or not whole(count) or count >= Rules.MAX_JOBS then
        return false, "invalid_capacity"
    end
    if coins < recipe.costCoins then return false, "insufficient_coins" end
    local hasElement = false
    if type(ownedSpecies) == "table" and type(catalog) == "table" then
        for id, amount in pairs(ownedSpecies) do
            if whole(amount) and amount > 0 and catalog[id] and catalog[id].element == recipe.element then
                hasElement = true
                break
            end
        end
    end
    if not hasElement then return false, "missing_element" end
    return true
end
-- Computes total generated coins, never mutates caller data.
-- Carry seconds remain to avoid losing fractional production intervals on frequent claims.
function Rules.harvest(recipeId, elapsedSeconds, storedCoins, carrySeconds)
    local recipe = type(recipeId) == "string" and Rules.RECIPES[recipeId]
    if not recipe or not whole(elapsedSeconds) or not whole(storedCoins)
        or not whole(carrySeconds) or carrySeconds >= recipe.interval then
        return nil, "invalid_state"
    end
    local bounded = math.min(elapsedSeconds, Rules.MAX_OFFLINE_SECONDS)
    local ticks = math.floor((bounded + carrySeconds) / recipe.interval)
    local available = math.max(0, recipe.maxStored - math.min(storedCoins, recipe.maxStored))
    local generated = math.min(available, ticks * recipe.yield)
    return {
        generated = generated,
        stored = math.min(recipe.maxStored, storedCoins + generated),
        carry = (bounded + carrySeconds) % recipe.interval,
        cappedOffline = elapsedSeconds > Rules.MAX_OFFLINE_SECONDS,
    }
end
return table.freeze(Rules)
