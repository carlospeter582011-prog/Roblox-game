-- Pure evolution rules. Free of Roblox globals for unit testing.
-- Evolving consumes duplicates of the base species, spends coins, and unlocks the evolved form.
-- The player keeps at least one base cloud. Evolved form is added as a catalog species count.
local Rules = {}

-- Stable paths using existing catalog species. Expand without changing ids.
Rules.paths = {
    breeze = { into = "gale", duplicates = 5, coins = 200 },
    drizzle = { into = "monsoon", duplicates = 4, coins = 250 },
    pebble = { into = "geode", duplicates = 6, coins = 300 },
    mist = { into = "mistveil", duplicates = 5, coins = 220 },
    spring = { into = "blossom", duplicates = 4, coins = 180 },
    frost = { into = "frostbite", duplicates = 4, coins = 280 },
    ember = { into = "emberheart", duplicates = 3, coins = 350 },
    thunder = { into = "voltage", duplicates = 3, coins = 400 },
}

function Rules.requirement(speciesId)
    return Rules.paths[speciesId]
end

-- Returns true, path or false, reason. Does not mutate.
function Rules.canEvolve(speciesId, speciesCounts, coins, catalog)
    if type(speciesId) ~= "string" or type(speciesCounts) ~= "table" or type(coins) ~= "number" then
        return false, "invalid input"
    end
    local path = Rules.paths[speciesId]
    if not path or type(catalog) ~= "table" or not catalog[path.into] then
        return false, "no evolution path"
    end
    local have = speciesCounts[speciesId]
    if type(have) ~= "number" or have < path.duplicates + 1 then
        return false, "need more duplicates"
    end
    if coins < path.coins then
        return false, "need coins"
    end
    return true, path
end

-- Mutates data.species and data.coins on success. Caller must own a loaded profile.
function Rules.apply(speciesId, data, catalog)
    if type(data) ~= "table" or type(data.species) ~= "table" or type(data.coins) ~= "number" then
        return false, "invalid profile"
    end
    local ok, pathOrReason = Rules.canEvolve(speciesId, data.species, data.coins, catalog)
    if not ok then
        return false, pathOrReason
    end
    local path = pathOrReason
    data.species[speciesId] = data.species[speciesId] - path.duplicates
    data.species[path.into] = (data.species[path.into] or 0) + 1
    data.coins = data.coins - path.coins
    return true, path.into
end

return Rules
