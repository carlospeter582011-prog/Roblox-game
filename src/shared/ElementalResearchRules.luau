-- Session-only elemental field research. A set of three DIFFERENT elements
-- grants a modest XP bonus and then resets. Never trust client-supplied elements.
local Rules = {}
Rules.BONUS_XP = 15
local function validElement(element)
    return type(element) == "string" and #element > 0 and #element <= 24
        and element:match("^[%a]+$") ~= nil
end
function Rules.advance(previous, speciesId, catalog)
    local state = {}
    if type(previous) == "table" then
        for element, found in pairs(previous) do
            if validElement(element) and found == true then state[element] = true end
        end
    end
    local entry = type(speciesId) == "string" and type(catalog) == "table" and catalog[speciesId] or nil
    local element = type(entry) == "table" and entry.element or nil
    if not validElement(element) then return state, 0, false end
    state[element] = true
    local count = 0
    for _ in pairs(state) do count += 1 end
    if count >= 3 then return {}, Rules.BONUS_XP, true end
    return state, 0, false
end
return Rules
