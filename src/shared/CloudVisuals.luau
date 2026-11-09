-- Cloud visual helpers. Prefer real MeshParts when MeshId is set.
-- Falls back to improved multi-part geometry until meshes are uploaded.
-- Recommended free CC0 sources (import into Studio, then set MeshId):
-- - Kenney Nature Kit: https://kenney.nl/assets/nature-kit (CC0)
-- - Quaternius Ultimate Nature Pack: https://quaternius.com/packs/ultimatenature.html (CC0)
-- - Sketchfab free clouds (check each license; prefer CC0/CC-BY)
local CloudVisuals = {}
local AssetService = game:GetService("AssetService")
local modelTemplate = nil
local modelAttempted = false

-- Only set this to a confirmed, creator-owned Roblox MODEL asset ID from Open Cloud.
-- This is intentionally separate from MeshIds: a Model asset ID is NOT a MeshPart.MeshId.
local VERIFIED_CLOUD_MODEL_ASSET_ID = 104852877755332

local function loadCloudTemplate()
    if modelAttempted then return modelTemplate end
    modelAttempted = true
    if type(VERIFIED_CLOUD_MODEL_ASSET_ID) ~= "number" or VERIFIED_CLOUD_MODEL_ASSET_ID <= 0 then return nil end
    local ok, container = pcall(function()
        return AssetService:LoadAssetAsync(VERIFIED_CLOUD_MODEL_ASSET_ID)
    end)
    if not ok or not container then
        warn("Cloud model asset could not be loaded; using original 3D fallback")
        return nil
    end
    -- Treat uploaded assets as untrusted: copy ONLY geometry, never scripts or remotes.
    local template = Instance.new("Model")
    template.Name = "VerifiedCloudGeometry"
    local partCount = 0
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("BasePart") and partCount < 32 then
            partCount += 1
            local geometry = descendant:Clone()
            for _, child in ipairs(geometry:GetDescendants()) do
                if not child:IsA("SpecialMesh") and not child:IsA("DataModelMesh") then
                    child:Destroy()
                end
            end
            geometry.Anchored = true
            geometry.CanCollide = false
            geometry.Parent = template
        end
    end
    container:Destroy()
    if #template:GetChildren() == 0 then
        template:Destroy()
        warn("Cloud Model asset contained no usable geometry; using 3D fallback")
        return nil
    end
    -- Normalize imported GLB dimensions and origin before cloning into the world.
    -- The Open Cloud package may have a different pivot or meter-to-stud scale.
    local bounds, size = template:GetBoundingBox()
    local longest = math.max(size.X, size.Y, size.Z)
    if longest < 0.001 or longest ~= longest or longest > 100000 then
        template:Destroy()
        warn("Cloud Model has invalid geometry bounds; using 3D fallback")
        return nil
    end
    template:ScaleTo(6 / longest)
    bounds = template:GetBoundingBox()
    template:PivotTo(CFrame.new(-bounds.Position) * template:GetPivot())
    modelTemplate = template
    return modelTemplate
end

-- Set these after you upload meshes to Roblox and copy the MeshIds.
CloudVisuals.MeshIds = {
    -- cloud = "rbxassetid://YOUR_CLOUD_MESH_ID",
    -- tree = "rbxassetid://YOUR_TREE_MESH_ID",
    -- island = "rbxassetid://YOUR_ISLAND_MESH_ID",
}

function CloudVisuals.createCloudVisual(parent, position, tint, speciesId)
    local model = Instance.new("Model")
    model.Name = (speciesId or "cloud") .. "Visual"
    model.Parent = parent

    local template = loadCloudTemplate()
    if template then
        local imported = template:Clone()
        imported.Name = "ImportedCloudGeometry"
        imported.Parent = model
        imported:PivotTo(CFrame.new(position))
        for _, part in ipairs(imported:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = tint
                part.Anchored = true
                part.CanCollide = false
            end
        end
        return model
    end

    local meshId = CloudVisuals.MeshIds.cloud
    if meshId and meshId ~= "" and meshId ~= "rbxassetid://YOUR_CLOUD_MESH_ID" then
        local mesh = Instance.new("MeshPart")
        mesh.Name = "CloudMesh"
        mesh.MeshId = meshId
        mesh.Size = Vector3.new(6, 4, 5)
        mesh.Color = tint
        mesh.Material = Enum.Material.SmoothPlastic
        mesh.Anchored = true
        mesh.CanCollide = false
        mesh.Position = position
        mesh.Parent = model
        return model
    end

    -- Improved multi-part fallback (better than single ball)
    local offsets = {
        Vector3.new(-2.2, 0, 0),
        Vector3.new(0, 0.8, 0),
        Vector3.new(2.2, 0, 0),
        Vector3.new(0, -0.3, 1.4),
        Vector3.new(-1.2, 0.4, -0.8),
        Vector3.new(1.2, 0.3, -0.6),
    }
    for i, offset in ipairs(offsets) do
        local puff = Instance.new("Part")
        puff.Name = "Puff" .. i
        puff.Shape = Enum.PartType.Ball
        puff.Size = Vector3.new(3.6, 2.8, 3.4)
        puff.Color = tint:Lerp(Color3.new(1, 1, 1), 0.45)
        puff.Material = Enum.Material.SmoothPlastic
        puff.Anchored = true
        puff.CanCollide = false
        puff.Position = position + offset
        puff.Parent = model
    end
    return model
end

return CloudVisuals
