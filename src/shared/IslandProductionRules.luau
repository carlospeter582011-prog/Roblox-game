-- Pure, deterministic island habitat production rules. No Roblox services or client trust.
-- A production job is only a proposal until a server-owned profile transaction commits it.
local Rules = {}
Rules.MAX_OFFLINE_SECONDS = 8 * 60 * 60
Rules.MAX_JOBS = 12
Rules.RECIPES = table.freeze({
    breeze_nest = table.freeze({ interval = 120, yield = 3, maxStored = 240, costCoins = 100, element = "Air" }),
    rain_garden = table.freeze({ interval = 180, yield = 5, maxStored = 300, costCoins = 200, element = "Water" }),
    storm_turbine = table.freeze({ interval = 300, yield = 12, maxStored = 480, costCoins = 500, element = "Storm" }),
    blossom_orchard = table.freeze({ interval = 240, yield = 7, maxStored = 350, costCoins = 300, element = "Nature" }),
})
local function whole(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
        and n >= 0 and n == math.floor(n)
end
function Rules.canBuild(recipeId, coins, count, ownedSpecies, catalog)
    local recipe = type(recipeId) == "string" and Rules.RECIPES[recipeId]
    if not recipe then return false, "unknown_recipe" end
    if not whole(coins) or not whole(count) or count >= Rules.MAX_JOBS then
        return false, "invalid_capacity"
    end
    if coins < recipe.costCoins then return false, "insufficient_coins" end
    local hasElement = false
    if type(ownedSpecies) == "table" and type(catalog) == "table" then
        for id, amount in pairs(ownedSpecies) do
            if whole(amount) and amount > 0 and catalog[id] and catalog[id].element == recipe.element then
                hasElement = true
                break
            end
        end
    end
    if not hasElement then return false, "missing_element" end
    return true
end
-- Computes total generated coins, never mutates caller data.
-- Carry seconds remain to avoid losing fractional production intervals on frequent claims.
function Rules.harvest(recipeId, elapsedSeconds, storedCoins, carrySeconds)
    local recipe = type(recipeId) == "string" and Rules.RECIPES[recipeId]
    if not recipe or not whole(elapsedSeconds) or not whole(storedCoins)
        or not whole(carrySeconds) or carrySeconds >= recipe.interval then
        return nil, "invalid_state"
    end
    local bounded = math.min(elapsedSeconds, Rules.MAX_OFFLINE_SECONDS)
    local ticks = math.floor((bounded + carrySeconds) / recipe.interval)
    local available = math.max(0, recipe.maxStored - math.min(storedCoins, recipe.maxStored))
    local generated = math.min(available, ticks * recipe.yield)
    return {
        generated = generated,
        stored = math.min(recipe.maxStored, storedCoins + generated),
        carry = (bounded + carrySeconds) % recipe.interval,
        cappedOffline = elapsedSeconds > Rules.MAX_OFFLINE_SECONDS,
    }
end

-- Atomic, pure claim proposal. The caller must commit the returned new job and
-- wallet together in its server-owned profile transaction, never separately.
-- A repeated claim with the same timestamp generates nothing.
function Rules.claim(recipeId, job, now, wallet)
    if type(job) ~= "table" or not whole(now) or not whole(wallet)
        or not whole(job.lastAccrued) or now < job.lastAccrued then
        return nil, "invalid_state"
    end
    local result, reason = Rules.harvest(recipeId, now - job.lastAccrued,
        job.stored or 0, job.carry or 0)
    if not result then return nil, reason end
    -- Refuse unsafe integers rather than silently overflow or lose money.
    if wallet > 9007199254740991 - result.stored then
        return nil, "wallet_overflow"
    end
    return {
        coins = wallet + result.stored,
        credited = result.stored,
        job = {
            lastAccrued = now,
            stored = 0,
            carry = result.carry,
        },
        cappedOffline = result.cappedOffline,
    }
end
-- Propose purchasing a habitat and initializing its production clock in one immutable
-- transaction. Call only on the server using authoritative profile state.
-- The caller must persist both the new wallet and appended job together.
function Rules.build(recipeId, wallet, jobs, ownedSpecies, catalog, now)
    if type(jobs) ~= "table" or not whole(now) or now > 9007199254740991 then
        return nil, "invalid_state"
    end
    local count = 0
    for key, job in pairs(jobs) do
        if type(key) ~= "number" or key ~= math.floor(key) or key < 1
            or key > Rules.MAX_JOBS or type(job) ~= "table" then
            return nil, "invalid_jobs"
        end
        count += 1
    end
    local allowed, reason = Rules.canBuild(recipeId, wallet, count, ownedSpecies, catalog)
    if not allowed then return nil, reason end
    local recipe = Rules.RECIPES[recipeId]
    local updated = {}
    for i, job in ipairs(jobs) do
        if type(job.recipeId) ~= "string" or not Rules.RECIPES[job.recipeId]
            or not whole(job.lastAccrued) or not whole(job.stored or 0)
            or not whole(job.carry or 0) then
            return nil, "invalid_jobs"
        end
        updated[i] = table.clone(job)
    end
    if #updated ~= count then return nil, "invalid_jobs" end
    table.insert(updated, {
        recipeId = recipeId, lastAccrued = now, stored = 0, carry = 0,
    })
    return { coins = wallet - recipe.costCoins, jobs = updated, spent = recipe.costCoins }
end


-- Settle all habitats as one immutable wallet/jobs proposal. No partial credits on error.
-- The profile owner must commit the entire result in one server-authoritative mutation.
function Rules.claimAll(jobs, now, wallet)
    if type(jobs) ~= "table" or not whole(now) or now > 9007199254740991
        or not whole(wallet) or wallet > 9007199254740991 then
        return nil, "invalid_state"
    end
    local count = 0
    for key in pairs(jobs) do
        if type(key) ~= "number" or key < 1 or key ~= math.floor(key)
            or key > Rules.MAX_JOBS then return nil, "invalid_jobs" end
        count += 1
    end
    if count ~= #jobs then return nil, "invalid_jobs" end
    local nextJobs = {}
    local total = 0
    for i, job in ipairs(jobs) do
        if type(job) ~= "table" or type(job.recipeId) ~= "string"
            or not Rules.RECIPES[job.recipeId] then return nil, "invalid_jobs" end
        local result, reason = Rules.claim(job.recipeId, job, now, wallet + total)
        if not result then return nil, reason end
        total += result.credited
        nextJobs[i] = { recipeId = job.recipeId, lastAccrued = result.job.lastAccrued,
            stored = result.job.stored, carry = result.job.carry }
    end
    return { coins = wallet + total, credited = total, jobs = nextJobs }
end

return table.freeze(Rules)
