-- Two-player cooperative puzzle on native 3D Parts. No client remotes or economy mutation.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("WeatherHarmonizerRules"))

local model = Instance.new("Model")
model.Name = "CooperativeWeatherHarmonizer3D"
model.Parent = Workspace
local pads = {}
local activations = {}
local lastCompleted = nil
local boosts = {} -- [player] = {humanoid, original, untilTime}

local function createPad(index, x, color)
    local base = Instance.new("Part")
    base.Name = "HarmonizerPad" .. index
    base.Size = Vector3.new(7, 1, 7)
    base.Position = Vector3.new(x, 2, 38)
    base.Anchored = true
    base.Color = color
    base.Material = Enum.Material.Slate
    base.Parent = model
    local crystal = Instance.new("Part")
    crystal.Name = "HarmonizerCrystal" .. index
    crystal.Shape = Enum.PartType.Ball
    crystal.Size = Vector3.new(3, 5, 3)
    crystal.Position = Vector3.new(x, 5, 38)
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Material = Enum.Material.Neon
    crystal.Color = color
    crystal.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Channel Weather"
    prompt.ObjectText = index == 1 and "Sun Rune" or "Rain Rune"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = crystal
    pads[index] = {crystal = crystal, prompt = prompt}
end
createPad(1, -31, Color3.fromRGB(245, 197, 93))
createPad(2, -15, Color3.fromRGB(93, 168, 245))

local function eligible(player, crystal)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return false end
    return Rules.canActivate((root.Position - crystal.Position).Magnitude, humanoid.Health > 0,
        ProfileStore.Get(player) ~= nil)
end

local function grantBoost(player, now)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    -- Never stack speed or override an unrelated existing effect.
    if boosts[player] then return end
    local original = humanoid.WalkSpeed
    if original <= 0 or original > 32 then return end
    boosts[player] = {humanoid = humanoid, original = original, untilTime = now + Rules.BOOST_SECONDS}
    humanoid.WalkSpeed = math.min(32, original + 4)
    player:SetAttribute("HarmonizerFeedback", "Weather harmonized! +4 speed for 25s")
end

for index, pad in ipairs(pads) do
    pad.prompt.Triggered:Connect(function(player)
        if not eligible(player, pad.crystal) then return end
        local now = os.clock()
        if not Rules.cooldownReady(lastCompleted, now) then
            player:SetAttribute("HarmonizerFeedback", "The harmonizer is recharging")
            return
        end
        activations[index] = {player = player, userId = player.UserId, at = now}
        player:SetAttribute("HarmonizerFeedback", "Rune charged! A different player must charge the other rune")
        local a, b = activations[1], activations[2]
        if a and b and Rules.complete(a, b, now) and eligible(a.player, pads[1].crystal)
            and eligible(b.player, pads[2].crystal) then
            activations = {}
            lastCompleted = now
            grantBoost(a.player, now)
            grantBoost(b.player, now)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        local now = os.clock()
        for i, activation in pairs(activations) do
            if now - activation.at > Rules.WINDOW or not activation.player.Parent then
                activations[i] = nil
            end
        end
        for player, state in pairs(boosts) do
            if now >= state.untilTime or not player.Parent or state.humanoid.Parent == nil then
                if state.humanoid.Parent and state.humanoid.WalkSpeed == math.min(32, state.original + 4) then
                    state.humanoid.WalkSpeed = state.original
                end
                boosts[player] = nil
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    for i, activation in pairs(activations) do
        if activation.player == player then activations[i] = nil end
    end
    boosts[player] = nil
end)
