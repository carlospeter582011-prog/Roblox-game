-- Three native Roblox 3D checkpoints; session-only time trial, no exploitable currency grants.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRelayRules"))
local states = {}
local best = {}
local gates = {
    Vector3.new(0, 13, 18),
    Vector3.new(36, 13, -12),
    Vector3.new(-30, 13, -38),
}
local folder = Instance.new("Folder")
folder.Name = "SkyRelayCourse"
folder.Parent = workspace
for index, position in ipairs(gates) do
    local model = Instance.new("Model")
    model.Name = "RelayCheckpoint" .. index
    model.Parent = folder
    for side = -1, 1, 2 do
        local pillar = Instance.new("Part")
        pillar.Name = "Pillar"
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.Material = Enum.Material.Neon
        pillar.Color = Color3.fromRGB(90, 205, 235)
        pillar.Size = Vector3.new(1.4, 10, 1.4)
        pillar.Position = position + Vector3.new(side * 5, 0, 0)
        pillar.Parent = model
    end
    local top = Instance.new("Part")
    top.Name = "Arch"
    top.Anchored = true
    top.CanCollide = false
    top.Material = Enum.Material.Neon
    top.Color = Color3.fromRGB(130, 245, 190)
    top.Size = Vector3.new(12, 1.4, 1.4)
    top.Position = position + Vector3.new(0, 5, 0)
    top.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = index == 1 and "Start Sky Relay" or ("Checkpoint " .. index)
    prompt.ObjectText = "Sky Relay"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.2
    prompt.RequiresLineOfSight = false
    prompt.Parent = top
    prompt.Triggered:Connect(function(player)
        if player:GetAttribute("ProfileReady") ~= true then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root then return end
        if (root.Position - top.Position).Magnitude > 15 then return end
        local nextState, result = Rules.advance(states[player], index, os.clock())
        if not nextState then
            player:SetAttribute("RelayStatus", result)
            return
        end
        states[player] = nextState
        if result == "finished" then
            local elapsed = nextState.finished
            if not best[player] or elapsed < best[player] then
                best[player] = elapsed
                player:SetAttribute("RelayBestSeconds", math.floor(elapsed * 100) / 100)
            end
            player:SetAttribute("RelayStatus", "Finished " .. string.format("%.2f", elapsed) .. "s")
            states[player] = nil
        else
            player:SetAttribute("RelayStatus", result == "started" and "Race started!" or ("Checkpoint " .. index .. " cleared"))
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    best[player] = nil
end)
