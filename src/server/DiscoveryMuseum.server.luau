-- Sky Museum: shared physical gallery, individual server-authoritative discovery progress.
-- All pedestals are actual Roblox 3D Parts; feedback is private to the interacting player.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Gallery = require(ReplicatedStorage:WaitForChild("DiscoveryGalleryRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local museum = Instance.new("Model")
museum.Name = "SkyDiscoveryMuseum3D"
museum.Parent = Workspace
local cooldowns = {}
local function part(name, size, pos, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = true
    p.Material = Enum.Material.SmoothPlastic
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Parent = museum
    return p
end
-- Museum sits on the starter meadow and does not replace any world art with a GUI.
local base = part("MuseumWalkway", Vector3.new(38, 1, 12), Vector3.new(0, 3, 43), Color3.fromRGB(102, 150, 178))
base.Material = Enum.Material.Slate
for i, rarity in ipairs(Gallery.tiers) do
    local x = -15 + (i - 1) * 5
    local pillar = part(rarity .. "DiscoveryPillar", Vector3.new(3, 4, 3),
        Vector3.new(x, 5.5, 43), Color3.fromRGB(105 + i * 12, 140, 215 - i * 12))
    local orb = part(rarity .. "CloudOrb", Vector3.new(2.5, 2.5, 2.5),
        Vector3.new(x, 8.7, 43), Color3.fromRGB(185, 220, 250))
    orb.Shape = Enum.PartType.Ball
    orb.Material = Enum.Material.Glass
    orb.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "InspectDiscoveryTier"
    prompt.ActionText = "Inspect Collection"
    prompt.ObjectText = rarity .. " Clouds"
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 9
    prompt.RequiresLineOfSight = false
    prompt.Parent = pillar
    prompt.Triggered:Connect(function(player)
        local now = os.clock()
        if now < (cooldowns[player] or 0) then return end
        local profile = ProfileStore.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - pillar.Position).Magnitude > 12 then return end
        cooldowns[player] = now + 0.8
        local found, total, missing = Gallery.summary(Catalog, profile.species or {}, rarity)
        local hint = missing and Catalog[missing] and Catalog[missing].name or "All discovered!"
        player:SetAttribute("MuseumDiscoveryFeedback",
            rarity .. " collection: " .. found .. "/" .. total .. " | Next discovery: " .. hint)
        player:SetAttribute("MuseumDiscoveryTier", rarity)
        player:SetAttribute("MuseumDiscoveryCount", found)
        player:SetAttribute("MuseumDiscoveryTotal", total)
    end)
end
Players.PlayerRemoving:Connect(function(player)
    cooldowns[player] = nil
end)
