-- Sky Observatory: a replayable 3D compass puzzle, server-authoritative.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyNavigationRules"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local origin = Vector3.new(-36, 10, -35)
local model = Instance.new("Model")
model.Name = "SkyObservatory3D"
model.Parent = workspace
local sessions = {}
local function part(name, position, size, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = model
    return p
end
part("ObservatoryBase", origin, Vector3.new(19, 1, 19), Color3.fromRGB(64, 83, 124))
local center = part("CompassStart", origin + Vector3.new(0, 2, 0), Vector3.new(4, 3, 4), Color3.fromRGB(122, 210, 240))
local start = Instance.new("ProximityPrompt")
start.ActionText = "Start navigation"
start.ObjectText = "Sky Observatory"
start.MaxActivationDistance = 9
start.Parent = center
local directions = {
    north = Vector3.new(0, 2, -7),
    east = Vector3.new(7, 2, 0),
    south = Vector3.new(0, 2, 7),
    west = Vector3.new(-7, 2, 0),
}
local function closeEnough(player, target)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return root and humanoid and humanoid.Health > 0 and (root.Position - target.Position).Magnitude <= 12
end
start.Triggered:Connect(function(player)
    if not Profile.Get(player) or not closeEnough(player, center) then return end
    local now = os.clock()
    local state = sessions[player]
    if state and now < (state.cooldownUntil or 0) then return end
    sessions[player] = { progress = 0, started = now, cooldownUntil = 0 }
    player:SetAttribute("ObservatoryProgress", 0)
end)
for direction, offset in pairs(directions) do
    local marker = part("Compass_" .. direction, origin + offset, Vector3.new(3, 3, 3), Color3.fromRGB(117, 171, 225))
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Align " .. direction
    prompt.ObjectText = "Sky Compass"
    prompt.MaxActivationDistance = 9
    prompt.Parent = marker
    prompt.Triggered:Connect(function(player)
        local data = Profile.Get(player)
        local state = sessions[player]
        if not data or not state or not closeEnough(player, marker) then return end
        local now = os.clock()
        if now < state.cooldownUntil then return end
        local progress, complete, reason = Rules.step(state.progress, direction, now - state.started)
        if reason == "expired_or_invalid" then
            sessions[player] = nil
            player:SetAttribute("ObservatoryProgress", 0)
            return
        end
        state.progress = progress
        player:SetAttribute("ObservatoryProgress", progress)
        if complete then
            -- Reentrancy guard before touching currency.
            state.cooldownUntil = now + Rules.COOLDOWN
            state.progress = 0
            if data.coins <= 1e12 - Rules.REWARD_COINS and data.xp <= 1e12 - Rules.REWARD_XP then
                data.coins += Rules.REWARD_COINS
                data.xp += Rules.REWARD_XP
                player:SetAttribute("CloudCoins", data.coins)
                player:SetAttribute("CloudXP", data.xp)
                player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
                player:SetAttribute("ObservatoryProgress", 4)
            end
        end
    end)
end
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
