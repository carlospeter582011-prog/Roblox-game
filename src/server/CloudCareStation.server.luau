-- Original 3D companion feeding station. Server-authoritative coin sink that advances existing companion bond.
-- Uses native Roblox Parts and ProximityPrompt. No new DataStore fields; mutates existing profile data then saves.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Care = require(ReplicatedStorage:WaitForChild("CloudCareRules"))
local CompanionRules = require(ReplicatedStorage:WaitForChild("CompanionRules"))
local CloudCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))

local folder = Instance.new("Folder")
folder.Name = "CloudCareStations3D"
folder.Parent = Workspace

local lastFeed = {} -- [player] = os.clock()

local function createStation()
    local model = Instance.new("Model")
    model.Name = "SkyFeedingAltar3D"
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "AltarBase"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(1, 8, 8)
    base.Position = Vector3.new(-20, 1.5, -35)
    base.Orientation = Vector3.new(0, 0, 90)
    base.Anchored = true
    base.CanCollide = true
    base.Color = Color3.fromRGB(140, 110, 180)
    base.Material = Enum.Material.Marble
    base.Parent = model
    local bowl = Instance.new("Part")
    bowl.Name = "FeedingBowl"
    bowl.Shape = Enum.PartType.Ball
    bowl.Size = Vector3.new(4, 2, 4)
    bowl.Position = Vector3.new(-20, 4, -35)
    bowl.Anchored = true
    bowl.CanCollide = false
    bowl.Color = Color3.fromRGB(200, 180, 255)
    bowl.Material = Enum.Material.Neon
    bowl.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "FeedCompanion"
    prompt.ActionText = "Feed Companion"
    prompt.ObjectText = "Sky Altar"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = bowl
    prompt.Triggered:Connect(function(player)
        if not player or not player.Parent then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - bowl.Position).Magnitude > 14 then return end
        local data = Profile.Get(player)
        if not data then
            player:SetAttribute("CareFeedback", "Profile not ready")
            return
        end
        local species = data.companionSpecies
        if not CompanionRules.owned(species, data.species, CloudCatalog) then
            player:SetAttribute("CareFeedback", "Equip a caught companion first")
            return
        end
        local now = os.clock()
        local ok, reason = Care.canFeed(data.coins, lastFeed[player], now)
        if not ok then
            player:SetAttribute("CareFeedback", reason or "Cannot feed")
            return
        end
        data.coins -= Care.FEED_COST
        data.companionBond = data.companionBond or {}
        data.companionBond[species] = Care.applyFeed(data.companionBond[species])
        lastFeed[player] = now
        player:SetAttribute("CloudCoins", data.coins)
        player:SetAttribute("CompanionBondPoints", data.companionBond[species])
        player:SetAttribute("CompanionBondLevel", CompanionRules.bondLevel(data.companionBond[species]))
        player:SetAttribute("CareFeedback", "Fed " .. (CloudCatalog[species].name or species) .. "! Bond +" .. Care.BOND_GAIN)
        Profile.Save(player)
    end)
end

createStation()

Players.PlayerRemoving:Connect(function(player)
    lastFeed[player] = nil
end)
