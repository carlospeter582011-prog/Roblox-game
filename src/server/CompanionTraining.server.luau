-- Original 3D training station: a repeatable earned Coins sink for companion bond.
-- Server owns the profile, prices, position and cooldown; no client remotes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CompanionTrainingRules"))
local CompanionRules = require(ReplicatedStorage:WaitForChild("CompanionRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))

local model = Instance.new("Model")
model.Name = "CompanionTrainingSanctuary3D"
model.Parent = Workspace
local function part(name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.CanCollide = name == "TrainingPlatform3D"
    p.Parent = model
    return p
end
part("TrainingPlatform3D", Vector3.new(10, 1, 10), Vector3.new(-27, 2, 22),
    Color3.fromRGB(85, 136, 170), Enum.Material.Slate)
for _, offset in ipairs({-3, 3}) do
    part("SanctuaryPillar3D", Vector3.new(1, 5, 1), Vector3.new(-27 + offset, 5, 22),
        Color3.fromRGB(150, 188, 218), Enum.Material.SmoothPlastic)
end
local orb = part("BondOrb3D", Vector3.new(3, 3, 3), Vector3.new(-27, 5, 22),
    Color3.fromRGB(105, 195, 230), Enum.Material.Glass)
orb.Shape = Enum.PartType.Ball
orb.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Train Companion"
prompt.ObjectText = "Sky Sanctuary (Coins)"
prompt.HoldDuration = 0.6
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false
prompt.Parent = orb

local nextAllowed = {}
local busy = {}
prompt.Triggered:Connect(function(player)
    if busy[player] then return end
    busy[player] = true
    -- No yields in the transaction: duplicate triggers cannot double-spend.
    local data = ProfileStore.Get(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local now = os.clock()
    if data and root and humanoid and humanoid.Health > 0
        and (root.Position - orb.Position).Magnitude <= 13 then
        if now < (nextAllowed[player] or 0) then
            player:SetAttribute("TrainingFeedback", "Sanctuary resting; try again shortly")
        else
            local id = data.companionSpecies
            local result, reason = Rules.train(data.coins, id, data.species,
                data.companionBond, Catalog)
            if result then
                data.coins = result.coins
                data.companionBond[id] = result.points
                nextAllowed[player] = now + Rules.COOLDOWN
                player:SetAttribute("CloudCoins", result.coins)
                player:SetAttribute("CompanionBondPoints", result.points)
                player:SetAttribute("CompanionBondLevel", CompanionRules.bondLevel(result.points))
                player:SetAttribute("TrainingFeedback", "Training complete: +" ..
                    Rules.TRAINING_GAIN .. " Bond (-" .. result.cost .. " Coins)")
            else
                player:SetAttribute("TrainingFeedback", reason or "Training unavailable")
            end
        end
    end
    busy[player] = nil
end)
Players.PlayerRemoving:Connect(function(player)
    busy[player] = nil
    nextAllowed[player] = nil
end)
