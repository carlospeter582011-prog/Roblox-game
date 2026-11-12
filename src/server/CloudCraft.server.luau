-- 3D Cloud Crafting Workshop: original native Roblox Parts/Model with ProximityPrompt.
-- Server-authoritative: checks profile readiness, character health, distance, cooldown and pure CraftRules.
-- No external assets, Mesh IDs or Canvas world geometry. ScreenGui not used here.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CraftRules = require(ReplicatedStorage:WaitForChild("CraftRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))

local STATION_POSITION = Vector3.new(25, 5, 15)
local INTERACT_RANGE = 12
local COOLDOWN = 8
local lastUse = {}

local function createWorkshop()
    local model = Instance.new("Model")
    model.Name = "CloudCraftingWorkshop"
    model.Parent = Workspace

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(10, 1, 10)
    base.Position = STATION_POSITION
    base.Anchored = true
    base.Material = Enum.Material.Marble
    base.Color = Color3.fromRGB(200, 220, 255)
    base.Parent = model

    local pillar = Instance.new("Part")
    pillar.Name = "Pillar"
    pillar.Size = Vector3.new(2, 6, 2)
    pillar.Position = STATION_POSITION + Vector3.new(0, 3.5, 0)
    pillar.Anchored = true
    pillar.Material = Enum.Material.Neon
    pillar.Color = Color3.fromRGB(150, 200, 255)
    pillar.Parent = model

    local orb = Instance.new("Part")
    orb.Name = "EssenceOrb"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(3, 3, 3)
    orb.Position = STATION_POSITION + Vector3.new(0, 7, 0)
    orb.Anchored = true
    orb.Material = Enum.Material.Neon
    orb.Color = Color3.fromRGB(180, 140, 255)
    orb.Parent = model

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Craft"
    prompt.ObjectText = "Cloud Workshop"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = INTERACT_RANGE
    prompt.Parent = orb

    prompt.Triggered:Connect(function(player)
        if not player or not player.Character then return end
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - orb.Position).Magnitude > INTERACT_RANGE + 2 then return end
        local now = os.clock()
        if lastUse[player.UserId] and now - lastUse[player.UserId] < COOLDOWN then return end
        lastUse[player.UserId] = now

        local data = ProfileStore.Get(player)
        if not data then return end

        -- Prefer the first available recipe the player can afford.
        local chosen = nil
        for id in pairs(CraftRules.RECIPES) do
            local can, _ = CraftRules.canCraft(id, data)
            if can then
                chosen = id
                break
            end
        end
        if not chosen then
            -- Feedback via attribute for client HUD if desired.
            player:SetAttribute("CraftMessage", "Not enough surplus clouds or coins")
            return
        end

        local ok, recipe = CraftRules.applyCraft(chosen, data)
        if ok then
            player:SetAttribute("CloudCoins", data.coins)
            player:SetAttribute("Crafted_" .. chosen, data.crafted[chosen])
            player:SetAttribute("CraftMessage", "Crafted " .. recipe.name)
            -- Apply simple temporary effect via attribute (client or other systems can read).
            if recipe.effect == "speed_boost" then
                player:SetAttribute("SpeedBoostUntil", os.time() + recipe.duration)
                player:SetAttribute("SpeedBoostAmount", recipe.magnitude)
            end
            -- Other effects can be handled by catch rules reading charges.
        end
    end)

    return model
end

createWorkshop()

Players.PlayerRemoving:Connect(function(player)
    lastUse[player.UserId] = nil
end)
