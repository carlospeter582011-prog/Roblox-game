-- Original 3D respawn beacons: useful exploration checkpoints without DataStore schema changes.
-- Session-only on purpose: reconnect starts at Meadow until persistent travel is designed.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyBeaconRules"))
local active = {}
local folder = Instance.new("Folder")
folder.Name = "SkyRespawnBeacons3D"
folder.Parent = Workspace
for id, pos in pairs(Rules.POSITIONS) do
    local model = Instance.new("Model")
    model.Name = "Beacon_" .. id
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "StoneBase"
    base.Anchored = true
    base.Size = Vector3.new(7, 1, 7)
    base.Position = Vector3.new(pos.x, 1.5, pos.z)
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(83, 111, 151)
    base.Parent = model
    local crystal = Instance.new("Part")
    crystal.Name = "BeaconCrystal"
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Shape = Enum.PartType.Ball
    crystal.Size = Vector3.new(3, 3, 3)
    crystal.Position = Vector3.new(pos.x, 4, pos.z)
    crystal.Material = Enum.Material.Neon
    crystal.Color = Color3.fromRGB(115, 216, 233)
    crystal.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Set respawn"
    prompt.ObjectText = "Sky Beacon"
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local distance = (root.Position - base.Position).Magnitude
        if not Rules.canActivate(id, distance, humanoid.Health > 0, player:GetAttribute("ProfileReady")) then return end
        active[player] = id
        player:SetAttribute("ActiveSkyBeacon", id)
        player:SetAttribute("SkyBeaconFeedback", "Respawn set: " .. id)
    end)
end
local function onPlayer(player)
    player.CharacterAdded:Connect(function(character)
        local id = active[player]
        if not id then return end
        local root = character:WaitForChild("HumanoidRootPart", 10)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 or not player.Parent then return end
        local pos = Rules.spawnPosition(id)
        -- Place safely above the floor; no client remote can select a destination.
        character:PivotTo(CFrame.new(pos.x, pos.y + 5, pos.z))
    end)
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do onPlayer(player) end
Players.PlayerRemoving:Connect(function(player) active[player] = nil end)
