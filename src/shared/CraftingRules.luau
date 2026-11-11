-- Pure crafting validation and application. No Roblox globals.
-- Recipes consume materials + coins to unlock improved tools or permanent bonuses.
local Rules = {}

-- Example recipes: unlock or enhance specific tools beyond catch-count gates.
-- In practice, these can supplement or replace pure catch-count unlocks.
Rules.RECIPES = {
    wind_lasso_craft = {
        id = "wind_lasso_craft",
        resultTool = "wind_lasso",
        costCoins = 40,
        materials = { air_essence = 5 },
        description = "Craft Wind Lasso from Air Essence",
    },
    mist_gloves_craft = {
        id = "mist_gloves_craft",
        resultTool = "mist_gloves",
        costCoins = 60,
        materials = { water_droplet = 6, air_essence = 2 },
        description = "Craft Mist Gloves",
    },
    golden_net_upgrade = {
        id = "golden_net_upgrade",
        resultTool = "golden_net",
        costCoins = 150,
        materials = { light_mote = 8, fire_spark = 4 },
        description = "Craft Golden Net (higher coin multiplier)",
    },
    storm_vacuum_craft = {
        id = "storm_vacuum_craft",
        resultTool = "storm_vacuum",
        costCoins = 200,
        materials = { storm_charge = 10, air_essence = 5 },
        description = "Craft Storm Vacuum",
    },
}

function Rules.canCraft(recipeId, profile, materialCatalog)
    local recipe = Rules.RECIPES[recipeId]
    if not recipe then
        return false, "unknown_recipe"
    end
    if profile.ownedTools and profile.ownedTools[recipe.resultTool] then
        return false, "already_owned"
    end
    if (profile.coins or 0) < recipe.costCoins then
        return false, "insufficient_coins"
    end
    local materials = profile.materials or {}
    for matId, needed in pairs(recipe.materials) do
        if (materials[matId] or 0) < needed then
            return false, "insufficient_materials"
        end
        if not materialCatalog or not materialCatalog[matId] then
            return false, "invalid_material"
        end
    end
    return true
end

function Rules.applyCraft(recipeId, profile, materialCatalog)
    local ok, reason = Rules.canCraft(recipeId, profile, materialCatalog)
    if not ok then
        return false, reason
    end
    local recipe = Rules.RECIPES[recipeId]
    profile.coins = (profile.coins or 0) - recipe.costCoins
    profile.materials = profile.materials or {}
    for matId, needed in pairs(recipe.materials) do
        profile.materials[matId] = (profile.materials[matId] or 0) - needed
        if profile.materials[matId] <= 0 then
            profile.materials[matId] = nil
        end
    end
    profile.ownedTools = profile.ownedTools or {}
    profile.ownedTools[recipe.resultTool] = true
    return true, recipe.resultTool
end

-- Award materials on successful catch. Returns table of {matId = amount}.
function Rules.awardMaterials(speciesElement, rarity, rng)
    rng = rng or math.random
    local awards = {}
    local baseAmount = 1
    if rarity == "Rare" or rarity == "Epic" then
        baseAmount = 2
    elseif rarity == "Legendary" or rarity == "Mythic" then
        baseAmount = 3
    end
    -- Map element to primary material
    local elementToMat = {
        Air = "air_essence",
        Water = "water_droplet",
        Earth = "earth_shard",
        Fire = "fire_spark",
        Ice = "ice_crystal",
        Light = "light_mote",
        Shadow = "shadow_wisp",
        Storm = "storm_charge",
        Nature = "nature_seed",
        Cosmic = "cosmic_dust",
    }
    local matId = elementToMat[speciesElement]
    if matId then
        awards[matId] = baseAmount
        -- Small chance of bonus
        if rng() < 0.15 then
            awards[matId] = awards[matId] + 1
        end
    end
    return awards
end

return Rules
