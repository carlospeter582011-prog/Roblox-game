-- Pure discovery gallery rules. Never trust client-provided collection counts.
local Gallery = {}
Gallery.tiers = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
function Gallery.summary(catalog, owned, rarity)
    local total, discovered = 0, 0
    local nextMissing = nil
    for id, species in pairs(catalog) do
        if species.rarity == rarity then
            total += 1
            if type(owned[id]) == "number" and owned[id] > 0 then
                discovered += 1
            elseif not nextMissing or id < nextMissing then
                nextMissing = id
            end
        end
    end
    return discovered, total, nextMissing
end
function Gallery.completed(catalog, owned, rarity)
    local found, total = Gallery.summary(catalog, owned, rarity)
    return total > 0 and found == total
end
return table.freeze(Gallery)
