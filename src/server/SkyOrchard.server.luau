-- Three native 3D orchard trees. Growth timers are per-player, per-tree and session-only;
-- earned Coins/XP are persisted by the existing server-owned ProfileStore autosave.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyOrchardRules"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local cooldowns = MemoryStoreService:GetSortedMap("CatchACloud_OrchardCooldown_v1")
local inFlight = {}
local harvestTimes = {}
local folder = Instance.new("Folder")
folder.Name = "SkyOrchard3D"
folder.Parent = Workspace

local function makePart(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material
    p.Parent = parent
    return p
end

local function plant(id, label, center, tint)
    local model = Instance.new("Model")
    model.Name = "Orchard_" .. id
    model.Parent = folder
    makePart(model, "Trunk", Vector3.new(3, 13, 3), center + Vector3.new(0, 7.5, 0),
        Color3.fromRGB(120, 88, 65), Enum.Material.Wood)
    for i = 1, 5 do
        local angle = i * math.pi * 2 / 5
        local fruit = makePart(model, "SkyFruit", Vector3.new(4, 4, 4),
            center + Vector3.new(math.cos(angle) * 5, 14 + (i % 2), math.sin(angle) * 5),
            tint, Enum.Material.Neon)
        fruit.Shape = Enum.PartType.Ball
    end
    local canopy = makePart(model, "Canopy", Vector3.new(16, 8, 16),
        center + Vector3.new(0, 15, 0), tint, Enum.Material.Grass)
    canopy.Shape = Enum.PartType.Ball
    canopy.Transparency = 0.22
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Harvest"
    prompt.ActionText = "Harvest"
    prompt.ObjectText = label
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = makePart(model, "HarvestAnchor", Vector3.new(2, 2, 2),
        center + Vector3.new(0, 3, 0), tint, Enum.Material.SmoothPlastic)
    prompt.Parent.Transparency = 1
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local profile = Profile.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid then return end
        local now = os.time()
        local record = harvestTimes[player]
        local last = record and record[id] or nil
        local distance = (root.Position - prompt.Parent.Position).Magnitude
        if not Rules.canHarvest(id, profile.captures, distance, humanoid.Health > 0,
            player:GetAttribute("ProfileReady") == true, now, last) then
            player:SetAttribute("OrchardFeedback", "Not ready: unlock or wait for fruit to regrow")
            return
        end
        -- Atomically reserve a cross-server cooldown before awarding currency.
        -- Fail closed during MemoryStore outages, rather than allowing rejoin farming.
        local key = tostring(player.UserId) .. ":" .. id
        if inFlight[key] then return end
        inFlight[key] = true
        local reserved = false
        local ok, err = pcall(function()
            local result = cooldowns:UpdateAsync(key, function(previous)
                if type(previous) == "number" and previous > now then
                    return nil
                end
                return now + Rules.GROW_SECONDS, now + Rules.GROW_SECONDS
            end, Rules.GROW_SECONDS + 30)
            reserved = result == now + Rules.GROW_SECONDS
        end)
        inFlight[key] = nil
        if not ok or not reserved then
            player:SetAttribute("OrchardFeedback", "Fruit regrowing or orchard service unavailable")
            if not ok then warn("Orchard cooldown reservation failed", err) end
            return
        end
        if Profile.Get(player) ~= profile or not player.Parent
            or player:GetAttribute("ProfileReady") ~= true then return end
        -- No yield between timestamp update and wallet mutation.
        record = record or {}
        harvestTimes[player] = record
        record[id] = now
        local reward = Rules.TREES[id]
        profile.coins = math.min(1000000000, profile.coins + reward.coins)
        profile.xp = math.min(1000000000, profile.xp + reward.xp)
        player:SetAttribute("CloudCoins", profile.coins)
        player:SetAttribute("CloudXP", profile.xp)
        player:SetAttribute("CloudLevel", Leveling.levelForXp(profile.xp))
        player:SetAttribute("OrchardFeedback", label .. ": +" .. reward.coins .. " Coins, +" .. reward.xp .. " XP")
    end)
end

plant("meadow", "Meadow Skyfruit", Vector3.new(-45, 1, 45), Color3.fromRGB(130, 232, 165))
plant("eastwind", "Eastwind Skyfruit", Vector3.new(177, 1, 30), Color3.fromRGB(126, 201, 247))
plant("ridge", "Thunder Skyfruit", Vector3.new(328, 1, 29), Color3.fromRGB(195, 151, 246))
Players.PlayerRemoving:Connect(function(player) harvestTimes[player] = nil end)
