-- Original native-3D cooperative-area solo shrine: memorize the order, activate three stones.
-- No client remote can grant rewards; the server owns prompts, clock, distance and profile.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("WeatherShrineRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local sessions = {}
local cooldown = {}
local shrine = Instance.new("Model")
shrine.Name = "SkyWeatherShrine3D"
shrine.Parent = Workspace
local function stone(name, pos, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = Vector3.new(6, 5, 6)
    p.Position = pos
    p.Anchored = true
    p.Material = Enum.Material.Slate
    p.Color = color
    p.Parent = shrine
    return p
end
local guide = stone("WeatherShrineGuide", Vector3.new(-35, 3.5, 45), Color3.fromRGB(95, 135, 170))
local stones = {
    stone("SunStone", Vector3.new(-47, 3.5, 58), Color3.fromRGB(230, 176, 84)),
    stone("RainStone", Vector3.new(-35, 3.5, 61), Color3.fromRGB(82, 148, 225)),
    stone("WindStone", Vector3.new(-23, 3.5, 58), Color3.fromRGB(116, 204, 165)),
}
local names = {"Sun", "Rain", "Wind"}
local function notify(player, message)
    player:SetAttribute("WeatherShrineNotice", message)
end
local function valid(player, target)
    if not player or not player.Parent or player:GetAttribute("ProfileReady") ~= true then return false end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return root ~= nil and humanoid ~= nil and humanoid.Health > 0
        and (root.Position - target.Position).Magnitude <= 18
end
local function prompt(part, action)
    local p = Instance.new("ProximityPrompt")
    p.ActionText = action
    p.ObjectText = "Sky Weather Shrine"
    p.HoldDuration = 0.3
    p.MaxActivationDistance = 13
    p.RequiresLineOfSight = false
    p.Parent = part
    return p
end
prompt(guide, "Read weather order"):Triggered:Connect(function(player)
    if not valid(player, guide) then return end
    local now = os.clock()
    if not Rules.canStart(now, cooldown[player]) then
        notify(player, "Shrine recharging. Try again later.")
        return
    end
    local seq = Rules.sequence(math.random(0, 999999))
    sessions[player] = {sequence = seq, stage = 1, started = now}
    notify(player, "Activate in order: " .. names[seq[1]] .. " > " .. names[seq[2]] .. " > " .. names[seq[3]] .. " (45s)")
end)
for index, part in ipairs(stones) do
    prompt(part, "Activate " .. names[index]):Triggered:Connect(function(player)
        if not valid(player, part) then return end
        local session = sessions[player]
        if not session then notify(player, "Read the guide stone first.") return end
        local ok, result = Rules.advance(session.sequence, session.stage, index, session.started, os.clock())
        if not ok then
            sessions[player] = nil
            notify(player, result == "wrong" and "Wrong rune! Read the guide to retry." or "Time expired! Read the guide again.")
            return
        end
        if result == "complete" then
            sessions[player] = nil
            -- Set cooldown before the grant to prevent overlapping callbacks from awarding twice.
            cooldown[player] = os.clock()
            if Profile.AwardWeatherShrine(player, Rules.REWARD_COINS, Rules.REWARD_XP) then
                notify(player, "Shrine restored! +" .. Rules.REWARD_COINS .. " Coins, +" .. Rules.REWARD_XP .. " XP")
            else
                notify(player, "Profile unavailable; no reward awarded.")
            end
        else
            session.stage = result
            notify(player, "Weather rune " .. tostring(result - 1) .. "/3 activated!")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    sessions[player] = nil
    cooldown[player] = nil
end)
