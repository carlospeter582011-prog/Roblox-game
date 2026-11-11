-- Adds distinct elemental flight to existing 3D cloud models without client-trusted movement.
-- The catch script continues to own spawn, catch validation and visual model updates.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Flight = require(ReplicatedStorage:WaitForChild("CloudFlightRules"))
local SpawnRules = require(ReplicatedStorage:WaitForChild("SpawnRules"))
local folder = Workspace:WaitForChild("CatchableClouds")
local tracked = {}
local elapsed = 0
-- 5 Hz is enough for slow ambient motion; never spawn a loop per cloud.
task.spawn(function()
    while true do
        task.wait(0.2)
        elapsed += 0.2
        for _, cloud in ipairs(folder:GetChildren()) do
            if cloud:IsA("BasePart") and cloud:GetAttribute("CloudId") then
                local id = cloud:GetAttribute("CloudId")
                local state = tracked[cloud]
                if not state then
                    local species = catalog[cloud:GetAttribute("SpeciesId")]
                    if species then
                        -- Identify bounds by the original position, not client attributes.
                        local origin = cloud.Position
                        local region
                        if origin.X > 250 then
                            region = { minX = 285, maxX = 345, minZ = -30, maxZ = 30 }
                        elseif origin.X > 110 then
                            region = { minX = 140, maxX = 200, minZ = -30, maxZ = 30 }
                        else
                            region = { minX = -55, maxX = 55, minZ = -55, maxZ = 55 }
                        end
                        state = { origin = origin, element = species.element, seed = tonumber(id) or 0, bounds = region }
                        tracked[cloud] = state
                    end
                end
                if state and cloud.Parent then
                    local dx, dy, dz = Flight.offset(state.element, elapsed, state.seed)
                    local o = state.origin
                    local x, y, z = Flight.clampPosition(o.X + dx, o.Y + dy, o.Z + dz, state.bounds)
                    cloud.Position = Vector3.new(x, y, z)
                end
            end
        end
        for cloud in pairs(tracked) do
            if not cloud.Parent then tracked[cloud] = nil end
        end
    end
end)
