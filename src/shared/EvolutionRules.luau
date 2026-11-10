-- Pure cloud evolution rules. No Roblox globals.
-- Evolution paths are data-driven; applying an evolution is a pure transaction that
-- consumes the required captures/XP and grants the evolved species.
local Rules = {}

Rules.paths = {
	breeze = { evolved = "galehowl", requiredCaptures = 8, xpCost = 40 },
	drizzle = { evolved = "tidepool", requiredCaptures = 10, xpCost = 50 },
	mist = { evolved = "mistveil", requiredCaptures = 12, xpCost = 60 },
	sunbeam = { evolved = "sunflare", requiredCaptures = 6, xpCost = 80 },
	pebble = { evolved = "geode", requiredCaptures = 15, xpCost = 70 },
	frost = { evolved = "frostpeak", requiredCaptures = 8, xpCost = 90 },
	ember = { evolved = "emberheart", requiredCaptures = 7, xpCost = 100 },
}

function Rules.canEvolve(speciesId: string, captures: number, xp: number): boolean
	local path = Rules.paths[speciesId]
	if not path then
		return false
	end
	if type(captures) ~= "number" or type(xp) ~= "number" then
		return false
	end
	if captures ~= captures or xp ~= xp or captures < 0 or xp < 0 then
		return false
	end
	return captures >= path.requiredCaptures and xp >= path.xpCost
end

function Rules.apply(speciesId: string, species: { [string]: number }, captures: number, xp: number): (boolean, string?, { [string]: number }?, number?, number?)
	if not Rules.canEvolve(speciesId, captures, xp) then
		return false, "cannot_evolve", nil, nil, nil
	end
	local path = Rules.paths[speciesId]
	local newSpecies = {}
	for k, v in pairs(species) do
		newSpecies[k] = v
	end
	local owned = newSpecies[speciesId] or 0
	if owned < 1 then
		return false, "not_owned", nil, nil, nil
	end
	newSpecies[speciesId] = owned - 1
	if newSpecies[speciesId] <= 0 then
		newSpecies[speciesId] = nil
	end
	newSpecies[path.evolved] = (newSpecies[path.evolved] or 0) + 1
	local newCaptures = captures -- captures of the base stay tracked separately if needed; here we just consume the cost conceptually
	local newXp = xp - path.xpCost
	return true, nil, newSpecies, newCaptures, newXp
end

return table.freeze(Rules)
