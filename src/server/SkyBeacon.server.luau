-- Cooperative sky beacon: server-owned, server-local event. No client remote or client-supplied rewards.
-- Players opt in at a native 3D beacon; each new catch contributes to one shared target.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyBeaconRules"))

local model = Instance.new("Model")
model.Name = "CooperativeSkyBeacon3D"
model.Parent = Workspace
local function make(name, shape, size, position, color)
    local p = Instance.new("Part")
    p.Name, p.Shape, p.Size, p.Position = name, shape, size, position
    p.Anchored, p.CanCollide = true, false
    p.Material, p.Color = Enum.Material.SmoothPlastic, color
    p.Parent = model
    return p
end
local base = make("BeaconPedestal", Enum.PartType.Cylinder, Vector3.new(2, 9, 9), Vector3.new(-28, 3, 25), Color3.fromRGB(80, 145, 185))
base.CanCollide = true
base.Orientation = Vector3.new(0, 0, 90)
local orb = make("BeaconCore", Enum.PartType.Ball, Vector3.new(4, 4, 4), Vector3.new(-28, 7, 25), Color3.fromRGB(132, 231, 240))
orb.Material = Enum.Material.Neon
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText, prompt.ObjectText = "Join Shared Catch Challenge", "Sky Beacon"
prompt.HoldDuration, prompt.MaxActivationDistance = 0.5, 12
prompt.RequiresLineOfSight = false
prompt.Parent = orb

local participants = {} -- [player] = {start, lastProgress}
local cooldown = {} -- [player] = next eligible start time
local deadline = 0
local total = 0
local active = false
local function feedback(player, message)
    if player.Parent then player:SetAttribute("SkyBeaconFeedback", message) end
end
local function reset()
    active, total, deadline = false, 0, 0
    table.clear(participants)
end
prompt.Triggered:Connect(function(player)
    local profile = Profiles.Get(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not profile or not humanoid or humanoid.Health <= 0 or not root then return end
    if (root.Position - orb.Position).Magnitude > 16 then return end
    local now = os.clock()
    if participants[player] then
        feedback(player, "Already participating! Catch clouds to charge the beacon.")
        return
    end
    if now < (cooldown[player] or 0) then
        feedback(player, "Beacon recharging. Return later.")
        return
    end
    if not active then
        active, total, deadline = true, 0, now + Rules.DURATION
    end
    participants[player] = { start = profile.captures, lastProgress = 0 }
    feedback(player, "Joined! Catch at least 2 clouds before the shared goal is reached.")
end)
task.spawn(function()
    while true do
        task.wait(0.5)
        if active then
            local now = os.clock()
            for player, entry in pairs(participants) do
                local data = Profiles.Get(player)
                if not player.Parent or not data then
                    participants[player] = nil
                else
                    local progress = Rules.progress(entry.start, data.captures)
                    local delta = math.max(0, progress - entry.lastProgress)
                    entry.lastProgress = progress
                    total = math.min(Rules.GOAL, total + delta)
                    player:SetAttribute("SkyBeaconProgress", total .. "/" .. Rules.GOAL)
                end
            end
            local state = Rules.status(total, deadline, now)
            if state ~= "active" then
                for player, entry in pairs(participants) do
                    cooldown[player] = now + Rules.REJOIN_COOLDOWN
                    if state == "complete" and Rules.eligible(entry.lastProgress) then
                        local awarded, coins, xp = Profiles.AwardSkyBeacon(player)
                        if awarded then
                            feedback(player, "Beacon charged! +" .. coins .. " Coins, +" .. xp .. " XP.")
                        else
                            feedback(player, "Beacon completed, but profile reward was unavailable.")
                        end
                    else
                        feedback(player, state == "complete" and "Help catch 2 clouds next time to earn a reward." or "Beacon faded. Try again.")
                    end
                    player:SetAttribute("SkyBeaconProgress", "")
                end
                reset()
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    participants[player] = nil
    cooldown[player] = nil
end)
