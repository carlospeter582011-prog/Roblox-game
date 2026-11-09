-- Pure profile logic: session locking, schema migration, validation and retry policy.
-- Deliberately free of Roblox globals so tests/run.luau can exercise it with the plain Luau CLI.
-- ProfileStore.luau wires this to the real DataStore, Players events and the shutdown flow.
local Core = {}

Core.SCHEMA_VERSION = 3
-- A lock not refreshed for this many seconds is treated as dead (crashed server).
-- Autosave refreshes it every 90s, so this tolerates several missed saves.
Core.LOCK_TIMEOUT = 300

local MAX_COUNTER = 1e12
local MAX_SPECIES_COUNT = 100000
local MAX_ID_LENGTH = 48

function Core.defaultData(now)
    return {
        version = Core.SCHEMA_VERSION,
        coins = 0,
        xp = 0,
        captures = 0,
        species = {},
        quests = {},
        ownedTools = { starter_net = true },
        crystals = {},
        lastSeen = now or 0,
    }
end

local function isCount(value, limit)
    -- value == value rejects NaN; the upper bound rejects inf.
    return type(value) == "number" and value == value and value >= 0 and value < limit
end

-- Copies only well-formed fields out of untrusted/stored data. validQuests is a set of quest ids.
function Core.sanitize(raw, validQuests, now)
    local clean = Core.defaultData(now)
    if type(raw) ~= "table" then
        return clean
    end
    for _, key in ipairs({ "coins", "xp", "captures" }) do
        if isCount(raw[key], MAX_COUNTER) then
            clean[key] = math.floor(raw[key])
        end
    end
    if type(raw.species) == "table" then
        for id, count in pairs(raw.species) do
            if type(id) == "string" and #id <= MAX_ID_LENGTH and isCount(count, MAX_SPECIES_COUNT + 1) then
                clean.species[id] = math.floor(count)
            end
        end
    end
    if type(raw.quests) == "table" then
        for id, done in pairs(raw.quests) do
            if type(id) == "string" and validQuests[id] and done == true then
                clean.quests[id] = true
            end
        end
    end
    if type(raw.ownedTools) == "table" then
        for id, owned in pairs(raw.ownedTools) do
            if type(id) == "string" and #id <= MAX_ID_LENGTH and string.match(id, "^[%w_]+$") and owned == true then
                clean.ownedTools[id] = true
            end
        end
    end
    if type(raw.crystals) == "table" then
        for index, found in pairs(raw.crystals) do
            if type(index) == "number" and index == math.floor(index) and index >= 1 and index <= 18 and found == true then
                clean.crystals[index] = true
            end
        end
    end
    if isCount(raw.lastSeen, MAX_COUNTER) then
        clean.lastSeen = math.floor(raw.lastSeen)
    end
    return clean
end

-- v1 stored the profile flat; v2 wraps it as { version, data, lock, savedAt }.
function Core.migrate(record, validQuests, now)
    if type(record) ~= "table" then
        return Core.defaultData(now)
    end
    local payload = record
    if type(record.data) == "table" then
        payload = record.data
    end
    return Core.sanitize(payload, validQuests, now)
end

-- Retries fn() while its failure reason is in retryable (a set). fn returns { ok = bool, reason = string? }.
-- wait(seconds) is injected so tests do not sleep. Backoff is linear: delay, 2*delay, ...
function Core.retry(fn, attempts, baseDelay, wait, retryable)
    local result
    for attempt = 1, attempts do
        result = fn()
        if result.ok or not retryable[result.reason] then
            return result, attempt
        end
        if attempt < attempts then
            wait(baseDelay * attempt)
        end
    end
    return result, attempts
end

local Repo = {}
Repo.__index = Repo

-- store needs only :UpdateAsync(key, transform) with DataStore semantics
-- (transform returning nil cancels the write). options: jobId, validQuests, now (default os.time).
function Core.new(store, options)
    return setmetatable({
        store = store,
        jobId = options.jobId,
        validQuests = options.validQuests or {},
        now = options.now or os.time,
    }, Repo)
end

-- Claims the session lock and returns the player's data.
-- Failure reasons: "locked" (live lock held by another server), "newer_schema" (written by a
-- newer build; refusing so we never downgrade it), "error" (DataStore call failed).
function Repo:Load(key)
    local outcome = nil
    local loaded = nil
    local ok, err = pcall(function()
        self.store:UpdateAsync(key, function(record)
            -- UpdateAsync may run this more than once; reset per attempt.
            outcome = nil
            loaded = nil
            local now = self.now()
            if type(record) == "table" then
                if type(record.version) == "number" and record.version > Core.SCHEMA_VERSION then
                    outcome = "newer_schema"
                    return nil
                end
                local lock = record.lock
                if type(lock) == "table" and type(lock.at) == "number"
                    and lock.jobId ~= self.jobId and now - lock.at < Core.LOCK_TIMEOUT then
                    outcome = "locked"
                    return nil
                end
            end
            local data = Core.migrate(record, self.validQuests, now)
            loaded = data
            return {
                version = Core.SCHEMA_VERSION,
                data = data,
                lock = { jobId = self.jobId, at = now },
                savedAt = now,
            }
        end)
    end)
    if not ok then
        return { ok = false, reason = "error", detail = tostring(err) }
    end
    if outcome then
        return { ok = false, reason = outcome }
    end
    if not loaded then
        return { ok = false, reason = "error", detail = "no data produced" }
    end
    return { ok = true, data = loaded }
end

-- Writes data only while this server still owns the lock. release = true clears the lock.
-- Failure reasons: "lost_lock" (another server took over; never overwrite its data), "error".
function Repo:Save(key, data, release)
    local outcome = nil
    local ok, err = pcall(function()
        self.store:UpdateAsync(key, function(record)
            outcome = nil
            local now = self.now()
            local lock = type(record) == "table" and record.lock or nil
            if type(lock) ~= "table" or lock.jobId ~= self.jobId then
                outcome = "lost_lock"
                return nil
            end
            local snapshot = Core.sanitize(data, self.validQuests, now)
            snapshot.lastSeen = now
            return {
                version = Core.SCHEMA_VERSION,
                data = snapshot,
                lock = (not release) and { jobId = self.jobId, at = now } or nil,
                savedAt = now,
            }
        end)
    end)
    if not ok then
        return { ok = false, reason = "error", detail = tostring(err) }
    end
    if outcome then
        return { ok = false, reason = outcome }
    end
    return { ok = true }
end

return Core
