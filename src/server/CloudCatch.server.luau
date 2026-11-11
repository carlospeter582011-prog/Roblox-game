-- Initial playable vertical slice: spawns and validates cloud catches; progress lives in ProfileStore.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local toolCatalog = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local CatchRules = require(ReplicatedStorage:WaitForChild("CatchRules"))
local SpawnRules = require(ReplicatedStorage:WaitForChild("SpawnRules"))
local Mutations = require(ReplicatedStorage:WaitForChild("Mutations"))
local CompanionRules = require(ReplicatedStorage:WaitForChild("CompanionRules"))
local CloudVisuals = require(ReplicatedStorage:WaitForChild("CloudVisuals"))
local remote = Instance.new("RemoteEvent")
remote.Name = "RequestCloudCatch"
remote.Parent = ReplicatedStorage
local purchaseRemote = Instance.new("RemoteEvent")
purchaseRemote.Name = "PurchaseCatchTool"
purchaseRemote.Parent = ReplicatedStorage
purchaseRemote.OnServerEvent:Connect(function(player, toolId)
    if typeof(toolId) ~= "string" or #toolId > 40 then return end
    local ok, message = ProfileStore.BuyTool(player, toolId)
    purchaseRemote:FireClient(player, ok, message)
end)
local trainingRemote = Instance.new("RemoteEvent")
trainingRemote.Name = "PurchaseRangeTraining"
trainingRemote.Parent = ReplicatedStorage
trainingRemote.OnServerEvent:Connect(function(player)
    local ok, message = ProfileStore.BuyRangeTraining(player)
    trainingRemote:FireClient(player, ok, message)
end)
local equipRemote = Instance.new("RemoteEvent")
equipRemote.Name = "EquipCatchTool"
equipRemote.Parent = ReplicatedStorage
equipRemote.OnServerEvent:Connect(function(player,toolId)
    local profile=ProfileStore.Get(player)
    if not profile or not CatchRules.canEquip(toolId,profile.captures,toolCatalog) then return end
    if toolId ~= "starter_net" and not (profile.ownedTools and profile.ownedTools[toolId]) then return end
    player:SetAttribute("EquippedCatchTool",toolId)
end)
local cloudFolder = Instance.new("Folder")
cloudFolder.Name = "CatchableClouds"
cloudFolder.Parent = Workspace
local active = {}
local lastAttempt = {}
local nextId = 0
local visuals = {}
-- Brief original 3D catch feedback, visible to nearby players without a 2D world stand-in.
-- No external asset IDs, textures or unbounded permanent parts.
local function showCatchPulse(position, color, isMagnet)
    local pulse = Instance.new("Part")
    pulse.Name = isMagnet and "MagnetCatchPulse3D" or "CloudCatchPulse3D"
    pulse.Shape = Enum.PartType.Ball
    pulse.Anchored = true
    pulse.CanCollide = false
    pulse.CanTouch = false
    pulse.CanQuery = false
    pulse.Material = Enum.Material.ForceField
    pulse.Color = isMagnet and Color3.fromRGB(115, 220, 235) or color
    pulse.Transparency = 0.35
    pulse.Size = Vector3.new(1, 1, 1)
    pulse.Position = position
    pulse.Parent = cloudFolder
    local tween = TweenService:Create(pulse, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(7, 7, 7),
        Transparency = 1,
    })
    tween:Play()
    Debris:AddItem(pulse, 0.45)
end

local function spawnCloud()
    nextId += 1
    local id = tostring(nextId)
    local region = SpawnRules.regionBounds(nextId)
    local speciesId = SpawnRules.rollSpecies(catalog, math.random, region.element) or "breeze"
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
    cloud.Position = Vector3.new(
        math.random(region.minX, region.maxX), 9,
        math.random(region.minZ, region.maxZ))
    cloud:SetAttribute("SpawnRegion", region.name)
    cloud:SetAttribute("CloudId", id)
    cloud:SetAttribute("SpeciesId", speciesId)
    if mutationId then cloud:SetAttribute("MutationId", mutationId) end
    cloud.Parent = cloudFolder
    local model = CloudVisuals.createCloudVisual(cloudFolder, cloud.Position, tint, speciesId)
    model.Name = speciesId .. "CloudVisual_" .. id
    -- Remember each part's offset from the cloud so the bobbing keeps the puffs' shape.
    local offsets = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            offsets[part] = part.Position - cloud.Position
        end
    end
    local glow = Instance.new("PointLight")
    glow.Color = tint
    glow.Brightness = 1
    glow.Range = 12
    glow.Parent = cloud
    visuals[id] = { model = model, offsets = offsets }
    active[id] = cloud
