-- Original 3D checkpoint course. All completion logic runs on the server.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkywayTrialRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))

local course = Instance.new("Model")
course.Name = "SkywayTrial3D"
course.Parent = Workspace
local positions = {
    Vector3.new(-18, 9, 18),
    Vector3.new(-6, 9, 18),
    Vector3.new(6, 9, 18),
    Vector3.new(18, 9, 18),
}
local colors = {
    Color3.fromRGB(120, 220, 255),
    Color3.fromRGB(140, 255, 190),
    Color3.fromRGB(255, 215, 130),
    Color3.fromRGB(215, 155, 255),
}
local states = {}
local boosts = {}

local function part(name, size, position, color, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = parent
    return p
end

-- Solid connected course with no invisible platforms or Canvas geometry.
for i, position in ipairs(positions) do
    part("CheckpointPlatform" .. i, Vector3.new(12, 1, 12), position - Vector3.new(0, 3, 0), Color3.fromRGB(88, 125, 156), course)
    local marker = part("RunePillar" .. i, Vector3.new(2, 5, 2), position, colors[i], course)
    marker.Material = Enum.Material.Neon
    marker.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ActivateCheckpoint" .. i
    prompt.ActionText = i == 4 and "Finish skyway" or "Activate rune"
    prompt.ObjectText = "Skyway " .. i .. "/4"
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 9
    prompt.RequiresLineOfSight = false
    prompt.Parent = marker
    prompt.Triggered:Connect(function(player)
        if not ProfileStore.Get(player) then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - marker.Position).Magnitude > 11 then return end
        local now = os.clock()
        local nextState, result = Rules.advance(states[player], i, now)
        if nextState then states[player] = nextState end
        if result == "progress" then
            player:SetAttribute("SkywayNextCheckpoint", nextState.next)
        elseif result == "completed" then
            player:SetAttribute("SkywayNextCheckpoint", 1)
            player:SetAttribute("SkywayCompletions", (player:GetAttribute("SkywayCompletions") or 0) + 1)
            -- Temporary non-stacking reward. Token guards delayed reset after respawn/retrigger.
            local token = (boosts[player] or 0) + 1
            boosts[player] = token
            local original = humanoid.WalkSpeed
            humanoid.WalkSpeed = math.max(original, 23)
            task.delay(Rules.BOOST_SECONDS, function()
                if boosts[player] == token and humanoid.Parent and humanoid.Health > 0 then
                    humanoid.WalkSpeed = original
                end
            end)
        end
    end)
end

Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    boosts[player] = nil
end)
