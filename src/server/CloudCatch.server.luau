-- Initial playable vertical slice: spawns and validates cloud catches; progress lives in ProfileStore.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local toolCatalog = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local CatchRules = require(ReplicatedStorage:WaitForChild("CatchRules"))
local SpawnRules = require(ReplicatedStorage:WaitForChild("SpawnRules"))
local Mutations = require(ReplicatedStorage:WaitForChild("Mutations"))
local CloudVisuals = require(ReplicatedStorage:WaitForChild("CloudVisuals"))
local remote = Instance.new("RemoteEvent")
remote.Name = "RequestCloudCatch"
remote.Parent = ReplicatedStorage
local equipRemote = Instance.new("RemoteEvent")
equipRemote.Name = "EquipCatchTool"
equipRemote.Parent = ReplicatedStorage
equipRemote.OnServerEvent:Connect(function(player,toolId)
    local profile=ProfileStore.Get(player)
    if not profile or not CatchRules.canEquip(toolId,profile.captures,toolCatalog) then return end
    player:SetAttribute("EquippedCatchTool",toolId)
end)
local cloudFolder = Instance.new("Folder")
cloudFolder.Name = "CatchableClouds"
cloudFolder.Parent = Workspace
local active = {}
local lastAttempt = {}
local nextId = 0
local visuals = {}
local function spawnCloud()
    nextId += 1
    local id = tostring(nextId)
    local speciesId = SpawnRules.rollSpecies(catalog, math.random) or "breeze"
    local species = catalog[speciesId]
    local mutationId = Mutations.roll(math.random)
    local tint = Color3.fromRGB(species.colorRGB[1], species.colorRGB[2], species.colorRGB[3])
    if mutationId == "golden" then tint = Color3.fromRGB(255, 215, 0) end
    if mutationId == "rainbow" then tint = Color3.fromRGB(255, 100, 255) end
    if mutationId == "electric" then tint = Color3.fromRGB(100, 200, 255) end
    local cloud = Instance.new("Part")
    cloud.Name = speciesId .. "Cloud_" .. id
    cloud.Shape = Enum.PartType.Ball
    cloud.Size = Vector3.new(5, 3, 4)
    cloud.Color = tint
    cloud.Material = Enum.Material.Neon
    cloud.Anchored = true
    cloud.CanCollide = false
    cloud.Transparency = 1
    cloud.Position = Vector3.new(math.random(-28, 28), 9, math.random(-28, 28))
    cloud:SetAttribute("CloudId", id)
    cloud:SetAttribute("SpeciesId", speciesId)
    if mutationId then cloud:SetAttribute("MutationId", mutationId) end
    cloud.Parent = cloudFolder
    local model = CloudVisuals.createCloudVisual(cloudFolder, cloud.Position, tint, speciesId)
    model.Name = speciesId .. "CloudVisual_" .. id
    local glow = Instance.new("PointLight")
    glow.Color = tint
    glow.Brightness = 1
    glow.Range = 12
    glow.Parent = cloud
    visuals[id] = model
    active[id] = cloud
end
for _ = 1, 6 do spawnCloud() end
remote.OnServerEvent:Connect(function(player, cloudId)
    if typeof(cloudId) ~= "string" or #cloudId > 24 then return end
    local now = os.clock()
    local profile=ProfileStore.Get(player)
    if not profile then
        remote:FireClient(player,false,"Profile unavailable. Please rejoin.")
        return
    end
    local equipped=player:GetAttribute("EquippedCatchTool")
    local tool,toolId=CatchRules.resolveTool(equipped,profile.captures,toolCatalog)
    if equipped~=nil and equipped~=toolId then
        player:SetAttribute("EquippedCatchTool",toolId)
    end
    if now - (lastAttempt[player] or -100) < tool.cooldown then return end
    lastAttempt[player] = now
    local cloud = active[cloudId]
    if not cloud or not cloud.Parent then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local species = catalog[cloud:GetAttribute("SpeciesId")]
    if not species then return end
    if not CatchRules.isInRange((root.Position - cloud.Position).Magnitude, species, tool) then
        remote:FireClient(player, false, "Move closer to the cloud!")
        return
    end
    active[cloudId] = nil
    local mut = cloud:GetAttribute("MutationId")
    local trackId = Mutations.key(species.id, mut)
    local baseCoins = CatchRules.coinReward(species, tool)
    local coins = Mutations.bonusCoins(baseCoins, mut)
    if not ProfileStore.AddCatch(player, trackId, coins) then
        active[cloudId] = cloud
        remote:FireClient(player, false, "Profile unavailable. Please rejoin.")
        return
    end
    cloud:Destroy()
    if visuals[cloudId] then visuals[cloudId]:Destroy(); visuals[cloudId] = nil end
    local label = mut and (Mutations[mut].name .. " " .. species.name) or species.name
    remote:FireClient(player, true, "Caught a " .. label .. "!")
    task.delay(5, spawnCloud)
end)
Players.PlayerRemoving:Connect(function(player)
    lastAttempt[player] = nil
end)

task.spawn(function()
    local phase = 0
    while true do
        task.wait(0.12)
        phase += 0.12
        for id, model in pairs(visuals) do
            local cloud = active[id]
            if cloud and cloud.Parent and model.Parent then
                local bob = Vector3.new(0, math.sin(phase + tonumber(id))*0.5, 0)
                for _, part in ipairs(model:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Position = cloud.Position + bob
                    end
                end
            end
        end
    end
end)
