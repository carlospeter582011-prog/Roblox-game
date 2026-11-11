-- Original native 3D Cloud Exchange kiosk. Interaction and rewards run only on server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudExchangeRules"))
local kiosk = Instance.new("Model")
kiosk.Name = "CloudExchangeKiosk3D"
local function part(name, size, pos, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Anchored = true
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = kiosk
    return p
end
local base = part("ExchangeBase", Vector3.new(9, 1, 9), Vector3.new(-22, 4, -12), Color3.fromRGB(65, 105, 155))
part("ExchangeColumn", Vector3.new(3, 5, 3), Vector3.new(-22, 7, -12), Color3.fromRGB(125, 180, 220))
local orb = part("CloudRecyclingOrb", Vector3.new(3, 3, 3), Vector3.new(-22, 11, -12), Color3.fromRGB(160, 225, 255))
orb.Shape = Enum.PartType.Ball
orb.Material = Enum.Material.Glass
orb.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Exchange 1 duplicate"
prompt.ObjectText = "Cloud Exchange"
prompt.MaxActivationDistance = 10
prompt.HoldDuration = 0.5
prompt.RequiresLineOfSight = false
prompt.Parent = base
kiosk.Parent = Workspace
local feedback = Instance.new("RemoteEvent")
feedback.Name = "CloudExchangeFeedback"
feedback.Parent = ReplicatedStorage
local cooldown = {}
prompt.Triggered:Connect(function(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 or (root.Position - base.Position).Magnitude > 13 then return end
    local now = os.clock()
    if now - (cooldown[player] or -100) < 2 then return end
    cooldown[player] = now
    local profile = ProfileStore.Get(player)
    if not profile then feedback:FireClient(player, "Profile not ready"); return end
    local ok, id, coins, remaining = Rules.apply(profile, Catalog)
    if not ok then feedback:FireClient(player, id); return end
    player:SetAttribute("CloudCoins", profile.coins)
    player:SetAttribute("SpeciesCount_" .. id, remaining)
    feedback:FireClient(player, "Exchanged " .. Catalog[id].name .. " for " .. coins .. " Coins")
end)
Players.PlayerRemoving:Connect(function(player) cooldown[player] = nil end)
