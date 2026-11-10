-- Server-authoritative automatic rescue from falling off the floating islands.
-- Does not grant Coins/XP and does not trust a client RemoteEvent.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRescueRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local lastRescue = {}
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator < 0.25 then return end
    accumulator = 0
    local now = os.clock()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root and humanoid and Rules.canRecover(root.Position.Y, now, lastRescue[player],
            humanoid.Health > 0, ProfileStore.Get(player) ~= nil) then
            local spawn = Rules.destination(root.Position.X, root.Position.Z)
            if spawn then
                lastRescue[player] = now
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                character:PivotTo(CFrame.new(spawn.x, spawn.y, spawn.z))
                player:SetAttribute("TravelFeedback", "Sky rescue! Returned to safe ground.")
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(player) lastRescue[player] = nil end)
