-- Three native 3D habitats give owned elemental companions repeatable, bounded work.
-- All inventory, rewards, distance, and cooldowns are server-authoritative.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("HabitatWorkRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local root = Instance.new("Folder")
root.Name = "ElementalHabitats3D"
root.Parent = Workspace
local lastWork = {}
local stations = {
    { id = "air", position = Vector3.new(-30, 5, -16), color = Color3.fromRGB(140, 215, 255) },
    { id = "water", position = Vector3.new(-19, 5, -16), color = Color3.fromRGB(80, 155, 240) },
    { id = "nature", position = Vector3.new(-8, 5, -16), color = Color3.fromRGB(100, 205, 125) },
}
local function makePart(name, size, cf, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cf
    part.Color = color
    part.Material = Enum.Material.SmoothPlastic
    part.Anchored = true
    part.Parent = parent
    return part
end
for _, station in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = station.id .. "Habitat3D"
    model.Parent = root
    local platform = makePart("HabitatPlatform", Vector3.new(9, 1, 9),
        CFrame.new(station.position), station.color, model)
    makePart("HabitatSpire", Vector3.new(1.5, 5, 1.5),
        CFrame.new(station.position + Vector3.new(0, 3, 0)), station.color, model)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Assign companion"
    prompt.ObjectText = station.id .. " cloud habitat"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.Parent = platform
    prompt.Triggered:Connect(function(player)
        local profile = ProfileStore.Get(player)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local pivot = character and character:FindFirstChild("HumanoidRootPart")
        if not profile or not humanoid or humanoid.Health <= 0 or not pivot
            or (pivot.Position - platform.Position).Magnitude > 13 then return end
        local companion = profile.companionSpecies
        local coins, xp = Rules.reward(station.id, companion, profile.species, Catalog, profile.companionBond)
        if not coins then return end
        local now = os.clock()
        local state = lastWork[player]
        if not state then state = {}; lastWork[player] = state end
        if not Rules.ready(now, state[station.id], Rules.HABITATS[station.id].cooldown) then return end
        if type(profile.coins) ~= "number" or type(profile.xp) ~= "number"
            or profile.coins ~= profile.coins or profile.xp ~= profile.xp
            or profile.coins < 0 or profile.xp < 0
            or profile.coins > 999999900 or profile.xp > 999999900 then return end
        state[station.id] = now
        profile.coins += coins
        profile.xp += xp
        player:SetAttribute("CloudCoins", profile.coins)
        player:SetAttribute("CloudXP", profile.xp)
        player:SetAttribute("CloudLevel", Leveling.levelForXp(profile.xp))
        player:SetAttribute("LastHabitatWork", station.id)
    end)
end
Players.PlayerRemoving:Connect(function(player) lastWork[player] = nil end)
