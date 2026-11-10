-- Server-authoritative Sky Forge recipes. Pure Luau, no client-provided costs.
local R = {}
R.recipes = {
 wind_lasso = {coins=35, captures=3, ingredients={breeze=3, drizzle=2}},
 mist_gloves = {coins=70, captures=8, ingredients={drizzle=4, mist=3}},
 cloud_magnet = {coins=100, captures=15, ingredients={breeze=5, cirrus=3}},
 golden_net = {coins=125, captures=30, ingredients={sunbeam=4, rainbow=2}},
 storm_vacuum = {coins=175, captures=50, ingredients={thunder=3, gale=4}},
}
function R.check(data, id, tools)
 local recipe = type(id)=="string" and R.recipes[id] or nil
 if not recipe or not tools[id] then return false,"Unknown recipe" end
 if type(data)~="table" or type(data.species)~="table" or type(data.ownedTools)~="table" then return false,"Profile unavailable" end
 if data.ownedTools[id] then return false,"Already owned" end
 if type(data.captures)~="number" or data.captures<recipe.captures then return false,"More catches required" end
 if type(data.coins)~="number" or data.coins<recipe.coins then return false,"Not enough coins" end
 for species,needed in pairs(recipe.ingredients) do
  local count=data.species[species]
  -- Preserve at least one specimen of every ingredient species.
  if type(count)~="number" or count~=count or count<needed+1 then return false,"Need spare "..species.." clouds" end
 end
 return true,recipe
end
function R.craft(data,id,tools)
 local ok,recipe=R.check(data,id,tools)
 if not ok then return false,recipe end
 -- All validations happen before any mutation: failed crafts consume nothing.
 data.coins-=recipe.coins
 for species,needed in pairs(recipe.ingredients) do data.species[species]-=needed end
 data.ownedTools[id]=true
 return true,recipe
end
return R
