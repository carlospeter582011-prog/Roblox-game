-- Deterministic server-wide sky weather. Pure logic, no Roblox services.
local Weather = {}
Weather.CYCLE_SECONDS = 480
Weather.PHASES = {
    { id = "calm", label = "Clear Skies", coins = 1, xp = 1, color = {120, 195, 255} },
    { id = "tailwind", label = "Tailwind", coins = 1.15, xp = 1.10, color = {120, 245, 185} },
    { id = "rain", label = "Cloudburst", coins = 1.05, xp = 1.25, color = {110, 150, 255} },
    { id = "aurora", label = "Aurora Hour", coins = 1.25, xp = 1.15, color = {205, 125, 255} },
}
function Weather.phaseAt(seconds)
    if type(seconds) ~= "number" or seconds ~= seconds or seconds < 0 or seconds == math.huge then
        return Weather.PHASES[1], Weather.CYCLE_SECONDS
    end
    local index = math.floor(seconds / Weather.CYCLE_SECONDS) % #Weather.PHASES + 1
    return Weather.PHASES[index], Weather.CYCLE_SECONDS - seconds % Weather.CYCLE_SECONDS
end
function Weather.reward(base, multiplier)
    if type(base) ~= "number" or base ~= base or base < 0 or base > 1000000 then return 0 end
    if type(multiplier) ~= "number" or multiplier ~= multiplier or multiplier < 1 or multiplier > 1.25 then return 0 end
    return math.floor(base * multiplier)
end
return Weather
