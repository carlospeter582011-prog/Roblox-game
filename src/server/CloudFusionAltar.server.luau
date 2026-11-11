-- Original procedural 3D fusion altar; no third-party assets or 2D world stand-ins.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))

local model = Instance.new("Model")
model.Name = "CloudFusionAltar3D"
model.Parent = Workspace

local function part(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material
    p.Parent = model
    return p
end

local base = part("FusionPedestal", Vector3.new(8, 1.2, 8),
    Vector3.new(32, 1.8, 18), Color3.fromRGB(66, 91, 132), Enum.Material.Slate)
base.Shape = Enum.PartType.Cylinder
local core = part("FusionCore", Vector3.new(3, 3, 3),
    Vector3.new(32, 4, 18), Color3.fromRGB(125, 203, 224), Enum.Material.Glass)
core.Shape = Enum.PartType.Ball
core.Transparency = 0.25
for i = 1, 4 do
    local angle = i * math.pi / 2
    local shard = part("FusionShard" .. i, Vector3.new(0.8, 2.5, 0.8),
        Vector3.new(32 + math.cos(angle) * 3, 3.5, 18 + math.sin(angle) * 3),
        Color3.fromRGB(150, 130, 228), Enum.Material.SmoothPlastic)
    shard.Shape = Enum.PartType.Ball
end

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "FuseClouds"
prompt.ActionText = "Fuse duplicates"
prompt.ObjectText = "Cloud Fusion Altar"
prompt.MaxActivationDistance = 11
prompt.RequiresLineOfSight = false
prompt.HoldDuration = 0.7
prompt.Parent = core

local lastUse = {}
prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - core.Position).Magnitude > 13 then return end
    if player:GetAttribute("ProfileReady") ~= true then return end
    local now = os.clock()
    if now - (lastUse[player] or -100) < 2 then return end
    lastUse[player] = now
    local ok, message = Profile.FuseFirstAvailable(player)
    player:SetAttribute("CloudFusionFeedback", (ok and "SUCCESS: " or "INFO: ") .. message)
end)
Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
