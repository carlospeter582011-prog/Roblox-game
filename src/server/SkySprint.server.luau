-- Original 3D sky sprint: five physical checkpoint gates and server-owned rewards.
-- Session cooldown only; live geometry, collisions and balance need Roblox playtests.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkySprintRules"))
local folder = Instance.new("Folder")
folder.Name = "SkySprintCourse3D"
folder.Parent = Workspace
local active = {}
local lastFinish = {}
local points = {
    Vector3.new(-35, 5, -36),
    Vector3.new(-14, 5, -36),
    Vector3.new(7, 5, -36),
    Vector3.new(28, 5, -36),
    Vector3.new(49, 5, -36),
}
local function part(name, size, position, color, parent, collision)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.CanCollide = collision
    p.Parent = parent
    return p
end
for index, position in ipairs(points) do
    local model = Instance.new("Model")
    model.Name = "SprintGate" .. index
    model.Parent = folder
    local floor = part("SafePlatform", Vector3.new(14, 1.5, 15),
        position - Vector3.new(0, 3, 0), Color3.fromRGB(74, 123, 155), model, true)
    part("LeftPillar", Vector3.new(1.5, 9, 1.5),
        position + Vector3.new(-5, 1, 0), Color3.fromRGB(102, 194, 225), model, false)
    part("RightPillar", Vector3.new(1.5, 9, 1.5),
        position + Vector3.new(5, 1, 0), Color3.fromRGB(102, 194, 225), model, false)
    local arch = part("Arch", Vector3.new(11, 1.5, 1.5),
        position + Vector3.new(0, 5, 0), Color3.fromRGB(144, 225, 240), model, false)
    arch.Material = Enum.Material.Neon
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = index == 1 and "Start Sky Sprint" or ("Checkpoint " .. index)
    prompt.ObjectText = "Sky Sprint " .. index .. "/" .. #points
    prompt.MaxActivationDistance = 9
    prompt.HoldDuration = 0.2
    prompt.RequiresLineOfSight = false
    prompt.Parent = floor
    prompt.Triggered:Connect(function(player)
        local profile = ProfileStore.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - floor.Position).Magnitude > 12 then return end
        local now = os.clock()
        if index == 1 then
            local state, err = Rules.start(now, lastFinish[player])
            if not state then
                player:SetAttribute("SkySprintFeedback", err == "cooldown" and "Race resting. Try later!" or "Race unavailable")
                return
            end
            active[player] = state
            player:SetAttribute("SkySprintProgress", "1/" .. Rules.checkpoints)
            player:SetAttribute("SkySprintFeedback", "Go! Reach all gates in order.")
            return
        end
        local state = active[player]
        local result = Rules.advance(state, index, now)
        if result == "expired" then
            active[player] = nil
            player:SetAttribute("SkySprintFeedback", "Time up! Restart the race.")
        elseif result == "advanced" then
            player:SetAttribute("SkySprintProgress", index .. "/" .. Rules.checkpoints)
        elseif result == "finished" then
            active[player] = nil
            lastFinish[player] = now
            local ok = ProfileStore.AwardSkySprint(player, Rules.rewardCoins, Rules.rewardXP)
            player:SetAttribute("SkySprintFeedback", ok and "Sky Sprint cleared! Coins and XP earned!" or "Race complete; reward unavailable.")
            player:SetAttribute("SkySprintProgress", "")
        elseif result == "out_of_order" then
            player:SetAttribute("SkySprintFeedback", "Follow the gates in order!")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
    lastFinish[player] = nil
end)
