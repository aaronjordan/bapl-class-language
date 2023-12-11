local lpeg = require "lpeg"
local lu = require "luaunit"

-- Samples to test CI integration.

local test = "testing 👷"
print(test);

local result = 1 + 2

function TestBasicMath()
  lu.assertEquals(result, 3)
end

function TestTestMessage()
  lu.assertStrContains(test, 'test')
  lu.assertStrContains(test, '👷')
end

-- CP / 8. Getting Started!

local p = lpeg.P("hello")

local result1 = lpeg.match(p, "hello world")
local result2 = lpeg.match(p, "goodbye world")

function TestStarterExample()
  lu.assertEquals(result1, 6)
  lu.assertEquals(result2, nil)
end

os.exit(lu.LuaUnit.run())