end
-- Keep a dozen discoverable clouds near the starter activity zone.
for _ = 1, 12 do spawnCloud() end
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
    if toolId ~= "starter_net" and not (profile.ownedTools and profile.ownedTools[toolId]) then
        tool,toolId=CatchRules.resolveTool(nil,profile.captures,toolCatalog)
    end
    -- Server-owned permanent training bonus; never accept a range value from client.
    local training = math.clamp(math.floor(tonumber(profile.rangeTraining) or 0), 0, 3)
    local baseTool = tool
    tool = table.clone(baseTool)
    tool.rangeBonus = baseTool.rangeBonus + training * 2
        + CompanionRules.airReachBonus(profile.companionSpecies, profile.species, catalog, profile.companionBond)
    if equipped~=nil and equipped~=toolId then
        player:SetAttribute("EquippedCatchTool",toolId)
    end
    local cloud = active[cloudId]
    if not cloud or not cloud.Parent then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local species = catalog[cloud:GetAttribute("SpeciesId")]
    if not species then return end
    local targetDistance = (root.Position - cloud.Position).Magnitude
    local magnetPull = CatchRules.canMagnetPull(targetDistance, species, toolId, tool)
    if not CatchRules.isInRange(targetDistance, species, tool) and not magnetPull then
        remote:FireClient(player, false, "Move closer to the cloud!")
        return
    end
    -- Invalid, stale or out-of-range targets must not consume the catch cooldown.
    if now - (lastAttempt[player] or -100) < tool.cooldown then return end
    lastAttempt[player] = now
    -- Vacuum tools can collect nearby clouds in a single server-authoritative burst.
    -- Only the explicitly targeted cloud needs to be in range to start a burst.
    local candidates = {}
    if toolId == "storm_vacuum" then
        for otherId, otherCloud in pairs(active) do
            if otherId ~= cloudId and otherCloud.Parent then
                local otherSpecies = catalog[otherCloud:GetAttribute("SpeciesId")]
                local distance = (root.Position - otherCloud.Position).Magnitude
                if otherSpecies and CatchRules.isInRange(distance, otherSpecies, tool) then
                    table.insert(candidates, { id = otherId, distance = distance })
                end
            end
        end
    end
    local targetIds = CatchRules.selectBurstTargets(cloudId, candidates, toolId == "storm_vacuum" and 3 or 1)
    local caught = 0
    for _, targetId in ipairs(targetIds) do
        local targetCloud = active[targetId]
        if not targetCloud then continue end
        local targetSpecies = catalog[targetCloud:GetAttribute("SpeciesId")]
        if targetSpecies and active[targetId] == targetCloud then
            local mut = targetCloud:GetAttribute("MutationId")
            local baseCoins = CatchRules.coinReward(targetSpecies, tool)
            local coins = Mutations.bonusCoins(baseCoins, mut)
            local options = {
                variantId = mut and Mutations.key(targetSpecies.id, mut) or nil,
                xp = Mutations.bonusXp(CatchRules.XP_PER_CATCH, mut),
            }
            if ProfileStore.AddCatch(player, targetSpecies.id, coins, options) then
                active[targetId] = nil
                showCatchPulse(targetCloud.Position, targetCloud.Color, magnetPull)
                targetCloud:Destroy()
                if visuals[targetId] then
                    visuals[targetId].model:Destroy()
                    visuals[targetId] = nil
                end
                caught += 1
                task.delay(5, spawnCloud)
            end
        end
    end
    if caught > 0 then
        remote:FireClient(player, true, caught > 1 and ("Vacuum burst! Caught " .. caught .. " clouds!") or (magnetPull and "Magnet pull! Cloud caught!" or "Cloud caught!"))
    else
        remote:FireClient(player, false, "Unable to save catch. Try again.")
    end
end)
Players.PlayerRemoving:Connect(function(player)
    lastAttempt[player] = nil
end)

task.spawn(function()
    local phase = 0
    while true do
        task.wait(0.12)
        phase += 0.12
        for id, entry in pairs(visuals) do
            local cloud = active[id]
            if cloud and cloud.Parent and entry.model.Parent then
                local bob = Vector3.new(0, math.sin(phase + tonumber(id))*0.5, 0)
                for part, offset in pairs(entry.offsets) do
                    if part.Parent then
                        part.Position = cloud.Position + offset + bob
                    end
                end
            end
        end
    end
end)
