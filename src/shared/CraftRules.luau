-- Pure crafting rules for the Cloud Crafting Workshop. No Roblox globals.
-- Recipes convert surplus clouds + coins into persistent upgrades or temporary benefits.
-- All checks are deterministic and testable.

local Craft = {}

Craft.RECIPES = {
    speed_essence = {
        id = "speed_essence",
        name = "Speed Essence",
        description = "Convert 5 surplus clouds and 50 coins into a +8 WalkSpeed boost for 60 seconds.",
        requiredSurplus = 5,
        costCoins = 50,
        effect = "speed_boost",
        duration = 60,
        magnitude = 8,
    },
    coin_magnet = {
        id = "coin_magnet",
        name = "Coin Magnet",
        description = "Convert 10 surplus clouds and 100 coins into +15% coin rewards for the next 10 catches.",
        requiredSurplus = 10,
        costCoins = 100,
        effect = "coin_boost",
        charges = 10,
        magnitude = 0.15,
    },
    xp_catalyst = {
        id = "xp_catalyst",
        name = "XP Catalyst",
        description = "Convert 8 surplus clouds and 75 coins into +20% XP for the next 5 catches.",
        requiredSurplus = 8,
        costCoins = 75,
        effect = "xp_boost",
        charges = 5,
        magnitude = 0.2,
    },
}

function Craft.totalSurplus(species)
    if type(species) ~= "table" then return 0 end
    local total = 0
    for _, count in pairs(species) do
        if type(count) == "number" and count > 1 then
            total += math.floor(count - 1)
        end
    end
    return math.max(0, total)
end

function Craft.canCraft(recipeId, data)
    local recipe = Craft.RECIPES[recipeId]
    if not recipe or type(data) ~= "table" then return false, "Invalid recipe or profile" end
    local surplus = Craft.totalSurplus(data.species)
    if surplus < recipe.requiredSurplus then
        return false, "Need " .. recipe.requiredSurplus .. " surplus clouds (have " .. surplus .. ")"
    end
    if (data.coins or 0) < recipe.costCoins then
        return false, "Need " .. recipe.costCoins .. " coins"
    end
    return true, recipe
end

function Craft.applyCraft(recipeId, data)
    local ok, recipeOrMsg = Craft.canCraft(recipeId, data)
    if not ok then return false, recipeOrMsg end
    local recipe = recipeOrMsg
    -- Deduct surplus by reducing counts of species that have extras, preferring higher counts.
    local remaining = recipe.requiredSurplus
    local species = data.species or {}
    local ids = {}
    for id, count in pairs(species) do
        if type(count) == "number" and count > 1 then
            table.insert(ids, { id = id, extra = math.floor(count - 1) })
        end
    end
    table.sort(ids, function(a, b) return a.extra > b.extra end)
    for _, entry in ipairs(ids) do
        if remaining <= 0 then break end
        local take = math.min(entry.extra, remaining)
        species[entry.id] = species[entry.id] - take
        remaining -= take
    end
    data.coins = (data.coins or 0) - recipe.costCoins
    data.crafted = data.crafted or {}
    data.crafted[recipeId] = (data.crafted[recipeId] or 0) + 1
    return true, recipe
end

return Craft
