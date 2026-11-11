-- Pure evolution rules for Catch a Cloud. No Roblox globals.
-- Evolution is one-time unlock of a higher species when the base species count reaches a threshold.
-- Paths are data-driven; expand without changing existing IDs.

local Rules = {}

-- baseId -> { evolvedId = string, requiredCount = number }
Rules.PATHS = {
    breeze = { evolvedId = "gale", requiredCount = 25 },
    drizzle = { evolvedId = "monsoon", requiredCount = 30 },
    mist = { evolvedId = "mistveil", requiredCount = 20 },
    sunbeam = { evolvedId = "solar", requiredCount = 15 },
    spring = { evolvedId = "mossbloom", requiredCount = 22 },
    frost = { evolvedId = "glacier", requiredCount = 18 },
    ember = { evolvedId = "emberglow", requiredCount = 12 },
    thunder = { evolvedId = "voltage", requiredCount = 10 },
    pebble = { evolvedId = "crystal", requiredCount = 35 },
    hush = { evolvedId = "zephyr", requiredCount = 28 },
}

function Rules.canEvolve(speciesId: string, count: number): (boolean, string?)
    local path = Rules.PATHS[speciesId]
    if not path or type(count) ~= "number" or count < path.requiredCount then
        return false, nil
    end
    return true, path.evolvedId
end

function Rules.evolvedIdFor(speciesId: string): string?
    local path = Rules.PATHS[speciesId]
    return path and path.evolvedId or nil
end

function Rules.requiredFor(speciesId: string): number?
    local path = Rules.PATHS[speciesId]
    return path and path.requiredCount or nil
end

return table.freeze(Rules)
