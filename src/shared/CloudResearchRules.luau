-- Pure, server-authoritative permanent research progression.
local Research = {}
Research.COSTS = { 150, 400, 900 }
Research.REQUIRED_CATCHES = { 10, 40, 100 }
Research.MAX_LEVEL = #Research.COSTS
local function valid(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function Research.level(value)
    if not valid(value) or value < 0 then return 0 end
    return math.clamp(math.floor(value), 0, Research.MAX_LEVEL)
end
function Research.purchase(data)
    if type(data) ~= "table" then return false, "Profile unavailable" end
    local level = Research.level(data.researchLevel)
    if level >= Research.MAX_LEVEL then return false, "Research complete" end
    local nextLevel = level + 1
    if not valid(data.captures) or data.captures < Research.REQUIRED_CATCHES[nextLevel] then
        return false, "Requires " .. Research.REQUIRED_CATCHES[nextLevel] .. " catches"
    end
    local cost = Research.COSTS[nextLevel]
    if not valid(data.coins) or data.coins < cost then return false, "Need " .. cost .. " Coins" end
    data.coins -= cost
    data.researchLevel = nextLevel
    return true, "Research level " .. nextLevel .. " unlocked"
end
function Research.bonusXp(baseXp, level)
    if not valid(baseXp) or baseXp < 0 then return 0 end
    return math.floor(baseXp * Research.level(level) * 0.1)
end
return Research
