-- Session-only parties. No client can choose party membership or grant rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("PartyRules"))
local state = Rules.new()
local remote = Instance.new("RemoteEvent")
remote.Name = "PartyAction"
remote.Parent = ReplicatedStorage
local lastAction = {}
local function notify(userId, kind, payload)
    local player = Players:GetPlayerByUserId(userId)
    if player then remote:FireClient(player, kind, payload) end
end
local function sync(ids)
    for _, id in ipairs(ids) do
        local members, leader = Rules.members(state, id)
        notify(id, "state", { members = members, leader = leader })
    end
end
remote.OnServerEvent:Connect(function(player, action, targetId)
    if typeof(action) ~= "string" or #action > 12 then return end
    local now = os.clock()
    if now - (lastAction[player.UserId] or -100) < 1 then return end
    lastAction[player.UserId] = now
    local before = Rules.members(state, player.UserId)
    if action == "invite" then
        if typeof(targetId) ~= "number" or not Players:GetPlayerByUserId(targetId) then return end
        local ok, reason = Rules.invite(state, player.UserId, targetId, now)
        notify(player.UserId, "result", reason)
        if ok then notify(targetId, "invite", { from = player.UserId, expires = 60 }) end
    elseif action == "accept" then
        if typeof(targetId) ~= "number" or not Players:GetPlayerByUserId(targetId) then return end
        local ok, reason = Rules.accept(state, player.UserId, targetId, now)
        notify(player.UserId, "result", reason)
        if ok then sync(Rules.members(state, player.UserId)) end
    elseif action == "leave" then
        Rules.leave(state, player.UserId)
        sync(before)
        sync({player.UserId})
    elseif action == "status" then
        sync({player.UserId})
    end
end)
Players.PlayerRemoving:Connect(function(player)
    local previous = Rules.members(state, player.UserId)
    Rules.leave(state, player.UserId)
    lastAction[player.UserId] = nil
    for target, invite in pairs(state.invites) do
        if invite.from == player.UserId then state.invites[target] = nil end
    end
    sync(previous)
end)
