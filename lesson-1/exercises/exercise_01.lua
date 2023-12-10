-- Sample script that doesn't really do anything to test CI integration.
local lpeg = require "lpeg"
local lu = require "luaunit"

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

os.exit(lu.LuaUnit.run())
