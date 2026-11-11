-- Native 3D crafting bench: server-authoritative inventory consumption and tool unlock.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Craft = require(ReplicatedStorage:WaitForChild("CraftRules"))
local Tools = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local bench = Instance.new("Model")
bench.Name = "SkyCraftingWorkshop3D"
local base = Instance.new("Part")
base.Name = "Workbench"
base.Anchored = true
base.Size = Vector3.new(9, 2, 5)
base.Position = Vector3.new(0, 5, -20)
base.Material = Enum.Material.Wood
base.Color = Color3.fromRGB(126, 91, 65)
base.Parent = bench
bench.PrimaryPart = base
bench.Parent = Workspace
local status = Instance.new("RemoteEvent")
status.Name = "SkyCraftingResult"
status.Parent = ReplicatedStorage
local last = {}
local ordered = { "wind_lasso", "mist_gloves", "cloud_magnet" }
for i, toolId in ipairs(ordered) do
    -- Each recipe gets its own world-space pedestal: overlapping prompts on one
    -- crystal were ambiguous on touch and could hide the intended purchase.
    local pedestal = Instance.new("Part")
    pedestal.Name = "Recipe_" .. toolId
    pedestal.Anchored = true
    pedestal.CanCollide = false
    pedestal.Shape = Enum.PartType.Cylinder
    pedestal.Size = Vector3.new(1.5, 1.6, 1.5)
    pedestal.Position = base.Position + Vector3.new((i - 2) * 2.6, 2, 0)
    pedestal.Material = Enum.Material.Neon
    pedestal.Color = Color3.fromRGB(112, 215, 255)
    pedestal.Parent = bench
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Craft_" .. toolId
    prompt.ActionText = "Craft " .. Tools[toolId].name
    prompt.ObjectText = "Sky Workshop (duplicates + Coins)"
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = 10
    prompt.KeyboardKeyCode = i == 1 and Enum.KeyCode.E or (i == 2 and Enum.KeyCode.F or Enum.KeyCode.R)
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        local now = os.clock()
        if now - (last[player] or -100) < 0.8 then return end
        last[player] = now
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 or
            (root.Position - pedestal.Position).Magnitude > 13 then return end
        local data = Profile.Get(player)
        if not data then return end
        local ok, message = Craft.apply(data, toolId, Tools)
        if ok then
            player:SetAttribute("CloudCoins", data.coins)
            player:SetAttribute("OwnsTool_" .. toolId, true)
            for speciesId in pairs(Craft.Recipes[toolId].species) do
                player:SetAttribute("SpeciesCount_" .. speciesId, data.species[speciesId])
            end
        end
        status:FireClient(player, ok, message)
    end)
end
Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
