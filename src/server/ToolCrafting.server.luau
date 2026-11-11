-- Original 3D crafting workbench: server-authoritative, no client-supplied recipes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("ToolCraftRules"))
local Tools = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local station = Instance.new("Model")
station.Name = "CloudToolCraftingStation"
station.Parent = workspace
local base = Instance.new("Part")
base.Name = "Workbench"
base.Size = Vector3.new(7, 2, 5)
base.Position = Vector3.new(15, 6, 12)
base.Anchored = true
base.Material = Enum.Material.Slate
base.Color = Color3.fromRGB(100, 145, 195)
base.Parent = station
local orb = Instance.new("Part")
orb.Name = "CraftingOrb"
orb.Shape = Enum.PartType.Ball
orb.Size = Vector3.new(2, 2, 2)
orb.Position = base.Position + Vector3.new(0, 2.1, 0)
orb.Anchored = true
orb.CanCollide = false
orb.Material = Enum.Material.Neon
orb.Color = Color3.fromRGB(160, 235, 255)
orb.Parent = station
local cooldown = {}
local recipeOrder = {"wind_lasso", "mist_gloves", "cloud_magnet", "golden_net", "storm_vacuum"}
for i, id in ipairs(recipeOrder) do
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Craft_" .. id
    prompt.ActionText = "Craft " .. Tools[id].name
    prompt.ObjectText = "Cloud Workshop (" .. Rules.Recipes[id].coins .. " Coins + spare clouds)"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        local now = os.clock()
        if cooldown[player] and now - cooldown[player] < 1 then return end
        cooldown[player] = now
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid or humanoid.Health <= 0 or (root.Position - base.Position).Magnitude > 13 then return end
        if player:GetAttribute("ProfileReady") ~= true then return end
        local data = Profile.Get(player)
        local ok, message = Rules.craft(data, id, Tools)
        if not ok then
            player:SetAttribute("CraftingMessage", message)
            return
        end
        player:SetAttribute("CloudCoins", data.coins)
        player:SetAttribute("OwnsTool_" .. id, true)
        for speciesId in pairs(Rules.Recipes[id].ingredients) do
            player:SetAttribute("SpeciesCount_" .. speciesId, data.species[speciesId])
        end
        player:SetAttribute("CraftingMessage", message)
    end)
end
Players.PlayerRemoving:Connect(function(player) cooldown[player] = nil end)
