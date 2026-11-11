-- Client-only 3D outline; never changes server catch validation or rewards.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local event = ReplicatedStorage:WaitForChild("CloudTrackerResult")
local current
local generation = 0
event.OnClientEvent:Connect(function(id, duration)
    generation += 1
    local token = generation
    if current then current:Destroy(); current = nil end
    if type(id) ~= "string" or id == "" then return end
    local folder = Workspace:FindFirstChild("CatchableClouds")
    if not folder then return end
    local model
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") and item.Name:sub(-(#id + 1)) == "_" .. id
            and item.Name:find("CloudVisual_", 1, true) then
            model = item
            break
        end
    end
    if not model then return end
    local outline = Instance.new("Highlight")
    outline.Name = "PersonalCloudTrackerOutline"
    outline.Adornee = model
    outline.FillTransparency = 0.85
    outline.OutlineTransparency = 0
    outline.OutlineColor = Color3.fromRGB(255, 230, 95)
    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    outline.Parent = model
    current = outline
    task.delay(math.clamp(tonumber(duration) or 14, 1, 20), function()
        if generation == token and current == outline then
            current:Destroy()
            current = nil
        end
    end)
end)
