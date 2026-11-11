-- Shared physical 3D habitat station; purchases and production are per-player and server-owned.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("HabitatProductionRules"))
local model = Instance.new("Model")
model.Name = "MeadowHabitatProduction3D"
model.Parent = Workspace
local function block(name, size, offset, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Anchored = true
    p.CanCollide = true
    p.Position = Vector3.new(36, 1, 38) + offset
    p.Color = color
    p.Material = material
    p.Parent = model
    return p
end
local base = block("HabitatPlatform", Vector3.new(16, 1, 14), Vector3.new(0, 0, 0),
    Color3.fromRGB(94, 143, 111), Enum.Material.WoodPlanks)
for _, x in ipairs({-5, 5}) do
    block("HabitatPost", Vector3.new(1, 8, 1), Vector3.new(x, 4, 0),
        Color3.fromRGB(120, 94, 73), Enum.Material.Wood)
end
block("HabitatRoof", Vector3.new(14, 1, 12), Vector3.new(0, 8, 0),
    Color3.fromRGB(133, 203, 173), Enum.Material.Grass)
local orb = block("HabitatHeart", Vector3.new(4, 4, 4), Vector3.new(0, 4, 0),
    Color3.fromRGB(180, 228, 252), Enum.Material.Neon)
orb.Shape = Enum.PartType.Ball
orb.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "HabitatBuyOrCollect"
prompt.ActionText = "Buy / Collect"
prompt.ObjectText = "Cloud Habitat"
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = base
local function eligible(player)
    if not player or not player:IsA("Player") or not player.Parent then return false end
    if player:GetAttribute("ProfileReady") ~= true then return false end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local human = character and character:FindFirstChildOfClass("Humanoid")
    return root and human and human.Health > 0 and (root.Position - base.Position).Magnitude <= 14
end
prompt.Triggered:Connect(function(player)
    if not eligible(player) then return end
    local data = Profile.Get(player)
    if not data then return end
    local now = os.time()
    local ok, result
    if data.habitatOwned then
        ok, result = Rules.claim(data, now)
        player:SetAttribute("HabitatFeedback", ok and ("Collected " .. result .. " Coins") or "No production ready yet")
    else
        ok, result = Rules.buy(data, now)
        player:SetAttribute("HabitatFeedback", ok and "Habitat unlocked! Come back to collect Coins" or ("Habitat: " .. tostring(result)))
    end
    if ok then
        player:SetAttribute("CloudCoins", data.coins)
        player:SetAttribute("HabitatOwned", data.habitatOwned)
        player:SetAttribute("HabitatLastClaim", data.habitatLastClaim)
    end
end)
Players.PlayerAdded:Connect(function(player)
    task.spawn(function()
        while player.Parent and player:GetAttribute("ProfileReady") ~= true do task.wait(0.5) end
        local data = Profile.Get(player)
        if data then
            player:SetAttribute("HabitatOwned", data.habitatOwned == true)
            player:SetAttribute("HabitatLastClaim", data.habitatLastClaim or 0)
        end
    end)
end)
