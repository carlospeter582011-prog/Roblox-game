-- Pure, server-side validation for repeatable Cloud Survey commissions.
local Rules = {}
Rules.TIERS = {
    { required = 3, coins = 40, xp = 25, cooldown = 120 },
    { required = 8, coins = 110, xp = 70, cooldown = 240 },
    { required = 15, coins = 240, xp = 150, cooldown = 480 },
}
local function integer(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge and n >= 0 and n == math.floor(n)
end
function Rules.uniqueOwned(species, catalog)
    if type(species) ~= "table" or type(catalog) ~= "table" then return 0 end
    local count = 0
    for id, quantity in pairs(species) do
        if type(id) == "string" and catalog[id] and integer(quantity) and quantity > 0 then count += 1 end
    end
    return count
end
function Rules.evaluate(tier, species, catalog, now, lastClaim, coins, xp)
    local config = Rules.TIERS[tier]
    if not config or not integer(now) or not integer(lastClaim) or not integer(coins) or not integer(xp) then return nil, "invalid" end
    if now < lastClaim or now - lastClaim < config.cooldown then return nil, "cooldown" end
    if Rules.uniqueOwned(species, catalog) < config.required then return nil, "discover_more" end
    if coins > 1000000000 - config.coins or xp > 1000000000 - config.xp then return nil, "cap" end
    return { coins = coins + config.coins, xp = xp + config.xp, claimedAt = now }, nil
end
return Rules
