-- Pure server-side glide eligibility and bounded velocity rules.
local Glide = {}
Glide.RequiredCatches = 5
Glide.Duration = 6
Glide.Cooldown = 12
Glide.HorizontalSpeed = 26
Glide.MaxFallSpeed = -9
function Glide.canStart(catches, alive, grounded, now, lastStarted)
    if type(catches) ~= "number" or catches < Glide.RequiredCatches then return false end
    if not alive or grounded then return false end
    if type(now) ~= "number" or now ~= now then return false end
    if lastStarted and now - lastStarted < Glide.Cooldown then return false end
    return true
end
function Glide.velocity(x, z, y)
    local length = math.sqrt(x*x + z*z)
    if length < 0.001 then return 0, math.max(y, Glide.MaxFallSpeed), 0 end
    return x / length * Glide.HorizontalSpeed, math.max(y, Glide.MaxFallSpeed), z / length * Glide.HorizontalSpeed
end
return Glide
