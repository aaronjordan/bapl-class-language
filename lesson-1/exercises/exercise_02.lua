local lpeg = require "lpeg"
local lu = require "luaunit"

-- CP / 11. Matching a Summation
-- Pattern to match non-empty set of numerals joined with '+' and optional
-- whitespace

local numeral = lpeg.R("09") ^ 1  -- unsure if term *numeral* has length 1 or 1-N
local plusOperator = lpeg.P("+")
local space = lpeg.S(" \n\t") ^ 0 -- is this all whitespace chars?

-- let's match one number first, then attempt a plus and next number until end.
local matcher = numeral * (space * plusOperator * space * numeral) ^ 0

function TestMatcher()
  local testInputsAndExpected = {
    { input = "8",                      expected = 2 },
    { input = "8+12",                   expected = 5 },
    { input = "8 + 12",                 expected = 7 },
    { input = "8 + 12 + 7 + 2003",      expected = 18 },
    { input = "8 + 12 +\t7 +\n\n2003",  expected = 19 },
    { input = "x8 + 12 +\t7 +\n\n2003", expected = nil },
    { input = "beeswax",                expected = nil },
  }

  for i = 1, #testInputsAndExpected do
    local expected = testInputsAndExpected[i].expected
    local actual = matcher:match(testInputsAndExpected[i].input)
    lu.assertEquals(actual, expected)
  end
end

os.exit(lu.LuaUnit.run())
