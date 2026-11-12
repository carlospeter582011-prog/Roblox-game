-- Three-stage cooperative-friendly rescue relay: each player has independent state.
-- Native 3D Parts and ProximityPrompts; no client remotes or permanent currency.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("CloudRescueRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local states = {}
local folder = Instance.new("Model")
folder.Name = "CloudRescueRelay3D"
folder.Parent = workspace
local stations = {
    { Vector3.new(162, 2, -25), "Find the Lost Cloud" },
    { Vector3.new(184, 2, -4), "Calm the Cloud" },
    { Vector3.new(163, 2, 24), "Guide it Home" },
}
local function makePart(name, size, pos, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = pos
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Material = Enum.Material.SmoothPlastic
    part.Color = color
    part.Parent = parent
    return part
end
for index, info in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = "RescueStation" .. index
    model.Parent = folder
    local pedestal = makePart("RescuePedestal", Vector3.new(5, 2, 5), info[1], Color3.fromRGB(92, 142, 180), model)
    pedestal.Shape = Enum.PartType.Cylinder
    for puff = 1, 3 do
        local cloud = makePart("CloudPuff" .. puff, Vector3.new(3, 2.4, 3), info[1] + Vector3.new((puff - 2) * 1.5, 3.4, 0), Color3.fromRGB(210, 239, 250), model)
        cloud.Shape = Enum.PartType.Ball
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = info[2]
    prompt.ObjectText = "Sky Rescue " .. index .. "/3"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local ready = player:GetAttribute("ProfileReady") == true and Profile.Get(player) ~= nil
        local nextState, result = Rules.step(states[player], index, os.clock(), (root.Position - pedestal.Position).Magnitude, ready)
        if not nextState then
            player:SetAttribute("RescueFeedback", result == "order" and "Follow rescue stations 1, 2, 3!" or "Rescue unavailable: " .. result)
            return
        end
        states[player] = nextState
        player:SetAttribute("RescueStage", nextState.stage)
        if result == "complete" then
            player:SetAttribute("RescueCompletions", (player:GetAttribute("RescueCompletions") or 0) + 1)
            player:SetAttribute("RescueFeedback", "Cloud rescued! Sky trail completed.")
            -- Reward is session-only; no unsafely saved currency or permanent unlock.
        else
            player:SetAttribute("RescueFeedback", "Rescue step " .. index .. "/3. Keep going!")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
