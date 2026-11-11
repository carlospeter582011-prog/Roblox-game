-- Pure server-side rules for exchanging surplus clouds without destroying the last copy.
local Rules = {}
local MAX_COINS = 1000000000
function Rules.choose(species, catalog)
    if type(species) ~= "table" or type(catalog) ~= "table" then return nil end
    local best, count
    for id, amount in pairs(species) do
        if type(id) == "string" and catalog[id] and type(amount) == "number"
            and amount == amount and amount < math.huge and amount >= 2 and amount == math.floor(amount) then
            if not count or amount > count or (amount == count and id < best) then
                best, count = id, amount
            end
        end
    end
    return best
end
function Rules.exchange(profile, catalog)
    if type(profile) ~= "table" or type(profile.species) ~= "table" then return false, "Profile unavailable" end
    local id = Rules.choose(profile.species, catalog)
    if not id then return false, "Catch duplicate clouds first" end
    local coins = profile.coins
    if type(coins) ~= "number" or coins ~= coins or coins < 0 or coins == math.huge then
        return false, "Invalid balance"
    end
    local reward = math.floor(math.min(100, math.max(5, (catalog[id].baseRewardCoins or 10) * 0.5)))
    if coins > MAX_COINS - reward then return false, "Coin wallet full" end
    profile.species[id] -= 1
    profile.coins += reward
    return true, id, reward
end
return Rules
