-- Original native 3D station; no client remote or GUI world stand-in.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local base = Instance.new("Part")
base.Name = "CloudRecyclingAltar3D"
base.Size = Vector3.new(7, 2, 7)
base.Position = Vector3.new(-24, 5, 18)
base.Anchored = true
base.Material = Enum.Material.Slate
base.Color = Color3.fromRGB(95, 145, 190)
base.Parent = Workspace
local orb = Instance.new("Part")
orb.Name = "RecyclingOrb3D"
orb.Shape = Enum.PartType.Ball
orb.Size = Vector3.new(3, 3, 3)
orb.Position = base.Position + Vector3.new(0, 3, 0)
orb.Anchored = true
orb.CanCollide = false
orb.Material = Enum.Material.Neon
orb.Color = Color3.fromRGB(145, 240, 255)
orb.Parent = Workspace
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Recycle 3 duplicate clouds"
prompt.ObjectText = "+35 Coins / +20 XP (keep one)"
prompt.MaxActivationDistance = 11
prompt.HoldDuration = 0.5
prompt.Parent = base
local cooldown = {}
prompt.Triggered:Connect(function(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - base.Position).Magnitude > 14 then return end
    if not Profile.Get(player) then return end
    local now = os.clock()
    if now < (cooldown[player] or 0) then return end
    cooldown[player] = now + 2
    local ok, message = Profile.RecycleCloud(player)
    player:SetAttribute("RecyclingFeedback", ok and ("Recycled " .. message .. "! +35 Coins, +20 XP") or message)
end)
Players.PlayerRemoving:Connect(function(player) cooldown[player] = nil end)
