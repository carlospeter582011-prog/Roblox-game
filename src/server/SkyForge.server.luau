-- Original native Roblox 3D forge; no Canvas world geometry or external meshes.
local Players=game:GetService("Players")
local Profile=require(script.Parent:WaitForChild("ProfileStore"))
local model=Instance.new("Model")
model.Name="SkyForge3D"
model.Parent=workspace
local function part(name,size,pos,color,material)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true
 p.Color=color;p.Material=material;p.Parent=model
 return p
end
local base=part("StoneAnvil",Vector3.new(8,3,6),Vector3.new(-35,2,-22),Color3.fromRGB(83,96,116),Enum.Material.Slate)
part("ForgeCore",Vector3.new(3,2,3),Vector3.new(-35,4.5,-22),Color3.fromRGB(109,188,230),Enum.Material.Neon)
local recipes={"wind_lasso","mist_gloves","cloud_magnet","golden_net","storm_vacuum"}
for i,id in ipairs(recipes) do
 local x=-47+(i-1)*6
 local pedestal=part("Recipe_"..id,Vector3.new(4,2,4),Vector3.new(x,2,-30),Color3.fromRGB(93,109,131),Enum.Material.Slate)
 local prompt=Instance.new("ProximityPrompt")
 prompt.Name="Forge_"..id
 prompt.ActionText="Craft "..id:gsub("_"," ")
 prompt.ObjectText="Sky Forge"
 prompt.HoldDuration=0.5;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false
 prompt.Parent=pedestal
 prompt.Triggered:Connect(function(player)
  if not player or not player:IsA("Player") or not player.Parent then return end
  local character=player.Character
  local root=character and character:FindFirstChild("HumanoidRootPart")
  local hum=character and character:FindFirstChildOfClass("Humanoid")
  if not root or not hum or hum.Health<=0 or (root.Position-pedestal.Position).Magnitude>12 then return end
  if not player:GetAttribute("ProfileReady") then return end
  local ok,message=Profile.CraftTool(player,id)
  player:SetAttribute("ForgeFeedback",message)
 end)
end
