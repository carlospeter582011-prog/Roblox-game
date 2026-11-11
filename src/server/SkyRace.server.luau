-- Original physical sky race; touch checkpoints in order. Server alone tracks timing and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyRaceRules"))
local course = Instance.new("Model")
course.Name = "SkyRace3D"
course.Parent = Workspace
local state, cooldown = {}, {}
local positions = {
    Vector3.new(-25, 5, -70), Vector3.new(0, 7, -93),
    Vector3.new(25, 9, -116), Vector3.new(0, 7, -139),
    Vector3.new(-25, 5, -162),
}
local function part(name, size, position, color, material, collide)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, position
    p.Anchored, p.CanCollide = true, collide
    p.Color, p.Material = color, material
    p.Parent = course
    return p
end
for i, pos in ipairs(positions) do
    part("RacePlatform" .. i, Vector3.new(19, 2, 19), pos - Vector3.new(0, 3, 0),
        Color3.fromRGB(80, 132, 185), Enum.Material.Slate, true)
    local marker = part("Checkpoint" .. i, Vector3.new(9, 9, 2), pos,
        i == 1 and Color3.fromRGB(88, 230, 154) or Color3.fromRGB(245, 184, 86),
        Enum.Material.Neon, false)
    marker.Transparency = 0.4
    local lastTouch = {}
    marker.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if not player or player.Character ~= character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root or (root.Position - marker.Position).Magnitude > 15 then return end
        if not ProfileStore.Get(player) then return end
        local now = os.clock()
        if now - (lastTouch[player] or -1000) < 0.5 then return end
        lastTouch[player] = now
        if i == 1 then
            if state[player] or now < (cooldown[player] or 0) then return end
            state[player] = { started = now, next = 1 }
            player:SetAttribute("SkyRaceFeedback", "Race started! Reach all four gates in order.")
            player:SetAttribute("SkyRaceCheckpoint", 0)
            return
        end
        local current = state[player]
        if not current then return end
        local result, status = Rules.advance(current, i - 1, now)
        if not result then
            if status == "expired" or status == "too_fast" then
                state[player] = nil
                cooldown[player] = now + 10
                player:SetAttribute("SkyRaceFeedback", "Race invalid or timed out. Retry shortly.")
            end
            return
        end
        if result.completed then
            state[player] = nil
            cooldown[player] = now + Rules.cooldownSeconds
            local coins, xp = Rules.reward(result.elapsed)
            if coins and ProfileStore.AwardSkyRace(player, coins, xp) then
                player:SetAttribute("SkyRaceFeedback", string.format("Race complete in %.1fs! +%d Coins, +%d XP", result.elapsed, coins, xp))
            else
                player:SetAttribute("SkyRaceFeedback", "Race complete; reward unavailable.")
            end
            player:SetAttribute("SkyRaceCheckpoint", 4)
        else
            state[player] = result
            player:SetAttribute("SkyRaceCheckpoint", i - 1)
            player:SetAttribute("SkyRaceFeedback", "Gate " .. (i - 1) .. "/4")
        end
    end)
end
-- Broad physical stepping stones; the path is traversable by ordinary Roblox jumps.
for i = 1, #positions - 1 do
    local a, b = positions[i], positions[i + 1]
    local midpoint = (a + b) / 2 - Vector3.new(0, 3, 0)
    local length = (b - a).Magnitude
    local bridge = part("RaceBridge" .. i, Vector3.new(12, 2, length + 4), midpoint,
        Color3.fromRGB(102, 156, 196), Enum.Material.Slate, true)
    bridge.CFrame = CFrame.lookAt(midpoint, Vector3.new(b.X, midpoint.Y, b.Z))
end
Players.PlayerRemoving:Connect(function(player)
    state[player], cooldown[player] = nil, nil
end)
