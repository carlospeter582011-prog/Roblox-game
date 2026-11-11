-- Pure, deterministic storm survival rules. No Roblox globals.
local Rules = {}
Rules.ROUND_SECONDS = 150
Rules.STORM_SECONDS = 45
Rules.REQUIRED_SAFE_SECONDS = 22
Rules.REWARD_COINS = 55
Rules.REWARD_XP = 30
function Rules.inShelter(px, pz, sx, sz, radius)
    if type(px) ~= "number" or type(pz) ~= "number" or type(sx) ~= "number" or type(sz) ~= "number" then return false end
    if px ~= px or pz ~= pz or sx ~= sx or sz ~= sz then return false end
    if type(radius) ~= "number" or radius <= 0 or radius ~= radius then return false end
    return (px-sx)^2 + (pz-sz)^2 <= radius^2
end
function Rules.advance(seconds, isSafe, eligible)
    local n = type(seconds) == "number" and seconds == seconds and math.max(0, math.min(seconds, Rules.REQUIRED_SAFE_SECONDS)) or 0
    if eligible and isSafe then n = math.min(Rules.REQUIRED_SAFE_SECONDS, n + 1) end
    return n, n >= Rules.REQUIRED_SAFE_SECONDS
end
return Rules
