-- Cloud visual helpers. Prefer real MeshParts when MeshId is set.
-- Falls back to improved multi-part geometry until meshes are uploaded.
-- Recommended free CC0 sources (import into Studio, then set MeshId):
-- - Kenney Nature Kit: https://kenney.nl/assets/nature-kit (CC0)
-- - Quaternius Ultimate Nature Pack: https://quaternius.com/packs/ultimatenature.html (CC0)
-- - Sketchfab free clouds (check each license; prefer CC0/CC-BY)
local CloudVisuals = {}

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
