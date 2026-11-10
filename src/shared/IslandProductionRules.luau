-- Pure, deterministic island resource production rules. No client authority or Roblox services.
-- Caller must persist the returned snapshot under the existing server-owned profile lock.
local Production = {}
Production.MAX_OFFLINE_SECONDS = 8 * 60 * 60
Production.MAX_STORED = 500
Production.MAX_STATIONS = 12
Production.RECIPES = {
    dew_collector = { interval = 90, yield = 2, resource = "sky_dew", unlockCatches = 20 },
    wind_turbine = { interval = 120, yield = 3, resource = "wind_essence", unlockCatches = 40 },
    storm_condenser = { interval = 180, yield = 2, resource = "storm_shard", unlockCatches = 80 },
}
local function integer(n, max)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
        and n >= 0 and n == math.floor(n) and n <= max
end
function Production.validateStation(station, captures)
    if type(station) ~= "table" or not integer(captures, 1e12) then return false end
    local recipe = Production.RECIPES[station.kind]
    return recipe ~= nil and captures >= recipe.unlockCatches
        and integer(station.lastClaim, 1e12) and integer(station.stored, Production.MAX_STORED)
end
-- Never trust elapsed time or resource quantity supplied by the client.
-- Clocks moving backwards do not generate items; excess time is capped.
function Production.accrue(station, captures, now)
    if not Production.validateStation(station, captures) or not integer(now, 1e12) then
        return nil, "invalid_station"
    end
    local recipe = Production.RECIPES[station.kind]
    local elapsed = math.max(0, math.min(now - station.lastClaim, Production.MAX_OFFLINE_SECONDS))
    local cycles = math.floor(elapsed / recipe.interval)
    local gained = math.min(Production.MAX_STORED - station.stored, cycles * recipe.yield)
    return { kind = station.kind, lastClaim = now, stored = station.stored + gained }, gained
end
function Production.claim(station, captures, now, inventory)
    if type(inventory) ~= "table" then return nil, "invalid_inventory" end
    local nextStation, err = Production.accrue(station, captures, now)
    if not nextStation then return nil, err end
    local resource = Production.RECIPES[station.kind].resource
    local previous = inventory[resource] or 0
    if not integer(previous, 1e9) or previous + nextStation.stored > 1e9 then
        return nil, "inventory_full"
    end
    local nextInventory = {}
    for key, value in pairs(inventory) do nextInventory[key] = value end
    nextInventory[resource] = previous + nextStation.stored
    local awarded = nextStation.stored
    nextStation.stored = 0
    return { station = nextStation, inventory = nextInventory, resource = resource, awarded = awarded }
end
return table.freeze(Production)
