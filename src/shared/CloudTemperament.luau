-- Deterministic, bounded elemental movement for server-owned catch targets.
-- All values are studs; no client input or random state.
local Motion = {}
local patterns = {
 Air={1.4,0.55,1.3}, Water={0.65,0.45,0.65},
 Storm={1.0,0.8,2.1}, Fire={0.7,0.7,1.7},
 Ice={0.3,0.3,0.45}, Earth={0.25,0.25,0.4},
 Nature={0.6,0.4,0.85}, Light={0.9,0.6,1.2},
 Shadow={0.7,0.5,0.75}, Cosmic={1.1,0.75,0.5},
}
function Motion.offset(element, elapsed, seed)
    local p = patterns[element] or patterns.Air
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed == math.huge or elapsed == -math.huge then elapsed=0 end
    if type(seed) ~= "number" or seed ~= seed or seed == math.huge or seed == -math.huge then seed=0 end
    elapsed=math.clamp(elapsed,0,100000)
    seed=math.clamp(seed,0,100000)
    local phase=elapsed*p[3]+seed*0.37
    return math.sin(phase)*p[1], math.sin(phase*0.67)*p[2], math.cos(phase*0.8)*p[1]*0.65
end
return table.freeze(Motion)
