-- Server-authoritative permanent relic crafting. Pure logic for CI.
local Rules = {}
Rules.recipes = {
    lantern = { name = "Cloud Lantern", coins = 200, crystals = 3, xpPercent = 5 },
    charm = { name = "Wind Charm", coins = 400, crystals = 6, reach = 2 },
    compass = { name = "Storm Compass", coins = 750, crystals = 12, coinPercent = 10 },
}
local function validNumber(n)
    return type(n) == "number" and n == n and n >= 0 and n < 1e12
end
function Rules.crystalCount(crystals)
    if type(crystals) ~= "table" then return 0 end
    local count = 0
    for i = 1, 18 do
        if crystals[i] == true then count += 1 end
    end
    return count
end
function Rules.craft(data, id)
    local recipe = type(id) == "string" and Rules.recipes[id] or nil
    if not recipe or type(data) ~= "table" or not validNumber(data.coins) then
        return false, "Invalid recipe or profile"
    end
    if type(data.craftedRelics) ~= "table" then data.craftedRelics = {} end
    if data.craftedRelics[id] then return false, "Already crafted" end
    if Rules.crystalCount(data.crystals) < recipe.crystals then
        return false, "Discover " .. recipe.crystals .. " sky crystals first"
    end
    if data.coins < recipe.coins then return false, "Need " .. recipe.coins .. " Coins" end
    data.coins -= recipe.coins
    data.craftedRelics[id] = true
    return true, "Crafted " .. recipe.name
end
function Rules.has(data, id)
    return type(data) == "table" and type(data.craftedRelics) == "table"
        and data.craftedRelics[id] == true and Rules.recipes[id] ~= nil
end
function Rules.catchXpBonus(data, base)
    if not Rules.has(data, "lantern") or not validNumber(base) then return 0 end
    return math.floor(base * 0.05)
end
function Rules.catchCoinBonus(data, base)
    if not Rules.has(data, "compass") or not validNumber(base) then return 0 end
    return math.floor(base * 0.10)
end
function Rules.reachBonus(data)
    return Rules.has(data, "charm") and 2 or 0
end
return Rules
