-- Regression tests for pure cloud evolution rules.
return function(test, eq)
	local Rules = require("../src/shared/EvolutionRules")

	test("evolution paths exist for common starters and reject invalid data", function()
		eq(Rules.canEvolve("breeze", 8, 40), true, "breeze ready")
		eq(Rules.canEvolve("breeze", 7, 40), false, "not enough captures")
		eq(Rules.canEvolve("breeze", 8, 39), false, "not enough xp")
		eq(Rules.canEvolve("unknown", 100, 100), false, "no path")
		eq(Rules.canEvolve("breeze", 0/0, 40), false, "nan captures")
		eq(Rules.canEvolve("breeze", 8, math.huge), false, "inf xp")
	end)

	test("apply consumes one owned cloud and grants evolved form", function()
		local species = { breeze = 2, drizzle = 1 }
		local ok, reason, newSpecies, _, newXp = Rules.apply("breeze", species, 10, 100)
		eq(ok, true, "applied")
		eq(reason, nil, "no reason")
		eq(newSpecies.breeze, 1, "base reduced")
		eq(newSpecies.galehowl, 1, "evolved granted")
		eq(newXp, 60, "xp deducted")
		eq(species.breeze, 2, "original unchanged")
	end)

	test("apply refuses unowned or insufficient resources", function()
		local ok, reason = Rules.apply("breeze", {}, 10, 100)
		eq(ok, false, "refused")
		eq(reason, "not_owned", "reason")
		ok, reason = Rules.apply("pebble", { pebble = 1 }, 5, 100)
		eq(ok, false, "not ready")
		eq(reason, "cannot_evolve", "reason")
	end)
end
