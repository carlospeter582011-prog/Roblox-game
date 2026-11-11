-- Server-owned personal island plots with native 3D Parts and ProximityPrompts.
-- Each plot belongs to exactly one player in this server; layout is persisted in ProfileStore.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("IslandBuildRules"))
local plots = Instance.new("Folder")
plots.Name = "PersonalSkyIslands3D"
plots.Parent = Workspace
local slots = {}
local assigned = {}
local function makePart(parent, name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, pos
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color
    p.Parent = parent
    return p
end
local function prompt(part, action, label, callback)
    local p = Instance.new("ProximityPrompt")
    p.ActionText, p.ObjectText = action, label
    p.MaxActivationDistance = 12
    p.HoldDuration = 0.4
    p.RequiresLineOfSight = false
    p.Parent = part
    p.Triggered:Connect(callback)
end
local function near(player, part, distance)
    if not player or not player:IsA("Player") or not player.Parent then return false end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return root ~= nil and humanoid ~= nil and humanoid.Health > 0
        and (root.Position - part.Position).Magnitude <= distance
        and Profile.Get(player) ~= nil
end
local function teleport(player, target)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(target) end
end
local portal = makePart(plots, "PersonalIslandPortal", Vector3.new(10, 1, 10),
    Vector3.new(-35, 1.6, -25), Color3.fromRGB(110, 170, 240), Enum.Material.Neon)
local function createPlot(player, index)
    local center = Vector3.new(800 + index * 155, 0, 0)
    local model = Instance.new("Model")
    model.Name = "Island_" .. tostring(player.UserId)
    model.Parent = plots
    makePart(model, "FloatingIslandFloor", Vector3.new(100, 4, 100), center + Vector3.new(0, -2, 0),
        Color3.fromRGB(109, 187, 130), Enum.Material.Grass)
    local returnPad = makePart(model, "ReturnPortal", Vector3.new(9, 1, 9),
        center + Vector3.new(0, 0.5, -36), Color3.fromRGB(117, 175, 235), Enum.Material.Neon)
    prompt(returnPad, "Return", "Starter Meadow", function(visitor)
        if visitor ~= player or not near(visitor, returnPad, 15) then return end
        teleport(visitor, Vector3.new(-35, 6, -25))
    end)
    local positions = {}
    local function render(slot, id)
        if not Rules.Buildings[id] or positions[slot] then return end
        local x = ((slot - 1) % 3 - 1) * 25
        local z = (math.floor((slot - 1) / 3) - 0.5) * 28 + 10
        local base = makePart(model, "Building_" .. slot .. "_" .. id, Vector3.new(15, 8, 15),
            center + Vector3.new(x, 4, z), Color3.fromRGB(125, 173, 220), Enum.Material.Slate)
        local roof = makePart(model, "Roof_" .. slot, Vector3.new(18, 3, 18),
            base.Position + Vector3.new(0, 5.5, 0), Color3.fromRGB(182, 214, 240), Enum.Material.Glass)
        roof.CanCollide = false
        positions[slot] = true
    end
    local function refresh()
        local data = Profile.Get(player)
        if not data then return end
        for slot, id in pairs(data.islandLayout or {}) do render(slot, id) end
    end
    for slot = 1, Rules.MAX_SLOTS do
        local x = ((slot - 1) % 3 - 1) * 25
        local z = (math.floor((slot - 1) / 3) - 0.5) * 28 + 10
        local pad = makePart(model, "BuildSlot_" .. slot, Vector3.new(18, 1, 18),
            center + Vector3.new(x, 0.5, z), Color3.fromRGB(165, 140, 105), Enum.Material.WoodPlanks)
        local choices = { "breeze_habitat", "crystal_garden", "storm_roost" }
        local id = choices[(slot - 1) % #choices + 1]
        prompt(pad, "Build " .. Rules.Buildings[id].cost .. " Coins", Rules.Buildings[id].name, function(visitor)
            if visitor ~= player or not near(visitor, pad, 15) then return end
            local ok, feedback = Profile.BuyIslandBuilding(player, slot, id)
            if ok then render(slot, id) end
            player:SetAttribute("IslandBuildFeedback", feedback)
        end)
    end
    task.spawn(function()
        for _ = 1, 60 do
            if not player.Parent then return end
            if Profile.Get(player) then refresh() return end
            task.wait(1)
        end
    end)
    return model, center
end
prompt(portal, "Visit", "Your Sky Island", function(player)
    if not near(player, portal, 15) then return end
    local state = assigned[player]
    if not state then return end
    teleport(player, state.center + Vector3.new(0, 6, -35))
end)
Players.PlayerAdded:Connect(function(player)
    local index = 1
    while slots[index] do index += 1 end
    slots[index] = player
    local model, center = createPlot(player, index)
    assigned[player] = { index = index, model = model, center = center }
end)
Players.PlayerRemoving:Connect(function(player)
    local state = assigned[player]
    if not state then return end
    slots[state.index] = nil
    assigned[player] = nil
    state.model:Destroy()
end)
