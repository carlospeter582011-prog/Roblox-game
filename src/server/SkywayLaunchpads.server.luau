-- Original native 3D skyway fast-travel launchpads; no external meshes or client remotes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkywayRules"))
local lastUsed = {}
local folder = Instance.new("Folder")
folder.Name = "SkywayLaunchpads3D"
folder.Parent = workspace
for id, route in pairs(Rules.routes) do
    local pad = Instance.new("Part")
    pad.Name = id
    pad.Size = Vector3.new(9, 1, 9)
    pad.Position = Vector3.new(route.from[1], route.from[2], route.from[3])
    pad.Anchored = true
    pad.Material = Enum.Material.Neon
    pad.Color = Color3.fromRGB(102, 206, 238)
    pad.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Travel"
    prompt.ObjectText = "Skyway " .. id:gsub("_", " ")
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = pad
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local now = os.clock()
        local distance = (root.Position - pad.Position).Magnitude
        if not Rules.canLaunch(id, distance, now, lastUsed[player.UserId] or -1e9, player:GetAttribute("ProfileReady")) then return end
        lastUsed[player.UserId] = now
        local destination = route.to
        character:PivotTo(CFrame.new(destination[1], destination[2], destination[3]))
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastUsed[player.UserId] = nil
end)
