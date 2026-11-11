-- Pure deterministic fusion recipes. Preserve at least one source cloud so the
-- currently equipped companion can never be consumed. No client-supplied rewards.
local Fusion = {}
Fusion.Recipes = {
    { source = "breeze", result = "cirrus", copies = 3, cost = 75 },
    { source = "drizzle", result = "mistveil", copies = 3, cost = 90 },
    { source = "spring", result = "blossom", copies = 3, cost = 110 },
    { source = "dusk", result = "twilight", copies = 3, cost = 200 },
    { source = "thunder", result = "stormfront", copies = 3, cost = 240 },
    { source = "ember", result = "solar", copies = 3, cost = 260 },
}
local function validCount(n)
    return type(n) == "number" and n == n and n ~= math.huge and n >= 0 and n == math.floor(n)
end
function Fusion.available(profile, catalog)
    if type(profile) ~= "table" or type(profile.species) ~= "table"
        or not validCount(profile.coins) then return nil end
    for _, recipe in ipairs(Fusion.Recipes) do
        local owned = profile.species[recipe.source] or 0
        if catalog[recipe.source] and catalog[recipe.result] and validCount(owned)
            and owned >= recipe.copies + 1 and profile.coins >= recipe.cost then
            return recipe
        end
    end
    return nil
end
function Fusion.apply(profile, catalog)
    local recipe = Fusion.available(profile, catalog)
    if not recipe then return false, "Need 4 matching clouds and enough Coins" end
    -- Synchronous mutation, no yielding; both fields share the existing profile save lock.
    profile.species[recipe.source] -= recipe.copies
    profile.species[recipe.result] = (profile.species[recipe.result] or 0) + 1
    profile.coins -= recipe.cost
    return true, recipe
end
return Fusion
