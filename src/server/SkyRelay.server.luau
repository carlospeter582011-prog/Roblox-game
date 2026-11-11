-- Three physical beacon challenge: touch-friendly, server-authoritative, repeatable exploration.
-- No client remote or user-controlled progress/timer/rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyRelayRules"))
local stations = {
    { id = "meadow", pos = Vector3.new(-35, 2, 45), color = Color3.fromRGB(125, 218, 160) },
    { id = "outlook", pos = Vector3.new(175, 2, 28), color = Color3.fromRGB(115, 185, 240) },
    { id = "ridge", pos = Vector3.new(325, 2, 25), color = Color3.fromRGB(209, 145, 244) },
}
local state = {} -- per-server challenge progress; replay rewards are capped by cooldown
local rootFolder = Instance.new("Folder")
rootFolder.Name = "SkyRelay3D"
rootFolder.Parent = Workspace

local function interact(player, station)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local data = Profile.Get(player)
    if not data or player:GetAttribute("ProfileReady") ~= true then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local distance = (root.Position - station.pos).Magnitude
    local now = os.clock()
    local s = state[player]
    if not s then
        s = { stage = 0, start = now, lastFinish = nil }
        state[player] = s
    end
    if s.stage == 0 then
        if station.id ~= Rules.ORDER[1] or not Rules.canStart(now, s.lastFinish) then return end
        s.start = now
    end
    local nextStage = Rules.advance(s.stage, station.id, now - s.start, distance)
    if not nextStage then
        if s.stage > 0 and now - s.start > Rules.TIME_LIMIT then
            s.stage = 0
            player:SetAttribute("SkyRelayProgress", 0)
        end
        return
    end
    s.stage = nextStage
    player:SetAttribute("SkyRelayProgress", nextStage)
    if nextStage == #Rules.ORDER then
        local ok = Profile.AwardSkyRelay(player, Rules.REWARD_COINS, Rules.REWARD_XP)
        if ok then
            s.lastFinish = now
            player:SetAttribute("SkyRelayFeedback", "Sky Relay complete! +90 Coins +45 XP (one-time)")
        else
            player:SetAttribute("SkyRelayFeedback", "Sky Relay complete! Practice run finished.")
        end
        s.stage = 0
        player:SetAttribute("SkyRelayProgress", 0)
    else
        player:SetAttribute("SkyRelayFeedback", "Sky Relay " .. nextStage .. "/3 — reach the next beacon!")
    end
end

for _, station in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = "RelayBeacon_" .. station.id
    model.Parent = rootFolder
    local plinth = Instance.new("Part")
    plinth.Name = "StoneBase"
    plinth.Size = Vector3.new(6, 1.5, 6)
    plinth.Position = station.pos
    plinth.Material = Enum.Material.Slate
    plinth.Anchored = true
    plinth.Parent = model
    local crystal = Instance.new("Part")
    crystal.Name = "RelayCrystal"
    crystal.Shape = Enum.PartType.Ball
    crystal.Size = Vector3.new(3, 4, 3)
    crystal.Position = station.pos + Vector3.new(0, 3, 0)
    crystal.Material = Enum.Material.Neon
    crystal.Color = station.color
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate Relay"
    prompt.ObjectText = "Sky Relay — " .. station.id
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.35
    prompt.RequiresLineOfSight = false
    prompt.Parent = plinth
    prompt.Triggered:Connect(function(player) interact(player, station) end)
end
Players.PlayerRemoving:Connect(function(player) state[player] = nil end)
