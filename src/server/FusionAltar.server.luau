-- Original native 3D fusion altar. ProximityPrompt works on touch and gamepad.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local altar = Instance.new("Model")
altar.Name = "CloudFusionAltar3D"
altar.Parent = Workspace
local function make(name, shape, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Shape = shape
    part.Size = size
    part.Position = position
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.Parent = altar
    return part
end
make("StoneBase", Enum.PartType.Cylinder, Vector3.new(1.5, 9, 9),
    Vector3.new(-25, 2, 25), Color3.fromRGB(86, 103, 154), Enum.Material.Slate)
local crystal = make("FusionCrystal", Enum.PartType.Ball, Vector3.new(4, 4, 4),
    Vector3.new(-25, 6, 25), Color3.fromRGB(130, 230, 255), Enum.Material.Neon)
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Fuse 2 spare clouds"
prompt.ObjectText = "Companion Fusion Altar"
prompt.HoldDuration = 0.6
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = crystal
local lastUse = {}
prompt.Triggered:Connect(function(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - crystal.Position).Magnitude > 15 then return end
    local now = os.clock()
    if now - (lastUse[player] or -100) < 1.5 then return end
    lastUse[player] = now
    local ok, message = ProfileStore.FuseCompanionDuplicates(player)
    player:SetAttribute("FusionFeedback", message)
end)
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
