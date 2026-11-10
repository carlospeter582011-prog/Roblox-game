-- Pure, deterministic cloud evolution. No Roblox globals.
-- Stages 0-3. Evolution requires owned species, a catch threshold and Coins.
-- Duplicates are not consumed (protection for valuable clouds); thresholds gate progression.
local Rules = {}

Rules.MAX_STAGE = 3
Rules.COSTS = { 50, 150, 400 } -- coins to reach stage 1, 2, 3
Rules.THRESHOLDS = { 3, 8, 20 } -- total catches of the species required
Rules.XP_BONUS = { 0, 0.05, 0.10, 0.15 } -- stage 0-3 multiplier on catch XP when that species is equipped

function Rules.stage(evolutions, speciesId)
    if type(evolutions) ~= "table" or type(speciesId) ~= "string" then return 0 end
    local value = evolutions[speciesId]
    if type(value) ~= "number" or value ~= value or value < 0 then return 0 end
    return math.floor(math.min(value, Rules.MAX_STAGE))
end

-- Returns true, nextStage, coinCost or false, reason.
function Rules.canEvolve(speciesId, species, evolutions, coins, catalog)
    if type(speciesId) ~= "string" or type(catalog) ~= "table" or catalog[speciesId] == nil then
        return false, "Unknown species"
    end
    if type(species) ~= "table" or type(species[speciesId]) ~= "number" or species[speciesId] < 1 then
        return false, "Catch this cloud first"
    end
    local current = Rules.stage(evolutions, speciesId)
    if current >= Rules.MAX_STAGE then return false, "Already fully evolved" end
    local nextStage = current + 1
    local needCoins = Rules.COSTS[nextStage]
    local needCount = Rules.THRESHOLDS[nextStage]
    if type(coins) ~= "number" or coins ~= coins or coins < needCoins then
        return false, "Need " .. needCoins .. " coins"
    end
    if species[speciesId] < needCount then
        return false, "Need " .. needCount .. " of this species"
    end
    return true, nextStage, needCoins
end

function Rules.xpBonus(baseXp, stage)
    if type(baseXp) ~= "number" or baseXp ~= baseXp or baseXp < 0 or baseXp == math.huge or baseXp > 100000 then
        return 0
    end
    local safe = math.floor(math.min(math.max(tonumber(stage) or 0, 0), Rules.MAX_STAGE))
    return math.floor(baseXp * Rules.XP_BONUS[safe + 1])
end

return Rules
