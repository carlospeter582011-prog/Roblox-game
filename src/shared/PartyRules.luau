-- Pure, server-authoritative party state. IDs are numeric Roblox UserIds.
local Rules = {}
Rules.MAX_MEMBERS = 4
Rules.INVITE_TTL = 60
local function valid(id) return type(id) == "number" and id > 0 and id == math.floor(id) and id < math.huge end
function Rules.new() return { parties = {}, membership = {}, invites = {}, nextId = 0 } end
function Rules.invite(state, from, target, now)
    if not valid(from) or not valid(target) or from == target or type(now) ~= "number" or now ~= now then return false, "invalid" end
    local partyId = state.membership[from]
    if state.membership[target] then return false, "already_in_party" end
    if partyId then
        local party = state.parties[partyId]
        if not party or party.leader ~= from then return false, "leader_only" end
        if #party.members >= Rules.MAX_MEMBERS then return false, "full" end
    end
    state.invites[target] = { from = from, partyId = partyId, expires = now + Rules.INVITE_TTL }
    return true, "invited"
end
function Rules.accept(state, target, from, now)
    if not valid(target) or not valid(from) or type(now) ~= "number" then return false, "invalid" end
    local invite = state.invites[target]
    if not invite or invite.from ~= from then return false, "expired" end
    if now > invite.expires then state.invites[target] = nil return false, "expired" end
    state.invites[target] = nil
    if state.membership[target] then return false, "already_in_party" end
    local id = invite.partyId
    local party
    if id then
        party = state.parties[id]
        if not party or party.leader ~= from or state.membership[from] ~= id then return false, "stale" end
        if #party.members >= Rules.MAX_MEMBERS then return false, "full" end
    else
        if state.membership[from] then return false, "stale" end
        state.nextId += 1
        id = state.nextId
        party = { leader = from, members = { from } }
        state.parties[id] = party
        state.membership[from] = id
    end
    table.insert(party.members, target)
    state.membership[target] = id
    return true, "joined"
end
function Rules.leave(state, userId)
    local id = state.membership[userId]
    if not id then state.invites[userId] = nil return false end
    local party = state.parties[id]
    state.membership[userId] = nil
    state.invites[userId] = nil
    if not party then return false end
    for i, member in ipairs(party.members) do
        if member == userId then table.remove(party.members, i) break end
    end
    if #party.members == 0 then state.parties[id] = nil
    elseif party.leader == userId then party.leader = party.members[1] end
    return true
end
function Rules.members(state, userId)
    local party = state.parties[state.membership[userId]]
    if not party then return { userId }, userId end
    local copy = {}
    for _, member in ipairs(party.members) do table.insert(copy, member) end
    return copy, party.leader
end
return Rules
