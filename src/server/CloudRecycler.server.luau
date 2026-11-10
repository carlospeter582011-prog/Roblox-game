-- Original 3D recycler: gives duplicate clouds a useful, non-Robux economy sink.
-- Native ProximityPrompt works on touch, keyboard and gamepad; all rewards are server-owned.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudRecyclingRules"))
local model = Instance.new("Model")
model.Name = "SkyCloudRecycler3D"
model.Parent = workspace
local function makePart(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.CanTouch = false
    p.Color = color
    p.Material = material
    p.Parent = model
    return p
end
makePart("RecyclerBase", Vector3.new(9, 1, 9), Vector3.new(24, 1.2, 14),
    Color3.fromRGB(75, 94, 130), Enum.Material.Slate)
makePart("RecyclerColumn", Vector3.new(3, 5, 3), Vector3.new(24, 4.1, 14),
    Color3.fromRGB(96, 142, 178), Enum.Material.Metal)
local core = makePart("RecyclerCloudCore", Vector3.new(4, 4, 4), Vector3.new(24, 7.6, 14),
    Color3.fromRGB(128, 232, 244), Enum.Material.Neon)
core.Shape = Enum.PartType.Ball
core.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Recycle duplicate"
prompt.ObjectText = "Sky Cloud Recycler"
prompt.HoldDuration = 0.4
prompt.MaxActivationDistance = 11
prompt.RequiresLineOfSight = false
prompt.Parent = core
local lastUse = {}
local function chooseDuplicate(species)
    local ids = {}
    for id in pairs(species or {}) do
        if Rules.quote(id, species, Catalog) then table.insert(ids, id) end
    end
    table.sort(ids)
    return ids[1]
end
prompt.Triggered:Connect(function(player)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then return end
    if (root.Position - core.Position).Magnitude > 13 then return end
    local data = Profile.Get(player)
    if not data or player:GetAttribute("ProfileReady") ~= true then return end
    local now = os.clock()
    if lastUse[player] and now - lastUse[player] < 2 then return end
    lastUse[player] = now
    local id = chooseDuplicate(data.species)
    if not id then
        player:SetAttribute("RecyclerResult", "Catch 3 of one species to recycle a duplicate")
        return
    end
    local ok, message = Profile.RecycleCloud(player, id)
    player:SetAttribute("RecyclerResult", ok and ("Recycled " .. id .. ": " .. message) or message)
end)
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
