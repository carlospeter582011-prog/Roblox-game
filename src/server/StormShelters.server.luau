-- Native Roblox 3D storm shelters: periodic cooperative survival activity.
-- Rewards only server-observed safe time; never trusts client remotes.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("StormShelterRules"))

local folder = Instance.new("Folder")
folder.Name = "StormShelterWorld3D"
folder.Parent = Workspace
local shelters = {
    {x = -58, z = 48, radius = 14},
    {x = 58, z = 48, radius = 14},
    {x = 0, z = 72, radius = 14},
}
local function block(name, size, pos, color, material, parent)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, pos
    p.Anchored = true
    p.Material = material
    p.Color = color
    p.Parent = parent or folder
    return p
end
for i, site in ipairs(shelters) do
    local model = Instance.new("Model")
    model.Name = "StormHaven" .. i
    model.Parent = folder
    local base = block("HavenFloor", Vector3.new(24, 0.5, 24), Vector3.new(site.x, 1.3, site.z),
        Color3.fromRGB(73, 127, 165), Enum.Material.Slate, model)
    base.CanCollide = false -- Meadow itself remains walkable
    local roof = block("HavenRoof", Vector3.new(26, 1.5, 26), Vector3.new(site.x, 12, site.z),
        Color3.fromRGB(78, 148, 199), Enum.Material.Glass, model)
    roof.CanCollide = false
    for _, dx in ipairs({-11, 11}) do
        for _, dz in ipairs({-11, 11}) do
            local pillar = block("HavenPillar", Vector3.new(1.5, 10, 1.5),
                Vector3.new(site.x + dx, 6, site.z + dz), Color3.fromRGB(98, 113, 156),
                Enum.Material.Slate, model)
            pillar.CanCollide = false
        end
    end
    local light = Instance.new("PointLight")
    light.Brightness = 1.5
    light.Range = 18
    light.Color = Color3.fromRGB(121, 220, 255)
    light.Parent = roof
end

local stormVisual = block("StormCloudOverMeadow", Vector3.new(175, 8, 175),
    Vector3.new(0, 100, 0), Color3.fromRGB(67, 79, 116), Enum.Material.ForceField)
stormVisual.Shape = Enum.PartType.Ball
stormVisual.CanCollide = false
stormVisual.Transparency = 1

local progress = {}
Players.PlayerRemoving:Connect(function(player) progress[player] = nil end)

local function eligible(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and humanoid and humanoid.Health > 0 and Profile.Get(player), root
end

while true do
    stormVisual.Transparency = 1
    for _, player in Players:GetPlayers() do
        player:SetAttribute("StormStatus", "Calm skies - shelters activate soon")
        player:SetAttribute("StormSafeSeconds", 0)
    end
    task.wait(Rules.ROUND_SECONDS - Rules.STORM_SECONDS)
    table.clear(progress)
    stormVisual.Transparency = 0.55
    for second = 1, Rules.STORM_SECONDS do
        for _, player in Players:GetPlayers() do
            local valid, root = eligible(player)
            local safe = false
            if valid and root and root.Position.Y >= 0 and root.Position.Y <= 20 then
                for _, site in ipairs(shelters) do
                    if Rules.inShelter(root.Position.X, root.Position.Z, site.x, site.z, site.radius) then
                        safe = true
                        break
                    end
                end
            end
            local n, won = Rules.advance(progress[player] or 0, safe, valid ~= nil and valid ~= false)
            progress[player] = n
            player:SetAttribute("StormSafeSeconds", n)
            player:SetAttribute("StormStatus", safe and "Sheltered - earn storm survival reward" or "Storm active - find a blue haven!")
            if won and not player:GetAttribute("StormRewardedThisRound") then
                if Profile.AwardStormShelter(player) then
                    player:SetAttribute("StormRewardedThisRound", true)
                    player:SetAttribute("StormStatus", "Storm survived! +55 Coins +30 XP")
                end
            end
        end
        task.wait(1)
    end
    for _, player in Players:GetPlayers() do
        player:SetAttribute("StormRewardedThisRound", false)
    end
end
