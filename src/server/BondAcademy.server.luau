-- Original native Roblox 3D companion training station; touch/gamepad friendly.
local Players = game:GetService("Players")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("BondAcademyRules"))
local model = Instance.new("Model")
model.Name = "CloudBondAcademy"
local function piece(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.CanCollide = true
    p.Color = color
    p.Material = material
    p.Parent = model
    return p
end
piece("TrainingPlatform", Vector3.new(12, 1, 10), Vector3.new(26, 1.5, -24), Color3.fromRGB(85, 105, 155), Enum.Material.Slate)
for _, x in ipairs({22, 30}) do
    piece("AcademyPillar", Vector3.new(1.5, 6, 1.5), Vector3.new(x, 4.5, -27), Color3.fromRGB(150, 190, 225), Enum.Material.Marble)
end
local crystal = piece("BondBeacon", Vector3.new(3, 3, 3), Vector3.new(26, 5, -27), Color3.fromRGB(135, 230, 255), Enum.Material.Neon)
crystal.Shape = Enum.PartType.Ball
crystal.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Train bond (75 Coins)"
prompt.ObjectText = "Cloud Academy"
prompt.HoldDuration = 0.6
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = crystal
model.Parent = workspace
local lastUse = {}
prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local now = os.clock()
    if now - (lastUse[player] or -10) < 1.2 then return end
    lastUse[player] = now
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local ok, message = Profile.TrainCompanion(player, (root.Position - crystal.Position).Magnitude)
    player:SetAttribute("BondAcademyFeedback", message)
end)
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
