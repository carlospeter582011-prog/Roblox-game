-- Lightweight real 3D cloud companions; server-authoritative ownership and selection.
-- Each player can display one non-colliding original Part model, no world-space GUI.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Rules = require(ReplicatedStorage:WaitForChild("CompanionRules"))
local remote = Instance.new("RemoteEvent")
remote.Name = "CycleCloudCompanion"
remote.Parent = ReplicatedStorage
local models = {}
local lastPositions = {} -- smooth follow state, reset on respawn or companion switch
local folder = Instance.new("Folder")
folder.Name = "CloudCompanions"
folder.Parent = workspace
local function remove(player)
    local model = models[player]
    if model then model:Destroy() end
    models[player] = nil
    lastPositions[player] = nil
end
local function makePart(model, size, offset, color)
    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Size = size
    part.CFrame = CFrame.new(offset)
    part.Color = color
    part.Material = Enum.Material.SmoothPlastic
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Parent = model
    return part
end
local function rebuild(player)
    remove(player)
    local profile = Profile.Get(player)
    local id = player:GetAttribute("CompanionSpecies")
    if not profile or not Rules.owned(id, profile.species, Catalog) then return end
    local spec = Catalog[id]
    local rgb = spec.colorRGB or { 215, 235, 255 }
    local color = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
    local model = Instance.new("Model")
    model.Name = "Companion_" .. player.UserId
    local root = makePart(model, Vector3.new(2.5, 1.4, 1.7), Vector3.zero, color)
    model.PrimaryPart = root
    makePart(model, Vector3.new(1.6, 1.3, 1.5), Vector3.new(-0.8, 0.25, 0), color)
    makePart(model, Vector3.new(1.5, 1.2, 1.4), Vector3.new(0.85, 0.15, 0), color)
    model.Parent = folder
    models[player] = model
end
local lastRequest = {}
remote.OnServerEvent:Connect(function(player)
    local now = os.clock()
    if now - (lastRequest[player] or -10) < 0.6 then return end
    lastRequest[player] = now
    local ok, message = Profile.CycleCompanion(player)
    remote:FireClient(player, ok, message)
end)
local function setup(player)
    player:GetAttributeChangedSignal("CompanionSpecies"):Connect(function() rebuild(player) end)
    if player:GetAttribute("CompanionSpecies") then rebuild(player) end
end
Players.PlayerAdded:Connect(setup)
for _, player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerRemoving:Connect(function(player)
    remove(player)
    lastRequest[player] = nil
end)
task.spawn(function()
    local phase = 0
    while true do
        task.wait(0.15)
        phase += 0.15
        for player, model in pairs(models) do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root and model.Parent then
                local target = root.CFrame * CFrame.new(-3.3, 2 + math.sin(phase * 2 + player.UserId % 7) * 0.3, 2.8)
                -- Smoothly follow moving players, but snap after teleport/respawn.
                -- This avoids a companion visibly crossing the map after fast travel.
                local previous = lastPositions[player]
                local nextPivot = target
                if previous and (previous.Position - target.Position).Magnitude < 30 then
                    nextPivot = previous:Lerp(target, 0.38)
                end
                model:PivotTo(nextPivot)
                lastPositions[player] = nextPivot
            elseif model.Parent then
                -- Hide until the player's character respawns.
                model:PivotTo(CFrame.new(0, -10000, 0))
                lastPositions[player] = nil
            end
        end
    end
end)
