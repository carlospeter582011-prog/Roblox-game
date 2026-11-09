-- Server-side rescue for players falling off the starter island.
-- Uses actual character physics/3D CFrames, never a Canvas world substitute.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("RecoveryRules"))
local lastRescue = {}
local elapsed = 0

Players.PlayerRemoving:Connect(function(player)
    lastRescue[player] = nil
end)

RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.25 then return end
    elapsed = 0
    local now = os.clock()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 then
            local pos = root.Position
            local distance = Vector2.new(pos.X, pos.Z).Magnitude
            if Rules.shouldRecover(pos.Y, distance, now, lastRescue[player]) then
                lastRescue[player] = now
                character:PivotTo(CFrame.new(0, 9, 0))
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end)
