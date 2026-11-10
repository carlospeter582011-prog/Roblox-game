-- Original native Roblox 3D fusion altar. Server owns species selection and payment.
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Profile = require(ServerScriptService:WaitForChild("ProfileStore"))
local busy = {}
local altar = Instance.new("Model")
altar.Name = "CloudFusionAltar"
local function part(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.Material = material
    p.Color = color
    p.Parent = altar
    return p
end
local base = part("StoneBase", Vector3.new(9, 1, 9), Vector3.new(19, 5, 0), Color3.fromRGB(87, 77, 132), Enum.Material.Slate)
part("Core", Vector3.new(3, 4, 3), Vector3.new(19, 7.5, 0), Color3.fromRGB(142, 103, 236), Enum.Material.Neon).CanCollide = false
for i = 1, 4 do
    local angle = i * math.pi / 2
    part("Pillar" .. i, Vector3.new(1, 5, 1),
        Vector3.new(19 + math.cos(angle) * 3.5, 7.5, math.sin(angle) * 3.5),
        Color3.fromRGB(118, 105, 165), Enum.Material.SmoothPlastic)
end
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Fuse 2 spare clouds (75 Coins)"
prompt.ObjectText = "Sky Fusion Altar"
prompt.MaxActivationDistance = 11
prompt.HoldDuration = 0.6
prompt.RequiresLineOfSight = false
prompt.Parent = base
altar.Parent = workspace

prompt.Triggered:Connect(function(player)
    if busy[player] or not player.Parent or player:GetAttribute("ProfileReady") ~= true then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root or (root.Position - base.Position).Magnitude > 14 then return end
    busy[player] = true
    -- Use equipped companion only; clients cannot inject arbitrary species or costs.
    local speciesId = player:GetAttribute("CompanionSpecies")
    local ok, message = Profile.FuseCloud(player, speciesId)
    player:SetAttribute("FusionFeedback", ok and message or ("Fusion: " .. tostring(message)))
    busy[player] = nil
end)
Players.PlayerRemoving:Connect(function(player) busy[player] = nil end)
