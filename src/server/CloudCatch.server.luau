-- Initial playable vertical slice; session-only inventory (persistence is a later milestone).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local toolCatalog = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local CatchRules = require(ReplicatedStorage:WaitForChild("CatchRules"))
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
    cloud.Transparency = 1
    cloud.Parent = cloudFolder
    local model = Instance.new("Model")
    model.Name = "BreezeCloudVisual_" .. id
    model.Parent = cloudFolder
    for i, offset in ipairs({Vector3.new(-2,0,0),Vector3.new(0,1,0),Vector3.new(2.2,0,0),Vector3.new(0,-0.4,1.3)}) do
        local puff = Instance.new("Part")
        puff.Name = "Puff" .. i
        puff.Shape = Enum.PartType.Ball
        puff.Size = Vector3.new(3.8,3,3.5)
        puff.Color = Color3.fromRGB(226,242,255)
        puff.Material = Enum.Material.SmoothPlastic
        puff.Anchored = true
        puff.CanCollide = false
        puff.Position = cloud.Position + offset
        puff.Parent = model
    end
    local glow = Instance.new("PointLight")
    glow.Color = Color3.fromRGB(148,207,255)
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
    if not ProfileStore.AddCatch(player, species.id, CatchRules.coinReward(species, tool)) then
        -- Player profile unavailable: preserve the cloud rather than grant an unsaved catch.
        active[cloudId] = cloud
        remote:FireClient(player, false, "Profile unavailable. Please rejoin.")
        return
    end
    cloud:Destroy()
    if visuals[cloudId] then visuals[cloudId]:Destroy(); visuals[cloudId] = nil end
    remote:FireClient(player, true, "Caught a Breeze Cloud!")
    task.delay(5, spawnCloud)
end)
Players.PlayerRemoving:Connect(function(player)
    lastAttempt[player] = nil
end)

-- Lightweight idle animation for original multi-part cloud models.
task.spawn(function()
    local phase = 0
    while true do
        task.wait(0.12)
        phase += 0.12
        for id, model in pairs(visuals) do
            local cloud = active[id]
            if cloud and cloud.Parent and model.Parent then
                local offsets = {Vector3.new(-2,0,0),Vector3.new(0,1,0),Vector3.new(2.2,0,0),Vector3.new(0,-0.4,1.3)}
                local bob = Vector3.new(0, math.sin(phase + tonumber(id))*0.6, 0)
                for index, part in ipairs(model:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Position = cloud.Position + offsets[index] + bob
                    end
                end
            end
        end
    end
end)
