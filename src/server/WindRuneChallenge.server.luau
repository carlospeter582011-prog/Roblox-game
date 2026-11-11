-- Three original native 3D rune pillars: ordered exploration puzzle and temporary speed reward.
-- Server validates all ProximityPrompt activations; no client-supplied state or rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("WindRuneRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local model = Instance.new("Model")
model.Name = "WindRuneChallenge3D"
model.Parent = Workspace
local states = {}
local boosts = {}
local function pillar(id, position, color)
    local p = Instance.new("Part")
    p.Name = id .. "RunePillar"
    p.Anchored = true
    p.Size = Vector3.new(5, 8, 5)
    p.Position = position
    p.Material = Enum.Material.Slate
    p.Color = color
    p.Parent = model
    local orb = Instance.new("Part")
    orb.Name = id .. "RuneOrb"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(3, 3, 3)
    orb.Position = position + Vector3.new(0, 6, 0)
    orb.Anchored = true
    orb.CanCollide = false
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate"
    prompt.ObjectText = id .. " Rune"
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = p
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        local now = os.clock()
        local nextState, outcome = Rules.step(states[player], id, now,
            (root.Position - p.Position).Magnitude, hum.Health > 0,
            Profile.Get(player) ~= nil and player:GetAttribute("ProfileReady") == true)
        states[player] = nextState
        if outcome == "progress" then
            player:SetAttribute("WindRuneFeedback", "Rune " .. nextState.index .. "/3 activated")
        elseif outcome == "reset" then
            player:SetAttribute("WindRuneFeedback", "Wrong order! Try Air, Rain, Storm.")
        elseif outcome == "complete" then
            player:SetAttribute("WindRuneFeedback", "Wind blessing! Speed boosted for 20 seconds.")
            local original = hum.WalkSpeed
            local token = (boosts[player] or 0) + 1
            boosts[player] = token
            hum.WalkSpeed = math.max(original, Rules.BOOST_SPEED)
            task.delay(Rules.BOOST_SECONDS, function()
                if boosts[player] == token and hum.Parent and hum.WalkSpeed == Rules.BOOST_SPEED then
                    hum.WalkSpeed = original
                end
            end)
        end
    end)
end
-- On the connected Thunderhead Ridge; within its 110x100 walkable ground.
pillar("air", Vector3.new(292, 5, -22), Color3.fromRGB(175, 226, 255))
pillar("rain", Vector3.new(315, 5, 20), Color3.fromRGB(100, 174, 235))
pillar("storm", Vector3.new(341, 5, -20), Color3.fromRGB(179, 143, 255))
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    boosts[player] = nil
end)
