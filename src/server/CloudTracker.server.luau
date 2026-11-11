-- Server-authoritative, free discovery aid. Real 3D beacon, no client-request remote.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudTrackerRules"))
local beacon = Instance.new("Model")
beacon.Name = "CloudTrackerBeacon3D"
local pedestal = Instance.new("Part")
pedestal.Name = "TrackerPedestal"
pedestal.Anchored = true
pedestal.Size = Vector3.new(5, 3, 5)
pedestal.Position = Vector3.new(16, 2.5, -16)
pedestal.Material = Enum.Material.Slate
pedestal.Color = Color3.fromRGB(74, 93, 135)
pedestal.Parent = beacon
local orb = Instance.new("Part")
orb.Name = "TrackerOrb"
orb.Anchored = true
orb.CanCollide = false
orb.CanTouch = false
orb.Shape = Enum.PartType.Ball
orb.Size = Vector3.new(3, 3, 3)
orb.Position = Vector3.new(16, 5.5, -16)
orb.Material = Enum.Material.Glass
orb.Color = Color3.fromRGB(105, 220, 230)
orb.Parent = beacon
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Locate undiscovered cloud"
prompt.ObjectText = "Cloud Tracker"
prompt.HoldDuration = 0.4
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = orb
beacon.Parent = Workspace
local remote = Instance.new("RemoteEvent")
remote.Name = "CloudTrackerResult"
remote.Parent = ReplicatedStorage
local lastUsed = {}
prompt.Triggered:Connect(function(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local profile = Profile.Get(player)
    if not root or not profile then return end
    local now = os.clock()
    local elapsed = now - (lastUsed[player] or -100000)
    if not Rules.canActivate((root.Position - orb.Position).Magnitude, elapsed,
        player:GetAttribute("ProfileReady"), humanoid ~= nil and humanoid.Health > 0) then return end
    lastUsed[player] = now
    local folder = Workspace:FindFirstChild("CatchableClouds")
    local candidates = {}
    if folder then
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("BasePart") and item:GetAttribute("CloudId") and item:GetAttribute("SpeciesId") then
                table.insert(candidates, {
                    id = item:GetAttribute("CloudId"),
                    species = item:GetAttribute("SpeciesId"),
                    x = item.Position.X, z = item.Position.Z,
                })
            end
        end
    end
    local chosen = Rules.choose(candidates, profile.species or {}, { x = root.Position.X, z = root.Position.Z })
    remote:FireClient(player, chosen and chosen.id or "", Rules.DURATION)
end)
Players.PlayerRemoving:Connect(function(player) lastUsed[player] = nil end)
