-- Original native 3D evolution altar; persistent inventory uses the existing ProfileStore session.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Rules = require(ReplicatedStorage:WaitForChild("CloudEvolutionRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Profile = require(ServerScriptService:WaitForChild("ProfileStore"))
local altar = Instance.new("Model")
altar.Name = "CloudEvolutionAltar"
altar.Parent = workspace
local function part(name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Color = color
    p.Material = material
    p.Parent = altar
    return p
end
local base = part("EvolutionDais", Vector3.new(24, 2, 18), Vector3.new(-36, 4, 15), Color3.fromRGB(93, 76, 149), Enum.Material.Slate)
for i, recipe in ipairs(Rules.Recipes) do
    local column = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    local x = -43 + column * 7
    local z = 11 + row * 8
    local pillar = part(recipe.id, Vector3.new(3, 4, 3), Vector3.new(x, 7, z), Color3.fromRGB(135, 193, 237), Enum.Material.Neon)
    pillar.CanCollide = true
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Evolve " .. recipe.source .. " to " .. recipe.result
    prompt.ObjectText = recipe.coins .. " Coins | Bond " .. recipe.bond
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.6
    prompt.RequiresLineOfSight = false
    prompt.Parent = pillar
    local cooldown = {}
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player:GetAttribute("ProfileReady") then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root then return end
        if (root.Position - pillar.Position).Magnitude > 13 then return end
        local now = os.clock()
        if cooldown[player.UserId] and now - cooldown[player.UserId] < 2 then return end
        local data = Profile.Get(player)
        if not data then return end
        local ok, result = Rules.apply(data, recipe, Catalog)
        if not ok then
            player:SetAttribute("EvolutionStatus", result)
            return
        end
        cooldown[player.UserId] = now
        player:SetAttribute("CloudCoins", data.coins)
        player:SetAttribute("SpeciesCount_" .. recipe.source, data.species[recipe.source])
        player:SetAttribute("SpeciesCount_" .. recipe.result, data.species[recipe.result])
        player:SetAttribute("EvolutionStatus", "Evolved into " .. Catalog[result].name)
        -- Profile.Save is best-effort; existing autosave / release pipeline remains authoritative.
        task.spawn(Profile.Save, player)
    end)
    Players.PlayerRemoving:Connect(function(player) cooldown[player.UserId] = nil end)
end
