-- Server-authoritative island building. Original 3D Parts only. No client-trusted positions without validation.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local BuildingCatalog = require(ReplicatedStorage:WaitForChild("BuildingCatalog"))
local BuildingRules = require(ReplicatedStorage:WaitForChild("BuildingRules"))

local remote = Instance.new("RemoteEvent")
remote.Name = "PlaceBuilding"
remote.Parent = ReplicatedStorage

local function createBuildingModel(buildingId, position)
    local model = Instance.new("Model")
    model.Name = "Building_" .. buildingId
    local part = Instance.new("Part")
    part.Name = "Base"
    part.Anchored = true
    part.CanCollide = true
    part.Size = Vector3.new(2, 2, 2)
    part.Position = Vector3.new(position.x, position.y, position.z)
    part.Material = Enum.Material.SmoothPlastic
    if buildingId == "lantern" then
        part.Color = Color3.fromRGB(255, 220, 100)
        part.Material = Enum.Material.Neon
        part.Size = Vector3.new(1.5, 3, 1.5)
    elseif buildingId == "flower" then
        part.Color = Color3.fromRGB(200, 100, 150)
        part.Size = Vector3.new(3, 0.5, 3)
    elseif buildingId == "crystal" then
        part.Color = Color3.fromRGB(150, 200, 255)
        part.Material = Enum.Material.Glass
        part.Size = Vector3.new(1.5, 2.5, 1.5)
    elseif buildingId == "bench" then
        part.Color = Color3.fromRGB(120, 80, 40)
        part.Size = Vector3.new(4, 1.5, 1.5)
    end
    part.Parent = model
    model.Parent = workspace
    return model
end

local function spawnPlayerBuildings(player)
    local data = Profile.Get(player)
    if not data or not data.buildings then return end
    for _, b in ipairs(data.buildings) do
        if BuildingCatalog[b.id] then
            createBuildingModel(b.id, b)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    task.delay(2, function() -- wait for profile
        if player.Parent then spawnPlayerBuildings(player) end
    end)
end)

remote.OnServerEvent:Connect(function(player, buildingId, pos)
    if type(buildingId) ~= "string" or type(pos) ~= "table" then return end
    local data = Profile.Get(player)
    if not data then return end
    local ok, itemOrErr = BuildingRules.place(BuildingCatalog, data, buildingId, pos)
    if ok then
        player:SetAttribute("CloudCoins", data.coins)
        createBuildingModel(buildingId, pos)
        Profile.Save(player)
    else
        -- Optional feedback remote could be added; for now silent fail is safer than leaking
        warn("Building place failed for", player.UserId, itemOrErr)
    end
end)

-- Note: full persistence and rejoin spawn handled above. Runtime verification pending.
