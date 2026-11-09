-- Reusable server-side 3D world models. Models are actual Roblox 3D instances, never Canvas.
-- Replace individual parts with owner-approved MeshParts when licensed MeshIds become available.
local Assets = {}

Assets.MeshIds = {
    tree = nil,
    crystal = nil,
    floatingRock = nil,
}

local function solid(parent, name, size, cf, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material
    p.Anchored = true
    -- Decorative trees and underside rocks must not trap players or create climbable towers.
    p.CanCollide = false
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function approvedMesh(parent, name, meshId, size, cf, color, collide)
    if type(meshId) ~= "string" or not string.match(meshId, "^rbxassetid://%d+$") then
        return nil
    end
    local mesh = Instance.new("MeshPart")
    mesh.Name = name
    mesh.MeshId = meshId
    mesh.Size = size
    mesh.CFrame = cf
    mesh.Color = color
    mesh.Anchored = true
    mesh.CanCollide = collide == true
    mesh.Parent = parent
    return mesh
end

function Assets.tree(parent, position, scale)
    scale = scale or 1
    local model = Instance.new("Model")
    model.Name = "SkyTree3D"
    model.Parent = parent
    local cf = CFrame.new(position)
    if approvedMesh(model, "TreeMesh", Assets.MeshIds.tree,
        Vector3.new(12, 20, 12) * scale, cf * CFrame.new(0, 7 * scale, 0),
        Color3.fromRGB(146, 214, 181), true) then
        return model
    end
    solid(model, "Trunk", Vector3.new(2.4, 11, 2.4) * scale,
        cf * CFrame.new(0, 5.5 * scale, 0),
        Color3.fromRGB(120, 85, 75), Enum.Material.Wood)
    -- Tapered canopy tiers and branches create a recognizable fantasy tree silhouette.
    local foliage = Color3.fromRGB(105, 191, 169)
    for tier = 1, 3 do
        local height = (8 + tier * 2.3) * scale
        local crown = solid(model, "CanopyTier" .. tier,
            Vector3.new((10 - tier * 1.6) * scale, 3.2 * scale, (10 - tier * 1.6) * scale),
            cf * CFrame.new(0, height, 0),
            foliage:Lerp(Color3.fromRGB(190, 244, 217), tier / 5), Enum.Material.Grass)
        crown.CanCollide = false
    end
    for i, offset in ipairs({
        Vector3.new(-3, 12, 0), Vector3.new(3, 12, 0),
        Vector3.new(0, 15, 0), Vector3.new(0, 12, 3),
        Vector3.new(0, 12, -3),
    }) do
        solid(model, "Foliage" .. i, Vector3.new(7, 6, 7) * scale,
            cf * CFrame.new(offset * scale), foliage, Enum.Material.SmoothPlastic,
            Enum.PartType.Ball)
    end
    return model
end

function Assets.crystal(parent, position, scale)
    scale = scale or 1
    local model = Instance.new("Model")
    model.Name = "SkyCrystal3D"
    model.Parent = parent
    local cf = CFrame.new(position)
    if approvedMesh(model, "CrystalMesh", Assets.MeshIds.crystal,
        Vector3.new(3, 8, 3) * scale, cf,
        Color3.fromRGB(167, 140, 251), false) then
        return model
    end
    for i = 1, 3 do
        local angle = i * math.pi * 2 / 3
        local height = (i == 1 and 7 or 4.5) * scale
        local p = solid(model, "CrystalShard" .. i,
            Vector3.new(1.5, height, 1.5) * scale,
            cf * CFrame.new(math.cos(angle) * scale, height / 2, math.sin(angle) * scale)
                * CFrame.Angles(0, angle, math.rad(12)),
            Color3.fromRGB(167, 140, 251), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Brightness = 0.35
        light.Range = 8 * scale
        light.Parent = p
    end
    return model
end

function Assets.floatingRock(parent, position)
    local model = Instance.new("Model")
    model.Name = "FloatingRock3D"
    model.Parent = parent
    if approvedMesh(model, "FloatingRockMesh", Assets.MeshIds.floatingRock,
        Vector3.new(82, 24, 82), CFrame.new(position),
        Color3.fromRGB(95, 106, 135), true) then
        return model
    end
    for i = 1, 7 do
        local angle = i * math.pi * 2 / 7
        local radius = i == 1 and 0 or 20
        local rock = solid(model, "Rock",
            Vector3.new(i == 1 and 68 or 30, i == 1 and 22 or 15, i == 1 and 68 or 30),
            CFrame.new(position + Vector3.new(math.cos(angle) * radius, -i * 0.5, math.sin(angle) * radius)),
            Color3.fromRGB(95, 106, 135), Enum.Material.Slate, Enum.PartType.Ball)
        rock.CanCollide = false
    end
    return model
end


-- A fully procedural, reusable 3D arch. No external asset, Canvas or Studio import.
-- The arch is decorative and non-collidable so it cannot trap players.
function Assets.skyArch(parent, position, scale, yaw)
    scale = scale or 1
    yaw = yaw or 0
    local model = Instance.new("Model")
    model.Name = "SkyArch3D"
    model.Parent = parent
    local origin = CFrame.new(position) * CFrame.Angles(0, yaw, 0)
    local stone = Color3.fromRGB(169, 180, 218)
    for side = -1, 1, 2 do
        local pillar = solid(model, "ArchPillar", Vector3.new(3, 11, 3) * scale,
            origin * CFrame.new(side * 7 * scale, 5.5 * scale, 0),
            stone, Enum.Material.Slate)
        pillar.CanCollide = false
        local cap = solid(model, "ArchCapital", Vector3.new(4.2, 2, 4.2) * scale,
            origin * CFrame.new(side * 7 * scale, 11 * scale, 0),
            Color3.fromRGB(205, 204, 238), Enum.Material.Marble)
        cap.CanCollide = false
    end
    local lintel = solid(model, "ArchLintel", Vector3.new(17, 3, 4) * scale,
        origin * CFrame.new(0, 13 * scale, 0),
        stone, Enum.Material.Marble)
    lintel.CanCollide = false
    local gem = solid(model, "ArchKeystone", Vector3.new(3, 4, 3) * scale,
        origin * CFrame.new(0, 13 * scale, -2.5 * scale),
        Color3.fromRGB(152, 225, 255), Enum.Material.Neon, Enum.PartType.Ball)
    gem.CanCollide = false
    local light = Instance.new("PointLight")
    light.Brightness = 0.6
    light.Range = 14 * scale
    light.Parent = gem
    return model
end


-- Original three-dimensional wayfinding lantern: real Parts, not a GUI or decal stand-in.
-- The floating marker remains non-collidable so it cannot obstruct players.
function Assets.skyLantern(parent, position, scale)
    scale = scale or 1
    local model = Instance.new("Model")
    model.Name = "SkyLantern3D"
    model.Parent = parent
    local origin = CFrame.new(position)
    local metal = Color3.fromRGB(94, 119, 157)
    local glow = Color3.fromRGB(255, 218, 132)
    solid(model, "Pedestal", Vector3.new(2.4, 0.6, 2.4) * scale,
        origin * CFrame.new(0, 0.3 * scale, 0), metal, Enum.Material.Metal)
    solid(model, "Post", Vector3.new(0.45, 5, 0.45) * scale,
        origin * CFrame.new(0, 3 * scale, 0), metal, Enum.Material.Metal)
    local bulb = solid(model, "LightOrb", Vector3.new(2.2, 2.2, 2.2) * scale,
        origin * CFrame.new(0, 6.2 * scale, 0), glow, Enum.Material.Neon, Enum.PartType.Ball)
    local light = Instance.new("PointLight")
    light.Color = glow
    light.Brightness = 0.7
    light.Range = 14 * scale
    light.Parent = bulb
    return model
end

return Assets
