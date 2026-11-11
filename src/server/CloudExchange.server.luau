-- Physical 3D cloud exchange: turns spare specimens into useful Coins/XP.
-- The player chooses a species by interacting with a server-generated stand; no client-supplied currency.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudExchangeRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local station = Instance.new("Model")
station.Name = "CloudExchangeStation3D"
station.Parent = Workspace
local base = Instance.new("Part")
base.Name = "ExchangePedestal"
base.Anchored = true
base.Size = Vector3.new(8, 2, 8)
base.Position = Vector3.new(10, 5, -12)
base.Color = Color3.fromRGB(65, 105, 150)
base.Material = Enum.Material.SmoothPlastic
base.Parent = station
local beacon = Instance.new("Part")
beacon.Name = "ExchangeBeacon"
beacon.Anchored = true
beacon.CanCollide = false
beacon.Shape = Enum.PartType.Ball
beacon.Size = Vector3.new(3, 3, 3)
beacon.Position = base.Position + Vector3.new(0, 3, 0)
beacon.Color = Color3.fromRGB(120, 215, 230)
beacon.Material = Enum.Material.Glass
beacon.Parent = station
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Exchange 2 spare clouds"
prompt.ObjectText = "Sky Exchange"
prompt.HoldDuration = 0.6
prompt.MaxActivationDistance = 10
prompt.Parent = base
local lastUse = {}
prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 or (root.Position - base.Position).Magnitude > 13 then return end
    local now = os.clock()
    if now - (lastUse[player] or -100) < 2 then return end
    lastUse[player] = now
    local data = Profile.Get(player)
    if not data then return end
    -- Stable deterministic selection: highest eligible duplicate count, then lexicographic id.
    local selected, selectedCount
    for id, count in pairs(data.species or {}) do
        if Rules.quote(id, data.species, Catalog) and
            (not selected or count > selectedCount or (count == selectedCount and id < selected)) then
            selected, selectedCount = id, count
        end
    end
    if not selected then
        player:SetAttribute("ExchangeStatus", "Catch 3 of one species to exchange 2 duplicates")
        return
    end
    local quantity, coins, xp = Rules.quote(selected, data.species, Catalog)
    if not quantity then return end
    data.species[selected] -= quantity
    data.coins += coins
    data.xp += xp
    player:SetAttribute("SpeciesCount_" .. selected, data.species[selected])
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    player:SetAttribute("ExchangeStatus", "Exchanged 2 " .. Catalog[selected].name .. ": +" .. coins .. " Coins, +" .. xp .. " XP")
end)
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
