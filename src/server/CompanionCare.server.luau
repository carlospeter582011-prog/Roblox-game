-- Original 3D cloud care fountain. Player spends Coins to bond with an owned companion.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CompanionCareRules"))
local Companion = require(ReplicatedStorage:WaitForChild("CompanionRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))

local model = Instance.new("Model")
model.Name = "CloudCareFountain3D"
model.Parent = Workspace
local function piece(name, size, position, material, color, shape)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, position
    p.Anchored, p.CanCollide = true, false
    p.Material, p.Color = material, color
    if shape then p.Shape = shape end
    p.Parent = model
    return p
end
local base = piece("FountainBase", Vector3.new(9, 1, 9), Vector3.new(-34, 1.5, 23),
    Enum.Material.Slate, Color3.fromRGB(103, 125, 161), Enum.PartType.Cylinder)
piece("CloudOrb", Vector3.new(4, 4, 4), Vector3.new(-34, 5, 23),
    Enum.Material.Neon, Color3.fromRGB(177, 228, 255), Enum.PartType.Ball)
for _, offset in ipairs({Vector3.new(-3, 0, 0), Vector3.new(3, 0, 0),
    Vector3.new(0, 0, -3), Vector3.new(0, 0, 3)}) do
    piece("CareCrystal", Vector3.new(1, 2.5, 1), Vector3.new(-34, 3, 23) + offset,
        Enum.Material.Glass, Color3.fromRGB(132, 213, 245))
end
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "CareForCompanion"
prompt.ActionText = "Care: 30 Coins"
prompt.ObjectText = "Cloud Care Fountain"
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = base

local lastCare = {}
Players.PlayerRemoving:Connect(function(player) lastCare[player.UserId] = nil end)
prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") or not player.Parent
        or player:GetAttribute("ProfileReady") ~= true then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root
        or (root.Position - base.Position).Magnitude > 14 then return end
    local data = Profile.Get(player)
    local now = os.time()
    local transaction, reason = Rules.preview(data, Catalog, now, lastCare[player.UserId])
    if not transaction then
        player:SetAttribute("CloudCareFeedback", reason or "Unavailable")
        return
    end
    -- No yielding between preview and apply; cooldown is server-owned.
    if not Rules.apply(data, transaction) then return end
    lastCare[player.UserId] = now
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CompanionBondPoints", transaction.bond)
    player:SetAttribute("CompanionBondLevel", Companion.bondLevel(transaction.bond))
    player:SetAttribute("CloudCareFeedback", "Companion cared for! +5 bond")
end)
