-- Original native 3D cooperative traversal challenge; session-only speed reward.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyLanternRules"))
local stations = {
    Vector3.new(-45, 2, 36),
    Vector3.new(170, 2, 32),
    Vector3.new(315, 2, 28),
}
local folder = Instance.new("Folder")
folder.Name = "SkyLanternCoop3D"
folder.Parent = Workspace
local nextIndex, startedAt, cooldownUntil = 1, nil, 0
local participants = {}
local boosted = {}
local function reset()
    nextIndex, startedAt, participants = 1, nil, {}
end
local function countParticipants()
    local n = 0
    for player in pairs(participants) do
        if player.Parent == Players then n += 1 end
    end
    return n
end
local function grantBoost()
    local expiry = os.clock() + Rules.BOOST_SECONDS
    for _, player in ipairs(Players:GetPlayers()) do
        -- All players share the reward for a server-wide cooperative event.
        boosted[player] = expiry
        player:SetAttribute("SkyLanternBoostUntil", expiry)
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.WalkSpeed = math.max(humanoid.WalkSpeed, 20)
        end
    end
end
for index, position in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = "SkyLanternStation" .. index
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "LanternPedestal"
    base.Size = Vector3.new(6, 3, 6)
    base.Position = position
    base.Anchored = true
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(74, 91, 124)
    base.Parent = model
    local lantern = Instance.new("Part")
    lantern.Name = "SkyLantern"
    lantern.Shape = Enum.PartType.Ball
    lantern.Size = Vector3.new(3, 3, 3)
    lantern.Position = position + Vector3.new(0, 3.5, 0)
    lantern.Anchored = true
    lantern.CanCollide = false
    lantern.Material = Enum.Material.Glass
    lantern.Color = Color3.fromRGB(126, 214, 228)
    lantern.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Light Lantern"
    prompt.ObjectText = "Co-op Sky Lantern " .. index .. "/3"
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        local now = os.clock()
        if startedAt and now - startedAt > Rules.WINDOW then reset() end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 or player:GetAttribute("ProfileReady") ~= true then return end
        local distance = (root.Position - base.Position).Magnitude
        if not Rules.canActivate(index, distance, now, startedAt, nextIndex, cooldownUntil) then return end
        if index == 1 then startedAt = now end
        participants[player] = true
        nextIndex += 1
        if nextIndex == 4 then
            if Rules.canComplete(countParticipants()) then
                grantBoost()
                cooldownUntil = now + Rules.COOLDOWN
            end
            reset()
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    participants[player] = nil
    boosted[player] = nil
end)
-- Avoid permanent speed boosts. Restore only the speed this system raised.
task.spawn(function()
    while true do
        task.wait(1)
        local now = os.clock()
        for player, expiry in pairs(boosted) do
            if now >= expiry or player.Parent ~= Players then
                boosted[player] = nil
                if player.Parent == Players then
                    player:SetAttribute("SkyLanternBoostUntil", nil)
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 and humanoid.WalkSpeed == 20 then
                        humanoid.WalkSpeed = 16
                    end
                end
            else
                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.WalkSpeed = math.max(humanoid.WalkSpeed, 20)
                end
            end
        end
    end
end)
