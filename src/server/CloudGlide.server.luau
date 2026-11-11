-- Earned midair glide. Client only requests activation; server owns eligibility and movement.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Glide = require(ReplicatedStorage:WaitForChild("CloudGlideRules"))
local remote = Instance.new("RemoteEvent")
remote.Name = "RequestCloudGlide"
remote.Parent = ReplicatedStorage
local active, last = {}, {}
local function stop(player)
    active[player] = nil
    if player.Parent then player:SetAttribute("CloudGliding", false) end
end
remote.OnServerEvent:Connect(function(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local profile = ProfileStore.Get(player)
    if not root or not humanoid or not profile or active[player] then return end
    local now = os.clock()
    if not Glide.canStart(profile.captures, humanoid.Health > 0,
        humanoid.FloorMaterial ~= Enum.Material.Air, now, last[player]) then return end
    last[player] = now
    active[player] = {untilTime = now + Glide.Duration, character = character}
    player:SetAttribute("CloudGliding", true)
end)
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    for player, session in pairs(active) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if character ~= session.character or not root or not humanoid or humanoid.Health <= 0
            or humanoid.FloorMaterial ~= Enum.Material.Air or now >= session.untilTime then
            stop(player)
        else
            local forward = root.CFrame.LookVector
            local velocity = root.AssemblyLinearVelocity
            local x, y, z = Glide.velocity(forward.X, forward.Z, velocity.Y)
            -- Only slow a fall; do not turn glide into unlimited upward flight.
            if velocity.Y <= 0 then
                root.AssemblyLinearVelocity = Vector3.new(x, y, z)
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
    last[player] = nil
end)
