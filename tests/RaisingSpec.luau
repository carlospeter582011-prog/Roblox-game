-- Tests for RaisingRules
local Rules = require(script.Parent.Parent.src.shared.RaisingRules)

local function assertTrue(cond, msg)
    if not cond then error(msg or "assertion failed") end
end

local function testCanFeed()
    assertTrue(Rules.canFeed(50, 0))
    assertTrue(not Rules.canFeed(10, 0))
    assertTrue(not Rules.canFeed(50, 1000))
end

testCanFeed()
print("RaisingSpec: all tests passed")
