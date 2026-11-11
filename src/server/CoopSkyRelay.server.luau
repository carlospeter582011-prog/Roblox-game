-- Original 3D co-op activity: two distinct players activate separate sky beacons.
-- No client RemoteEvent controls payouts; all checks run on the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("CoopRelayRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))

local root = Instance.new("Model")
root.Name = "CooperativeSkyRelay3D"
root.Parent = Workspace
local stations = {}
local active = {}
local lastReward = {}
local busy = false

for i, position in ipairs({Vector3.new(-48, 1.5, 35), Vector3.new(-23, 1.5, 35)}) do
    local base = Instance.new("Part")
    base.Name = "RelayBeacon" .. i
    base.Size = Vector3.new(7, 3, 7)
    base.Shape = Enum.PartType.Cylinder
    base.Anchored = true
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(93, 116, 168)
    base.Position = position
    base.Parent = root
    local gem = Instance.new("Part")
    gem.Name = "RelayCrystal" .. i
    gem.Size = Vector3.new(3, 5, 3)
    gem.Shape = Enum.PartType.Ball
    gem.Anchored = true
    gem.CanCollide = false
    gem.Material = Enum.Material.Neon
    gem.Color = i == 1 and Color3.fromRGB(95, 219, 223) or Color3.fromRGB(227, 171, 105)
    gem.Position = position + Vector3.new(0, 4, 0)
    gem.Parent = root
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Synchronize"
    prompt.ObjectText = "Sky Relay " .. i .. " (2 players)"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    stations[i] = {base = base, prompt = prompt}
end

local function validPlayer(player, i)
    if not player or player.Parent ~= Players then return false end
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local distance = rootPart and (rootPart.Position - stations[i].base.Position).Magnitude or math.huge
    return Rules.canActivate(distance, player:GetAttribute("ProfileReady"), humanoid ~= nil and humanoid.Health > 0)
        and Profile.Get(player) ~= nil
end

local function award(player)
    local data = Profile.Get(player)
    if not data then return false end
    data.coins = math.min(1000000000, data.coins + Rules.COINS)
    data.xp = math.min(1000000000, data.xp + Rules.XP)
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    player:SetAttribute("CoopRelayFeedback", "Sky Relay complete! +" .. Rules.COINS .. " Coins, +" .. Rules.XP .. " XP")
    return true
end

local function activate(player, station)
    if busy or not validPlayer(player, station) then return end
    local now = os.clock()
    local userId = player.UserId
    if lastReward[userId] and now - lastReward[userId] < Rules.COOLDOWN then return end
    active[station] = {userId = userId, at = now, player = player, station = station}
    local a, b = active[1], active[2]
    if not a or not b or not Rules.canPair(a, b, now, lastReward) then return end
    busy = true
    -- Revalidate both participants at their respective physical stations.
    if validPlayer(a.player, 1) and validPlayer(b.player, 2) then
        lastReward[a.userId], lastReward[b.userId] = now, now
        award(a.player)
        award(b.player)
        active[1], active[2] = nil, nil
    end
    busy = false
end

for i, station in ipairs(stations) do
    station.prompt.Triggered:Connect(function(player) activate(player, i) end)
end
Players.PlayerRemoving:Connect(function(player)
    lastReward[player.UserId] = nil
    for i = 1, 2 do
        if active[i] and active[i].userId == player.UserId then active[i] = nil end
    end
end)
