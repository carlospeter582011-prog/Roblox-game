-- Sky Trail: original 3D cross-island time trial with server-authoritative progression.
-- Session-only best times; not a persistent leaderboard or currency source.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyTrailRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local trail = Instance.new("Model")
trail.Name = "SkyTrail3D"
trail.Parent = Workspace
local state = {}
local best = {}
local boosted = {}
local function makeMarker(name, pos, color)
    local base = Instance.new("Part")
    base.Name = name
    base.Anchored = true
    base.CanCollide = false
    base.Size = Vector3.new(5, 1, 5)
    base.Position = pos
    base.Material = Enum.Material.Neon
    base.Color = color
    base.Parent = trail
    local pillar = Instance.new("Part")
    pillar.Name = name .. "Beacon"
    pillar.Anchored = true
    pillar.CanCollide = false
    pillar.Size = Vector3.new(1.5, 8, 1.5)
    pillar.Position = pos + Vector3.new(0, 4, 0)
    pillar.Material = Enum.Material.Glass
    pillar.Color = color
    pillar.Parent = trail
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate"
    prompt.ObjectText = name
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0.25
    prompt.Parent = base
    return base, prompt
end
local function eligible(player, marker)
    if not player or not player.Parent or not Profile.Get(player) then return false end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local human = character and character:FindFirstChildOfClass("Humanoid")
    return root ~= nil and human ~= nil and human.Health > 0
        and (root.Position - marker.Position).Magnitude <= 15
end
local startPart, startPrompt = makeMarker("Sky Trail Start", Vector3.new(-25, 2.5, 18), Color3.fromRGB(90, 245, 170))
local markers = {}
for i, entry in ipairs({
    { Vector3.new(65, 2.5, 18), Color3.fromRGB(120, 200, 255) },
    { Vector3.new(170, 2.5, 18), Color3.fromRGB(250, 210, 110) },
    { Vector3.new(315, 2.5, 18), Color3.fromRGB(220, 130, 255) },
}) do
    local marker, prompt = makeMarker("Sky Trail " .. i, entry[1], entry[2])
    markers[i] = { marker = marker, prompt = prompt }
end
startPrompt.Triggered:Connect(function(player)
    if not eligible(player, startPart) then return end
    local nextState, reason = Rules.begin(state[player], os.clock())
    if nextState then
        state[player] = nextState
        player:SetAttribute("SkyTrailStatus", "Reach beacon 1 of 3!")
    elseif reason == "cooldown" then
        player:SetAttribute("SkyTrailStatus", "Trail resting: try again shortly")
    end
end)
for i, entry in ipairs(markers) do
    entry.prompt.Triggered:Connect(function(player)
        if not eligible(player, entry.marker) then return end
        local nextState, reason = Rules.advance(state[player], i, os.clock())
        if not nextState then
            if reason == "expired" then
                state[player] = nil
                player:SetAttribute("SkyTrailStatus", "Time expired. Return to the start!")
            end
            return
        end
        state[player] = nextState
        if reason ~= "finished" then
            player:SetAttribute("SkyTrailStatus", "Beacon " .. i .. "/3 — keep going!")
            return
        end
        local elapsed = nextState.elapsed
        if not best[player] or elapsed < best[player] then best[player] = elapsed end
        player:SetAttribute("SkyTrailBestSeconds", math.floor(best[player] * 10 + 0.5) / 10)
        player:SetAttribute("SkyTrailStatus", string.format("Trail cleared in %.1fs! Speed blessing!", elapsed))
        -- Reward cannot stack; restore only if this script still owns the speed.
        local character = player.Character
        local human = character and character:FindFirstChildOfClass("Humanoid")
        if human and not boosted[human] then
            local previous = human.WalkSpeed
            local increased = math.min(previous + 4, 24)
            boosted[human] = increased
            human.WalkSpeed = increased
            task.delay(20, function()
                if boosted[human] == increased then
                    boosted[human] = nil
                    if human.Parent and human.WalkSpeed == increased then human.WalkSpeed = previous end
                end
            end)
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    state[player] = nil
    best[player] = nil
end)
