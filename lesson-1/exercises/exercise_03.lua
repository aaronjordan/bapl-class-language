local lpeg = require "lpeg"
local lu = require "luaunit"

-- CP / 13. Position capture
-- Modify ex2 to return all numerals followed by the position of the next
-- captured '+' operator

local numeral = lpeg.C(lpeg.R("09") ^ 1)
local plusOperator = lpeg.Cp() * lpeg.P("+")
local space = lpeg.S(" \n\t") ^ 0

-- let's match one number first, then attempt a plus and next number until end.
local matcher = numeral * (space * plusOperator * space * numeral) ^ 0

function TestMatcher()
  -- New Lua thing: use a "constructor" to get multiple returns from a
  -- function packed into a table. `a = { multiFn() }`
  local testInputsAndExpected = {
    { input = "8",                      expected = { "8" } },
    { input = "3+12",                   expected = { "3", 2, "12" } },
    { input = "6 + 12",                 expected = { "6", 3, "12" } },
    { input = "8 + 12 + 7 + 2003",      expected = { "8", 3, "12", 8, "7", 12, "2003" } },
    { input = "x8 + 12 +\t7 +\n\n2003", expected = {} }, -- with constructor, these nils become empty tables
    { input = "fishing rod",            expected = {} },
  }

  for i = 1, #testInputsAndExpected do
    local expected = testInputsAndExpected[i].expected
    local actual = { matcher:match(testInputsAndExpected[i].input) }
    lu.assertEquals(actual, expected)
  end
end

os.exit(lu.LuaUnit.run())
