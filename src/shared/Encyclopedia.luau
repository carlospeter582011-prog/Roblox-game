-- Pure encyclopedia helpers. No Roblox globals.
local Encyclopedia = {}

function Encyclopedia.uniqueCount(speciesMap)
    local n = 0
    for _, count in pairs(speciesMap or {}) do
        if type(count) == "number" and count > 0 then
            n += 1
        end
    end
    return n
end

function Encyclopedia.completionPercent(speciesMap, catalog)
    local total = 0
    for _ in pairs(catalog or {}) do
        total += 1
    end
    if total == 0 then return 0 end
    return math.floor(Encyclopedia.uniqueCount(speciesMap) * 100 / total)
end

return Encyclopedia
