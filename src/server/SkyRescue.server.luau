-- Server-owned 3D checkpoint pads and safe fall recovery for the three connected islands.
-- Session checkpoints are deliberately not client remotes or persisted unlocks.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRescueRules"))

local folder = Instance.new("Folder")
folder.Name = "SkyRescueCheckpoints3D"
folder.Parent = Workspace
local checkpoints = {}
local lastRescue = {}
local lastActivation = {}

for id, point in pairs(Rules.CHECKPOINTS) do
    local pad = Instance.new("Part")
    pad.Name = "RescueCheckpoint_" .. id
    pad.Size = Vector3.new(9, 0.5, 9)
    pad.Position = Vector3.new(point.x, 1.4, point.z)
    pad.Shape = Enum.PartType.Cylinder
    pad.Anchored = true
    pad.CanCollide = false
    pad.Material = Enum.Material.Neon
    pad.Color = Color3.fromRGB(95, 205, 234)
    pad.Transparency = 0.3
    pad.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ActivateCheckpoint"
    prompt.ActionText = "Set rescue point"
    prompt.ObjectText = "Sky Beacon"
    prompt.HoldDuration = 0.3
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = pad
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local distance = (root.Position - pad.Position).Magnitude
        if Rules.canActivate(id, distance, player:GetAttribute("ProfileReady"), humanoid.Health > 0) then
            checkpoints[player] = id
            lastActivation[player] = os.clock()
            player:SetAttribute("SkyRescuePoint", id)
        end
    end)
end

local function watchCharacter(player, character)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not root or not humanoid then return end
    while player.Parent and player.Character == character and humanoid.Health > 0 do
        local now = os.clock()
        if Rules.shouldRescue(root.Position.Y, now, lastRescue[player] or -100000,
            player:GetAttribute("ProfileReady"), humanoid.Health > 0) then
            -- Prevent a fallen player from being lost beneath the kill plane.
            lastRescue[player] = now
            local dest = Rules.destination(checkpoints[player])
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            character:PivotTo(CFrame.new(dest.x, dest.y, dest.z))
            player:SetAttribute("SkyRescueFeedback", "Returned to your last Sky Beacon")
        end
        task.wait(0.2)
    end
end

Players.PlayerAdded:Connect(function(player)
    checkpoints[player] = "meadow"
    player:SetAttribute("SkyRescuePoint", "meadow")
    player.CharacterAdded:Connect(function(character)
        task.spawn(watchCharacter, player, character)
    end)
    if player.Character then task.spawn(watchCharacter, player, player.Character) end
end)
Players.PlayerRemoving:Connect(function(player)
    checkpoints[player] = nil
    lastRescue[player] = nil
    lastActivation[player] = nil
end)
