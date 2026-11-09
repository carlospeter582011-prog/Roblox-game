-- Pure catch/reward/quest rules used by the server systems. No Roblox globals and no catalog
-- requires (catalogs are passed in), so tests/run.luau can exercise it with the plain Luau CLI.
local Rules = {}

Rules.XP_PER_CATCH = 10
Rules.DEFAULT_TOOL_ID = "starter_net"
Rules.MAX_TOOL_ID_LENGTH = 40

-- Returns (tool, toolId) the player may actually use: the equipped one if it exists and is
-- unlocked, otherwise the starter net.
function Rules.resolveTool(equippedId, captures, tools)
    local tool = nil
    if type(equippedId) == "string" then
        tool = tools[equippedId]
    end
    if tool and captures >= tool.unlockCatches then
        return tool, equippedId
    end
    return tools[Rules.DEFAULT_TOOL_ID], Rules.DEFAULT_TOOL_ID
end

-- Whether an equip request for toolId should be accepted.
function Rules.canEquip(toolId, captures, tools)
    if type(toolId) ~= "string" or #toolId > Rules.MAX_TOOL_ID_LENGTH then
        return false
    end
    local tool = tools[toolId]
    return tool ~= nil and captures >= tool.unlockCatches
end

function Rules.isInRange(distance, species, tool)
    return distance <= species.baseCatchRadius + tool.rangeBonus
end

function Rules.coinReward(species, tool)
    return math.floor(species.baseRewardCoins * tool.coinMultiplier)
end

function Rules.questProgress(quest, data)
    if quest.objective == "catch_species" then
        return data.species[quest.speciesId] or 0
    end
    return data.captures
end

-- Roblox attribute names may only contain letters, digits, underscores and hyphens (per the
-- documented rules; not Studio-verified here). Anything else would make SetAttribute error, so
-- only ids passing this check may be replicated as attributes.
function Rules.isAttributeSafe(name)
    return type(name) == "string" and #name > 0 and #name <= 90 and string.match(name, "^[%w_%-]+$") ~= nil
end

-- Records one catch on data and completes every quest it newly satisfies, awarding quest
-- rewards. Mutates data. Returns the newly completed quest ids, sorted.
-- options (optional): variantId = extra collection key for a mutated catch (e.g. "breeze:golden");
-- the base species is ALWAYS counted too so species quests and the encyclopedia stay correct.
-- xp = XP for this catch (default XP_PER_CATCH), used for mutation XP multipliers.
function Rules.applyCatch(data, speciesId, coins, quests, options)
    data.species[speciesId] = (data.species[speciesId] or 0) + 1
    local variantId = options and options.variantId
    if variantId and variantId ~= speciesId then
        data.species[variantId] = (data.species[variantId] or 0) + 1
    end
    data.captures += 1
    data.coins += coins
    data.xp += (options and options.xp) or Rules.XP_PER_CATCH
    local completed = {}
    for id, quest in pairs(quests) do
        if not data.quests[id] and Rules.questProgress(quest, data) >= quest.required then
            data.quests[id] = true
            data.coins += quest.rewardCoins
            data.xp += quest.rewardXP
            table.insert(completed, id)
        end
    end
    table.sort(completed)
    return completed
end

return Rules
