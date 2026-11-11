-- Original native-3D sky observatory: reveals a nearby cloud, without granting farmable currency.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("ObservatoryRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local lastScan = {}
local model = Instance.new("Model")
model.Name = "SkyObservatory3D"
model.Parent = Workspace
local base = Instance.new("Part")
base.Name = "ObservatoryPlatform"
base.Size = Vector3.new(10, 1, 10)
base.Position = Vector3.new(-22, 2.5, 0)
base.Anchored = true
base.Material = Enum.Material.Slate
base.Color = Color3.fromRGB(55, 78, 115)
base.Parent = model
local lens = Instance.new("Part")
lens.Name = "CloudScannerLens"
lens.Shape = Enum.PartType.Ball
lens.Size = Vector3.new(4, 4, 4)
lens.Position = base.Position + Vector3.new(0, 4, 0)
lens.Anchored = true
lens.CanCollide = false
lens.Material = Enum.Material.Glass
lens.Color = Color3.fromRGB(110, 196, 238)
lens.Parent = model
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Scan clouds"
prompt.ObjectText = "Sky Observatory"
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false
prompt.Parent = lens
local event = Instance.new("RemoteEvent")
event.Name = "SkyObservatoryResult"
event.Parent = ReplicatedStorage
prompt.Triggered:Connect(function(player)
    local now = os.clock()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not ProfileStore.Get(player) or not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - lens.Position).Magnitude > prompt.MaxActivationDistance + 3 then return end
    if not Rules.canScan(now, lastScan[player]) then return end
    lastScan[player] = now
    local folder = Workspace:FindFirstChild("CatchableClouds")
    local candidates = {}
    if folder then
        for _, cloud in ipairs(folder:GetChildren()) do
            if cloud:IsA("BasePart") then
                local id, species = cloud:GetAttribute("CloudId"), cloud:GetAttribute("SpeciesId")
                if type(id) == "string" and catalog[species] then
                    table.insert(candidates, { id = id, species = species, x = cloud.Position.X, z = cloud.Position.Z })
                end
            end
        end
    end
    local found, distance = Rules.nearest({x = lens.Position.X, z = lens.Position.Z}, candidates)
    if found then
        event:FireClient(player, catalog[found.species].name, math.floor(distance + 0.5))
    else
        event:FireClient(player, nil, nil)
    end
end)
Players.PlayerRemoving:Connect(function(player) lastScan[player] = nil end)
