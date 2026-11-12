-- Original 3D Companion Training Pavilion: a persistent Coin sink and bond progression.
-- ProximityPrompt is touch/gamepad/keyboard accessible; all rewards validated on server.
local Players = game:GetService("Players")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local pavilion = Instance.new("Model")
pavilion.Name = "CompanionTrainingPavilion3D"
pavilion.Parent = workspace
local function piece(name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Color = color
    p.Material = material
    p.Parent = pavilion
    return p
end
local center = Vector3.new(35, 2, 35)
piece("TrainingBase", Vector3.new(13, 1, 13), center, Color3.fromRGB(112, 143, 184), Enum.Material.Slate)
for _, x in ipairs({ -5, 5 }) do
    for _, z in ipairs({ -5, 5 }) do
        piece("SkyPillar", Vector3.new(1.3, 7, 1.3), center + Vector3.new(x, 4, z),
            Color3.fromRGB(170, 204, 231), Enum.Material.Marble)
    end
end
piece("PavilionRoof", Vector3.new(13, 1, 13), center + Vector3.new(0, 8, 0),
    Color3.fromRGB(104, 157, 211), Enum.Material.SmoothPlastic)
local altar = piece("BondTrainingAltar", Vector3.new(3, 3, 3), center + Vector3.new(0, 2, 0),
    Color3.fromRGB(140, 225, 245), Enum.Material.Glass)
altar.Shape = Enum.PartType.Ball
altar.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Train Companion"
prompt.ObjectText = "Cloud Bond Academy (Coins)"
prompt.MaxActivationDistance = 12
prompt.HoldDuration = 0.5
prompt.RequiresLineOfSight = false
prompt.Parent = altar
prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - altar.Position).Magnitude > 15 then return end
    if player:GetAttribute("ProfileReady") ~= true then return end
    local ok, message = Profile.TrainCompanion(player)
    player:SetAttribute("CompanionTrainingFeedback", message)
end)
