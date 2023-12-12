local lpeg = require "lpeg"
local lu = require "luaunit"
local lang = require "./interpreter"

-- CP / 19. Add more operators

function TestMatcher()
  local tests = {
    -- a) add the '%' as multiplicative
    { input = "13 % 4",        out = 1 },
    { input = "2 * 13 % 4",    out = 2 },
    { input = "2 + 13 % 4",    out = 3 },
    { input = "4 % 4 * 4",     out = 0 },
    { input = "4 % 4 * 4 + 4", out = 4 },
    { input = "4 + 4 * 4 % 4", out = 4 },

    -- b) add the '^' higher than multiplicative
    { input = "4 ^ 2",         out = 16 },
    { input = "2 ^ 5",         out = 32 },
    { input = "2 ^ 5 * 2",     out = 64 },
    { input = "2 ^ (5 * 2)",   out = 1024 },
    { input = "5 ^ 3 - 25",    out = 100 },
  }

  for i = 1, #tests do
    local actual = lang:match(tests[i].input)
    lu.assertEquals(actual, tests[i].out)
  end
end

os.exit(lu.LuaUnit.run())
