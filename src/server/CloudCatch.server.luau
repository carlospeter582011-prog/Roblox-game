-- Initial playable vertical slice; session-only inventory (persistence is a later milestone).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local remote = Instance.new("RemoteEvent")
remote.Name = "RequestCloudCatch"
remote.Parent = ReplicatedStorage
local cloudFolder = Instance.new("Folder")
cloudFolder.Name = "CatchableClouds"
cloudFolder.Parent = Workspace
local active = {}
local inventory = {}
local lastAttempt = {}
local nextId = 0
local function spawnCloud()
    nextId += 1
    local id = tostring(nextId)
    local cloud = Instance.new("Part")
    cloud.Name = "BreezeCloud_" .. id
    cloud.Shape = Enum.PartType.Ball
    cloud.Size = Vector3.new(5, 3, 4)
    cloud.Color = Color3.fromRGB(211, 238, 255)
    cloud.Material = Enum.Material.Neon
    cloud.Anchored = true
    cloud.CanCollide = false
    cloud.Position = Vector3.new(math.random(-28, 28), 9, math.random(-28, 28))
    cloud:SetAttribute("CloudId", id)
    cloud:SetAttribute("SpeciesId", "breeze")
    cloud.Parent = cloudFolder
    active[id] = cloud
end
for _ = 1, 6 do spawnCloud() end
remote.OnServerEvent:Connect(function(player, cloudId)
    if typeof(cloudId) ~= "string" or #cloudId > 24 then return end
    local now = os.clock()
    if now - (lastAttempt[player] or -100) < 0.5 then return end
    lastAttempt[player] = now
    local cloud = active[cloudId]
    if not cloud or not cloud.Parent then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local species = catalog[cloud:GetAttribute("SpeciesId")]
    if not species then return end
    if (root.Position - cloud.Position).Magnitude > species.baseCatchRadius then
        remote:FireClient(player, false, "Move closer to the cloud!")
        return
    end
    active[cloudId] = nil
    cloud:Destroy()
    inventory[player] = (inventory[player] or 0) + 1
    player:SetAttribute("CloudCount", inventory[player])
    remote:FireClient(player, true, "Caught a Breeze Cloud!")
    task.delay(5, spawnCloud)
end)
Players.PlayerRemoving:Connect(function(player)
    inventory[player] = nil
    lastAttempt[player] = nil
end)
