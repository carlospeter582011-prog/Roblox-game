-- Pure fusion rules for duplicate cloud species. Server owns consumption and rewards.
-- Consumes two of the same base species for bonus XP and a small coin refund. Protects last specimen.
local Rules = {}

function Rules.canFuse(speciesId: string, counts: {[string]: number}): boolean
    if type(speciesId) ~= "string" or speciesId == "" then
        return false
    end
    local count = counts[speciesId]
    return type(count) == "number" and count >= 2 and count == math.floor(count) and count < 1e9
end

function Rules.fuse(speciesId: string, counts: {[string]: number}, baseXp: number): {ok: boolean, reason: string?, newCount: number?, xpBonus: number?, coinRefund: number?}
    if not Rules.canFuse(speciesId, counts) then
        return { ok = false, reason = "insufficient" }
    end
    local newCount = counts[speciesId] - 2
    local xpBonus = math.max(0, math.floor(baseXp * 0.5))
    local coinRefund = 5
    return {
        ok = true,
        newCount = newCount,
        xpBonus = xpBonus,
        coinRefund = coinRefund,
    }
end

return Rules
