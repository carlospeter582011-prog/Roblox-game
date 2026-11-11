-- Original native 3D fusion altar, not a Canvas world stand-in.
-- ProximityPrompt triggers server-owned deterministic fusion; no client reward remote.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local cooldown = {}
local altar = Instance.new("Model")
altar.Name = "SkyFusionAltar3D"
local function piece(name, size, position, material, color, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = name == "Base"
    p.Size = size
    p.Position = position
    p.Material = material
    p.Color = color
    if shape then p.Shape = shape end
    p.Parent = altar
    return p
end
local base = piece("Base", Vector3.new(11, 2, 11), Vector3.new(-28, 2, 25),
    Enum.Material.Slate, Color3.fromRGB(80, 104, 148))
piece("Core", Vector3.new(4, 4, 4), Vector3.new(-28, 5, 25),
    Enum.Material.Neon, Color3.fromRGB(126, 222, 245), Enum.PartType.Ball).CanCollide = false
for i = 1, 4 do
    local angle = i * math.pi / 2
    piece("OrbitStone" .. i, Vector3.new(2, 2, 2),
        Vector3.new(-28 + math.cos(angle) * 4, 5, 25 + math.sin(angle) * 4),
        Enum.Material.Glass, Color3.fromRGB(194, 152, 255), Enum.PartType.Ball).CanCollide = false
end
altar.PrimaryPart = base
altar.Parent = workspace
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Fuse 3 duplicates"
prompt.ObjectText = "Sky Fusion Altar (keeps 1 original)"
prompt.MaxActivationDistance = 10
prompt.HoldDuration = 0.7
prompt.RequiresLineOfSight = false
prompt.Parent = base
prompt.Triggered:Connect(function(player)
    local now = os.clock()
    if now - (cooldown[player] or -100) < 1.5 then return end
    cooldown[player] = now
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 or
        (root.Position - base.Position).Magnitude > 13 then return end
    local ok, message = Profile.FuseCloud(player)
    player:SetAttribute("LastFusionResult", ok and message or ("Fusion: " .. message))
end)
Players.PlayerRemoving:Connect(function(player) cooldown[player] = nil end)
