-- Pure evolution rules for collected clouds. No Roblox globals.
-- Stages are data-driven; XP is awarded by care, catching companions, or future raising interactions.
-- Compatible with existing profile species counts; individual cloud instances can be added later.

local Rules = {}

-- XP thresholds for stages 0 (base) through 4 (final). Higher stages require more XP.
Rules.STAGE_THRESHOLDS = { 0, 25, 80, 200, 500 }

function Rules.stageForXp(xp: number): number
	if type(xp) ~= "number" or xp ~= xp or xp < 0 or xp == math.huge then
		return 0
	end
	local floored = math.floor(xp)
	for i = #Rules.STAGE_THRESHOLDS, 1, -1 do
		if floored >= Rules.STAGE_THRESHOLDS[i] then
			return i - 1
		end
	end
	return 0
end

function Rules.xpToNext(xp: number): number?
	local stage = Rules.stageForXp(xp)
	if stage >= #Rules.STAGE_THRESHOLDS - 1 then
		return nil -- max stage
	end
	local nextThreshold = Rules.STAGE_THRESHOLDS[stage + 2]
	local floored = math.floor(math.max(0, xp))
	return math.max(0, nextThreshold - floored)
end

function Rules.canEvolve(xp: number): boolean
	return Rules.stageForXp(xp) < #Rules.STAGE_THRESHOLDS - 1
end

-- Bounded XP award (e.g. from feeding or companion resonance). Rejects invalid inputs.
function Rules.awardXp(current: number, amount: number, maxXp: number?): number
	if type(current) ~= "number" or current ~= current or current < 0 or current == math.huge then
		current = 0
	end
	if type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount == math.huge then
		return math.floor(current)
	end
	local cap = type(maxXp) == "number" and maxXp > 0 and maxXp == maxXp and maxXp ~= math.huge and maxXp or 10000
	local next = math.floor(current) + math.floor(amount)
	return math.min(next, cap)
end

-- Stage names for UI / encyclopedia (English; localization later).
Rules.STAGE_NAMES = { "Spark", "Whisper", "Bloom", "Tempest", "Ascendant" }

function Rules.stageName(stage: number): string
	local i = math.floor(stage or 0) + 1
	return Rules.STAGE_NAMES[i] or Rules.STAGE_NAMES[1]
end

return table.freeze(Rules)
