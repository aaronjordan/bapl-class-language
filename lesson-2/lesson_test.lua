local lu = require "luaunit"
local lang = require "interpreter"
local pt = require "pt"

-- CP / 5. Hexadecimal numbers
-- Tests for code contributions in ../interpreter.lua
function TestHexSource()
  local inputToAstValue = {
    { input = "0",     val = 0 },
    { input = "3",     val = 3 },
    { input = "3a",    val = nil },
    { input = "0x1",   val = 1 },
    { input = "0XA",   val = 10 },
    { input = "0X1A",  val = 26 },
    { input = "0xfff", val = 4095 },
  }

  for i = 1, #inputToAstValue do
    local actual = lang.parse(inputToAstValue[i].input)
    lu.assertEquals((actual or {}).val, inputToAstValue[i].val)

    if actual == nil then
      print("[PASS]: rejected " .. inputToAstValue[i].input .. " as malformatted input ")
    else
      print("[PASS]: accepted " .. inputToAstValue[i].input .. " as " .. actual.val)
    end
  end
end

-- CP / 7. Adding multiplication and division.
-- Assignment B is already in place in the interpreter base code.
function TestStackTrace()
  print("stack trace test:")
  local parsed = lang.parse("3 + 2")
  local code = lang.compile(parsed)
  lang.run(code, {})
  -- Logs include stacktrace
end

-- Execute code `source`, returning the value at the bottom of the stack at
-- the end of execution.
local function exec(source)
  local stack = {}
  lang.run(lang.compile(lang.parse(source)), stack)
  return stack[1]
end

-- CP / 9. Adding more ops (pt. 1)
-- Add modulo and exponents on % and ^
function TestNewOps1()
  -- Add modulo as multiplicative:
  lu.assertEquals(exec("10 % 3"), 1)
  lu.assertEquals(exec("10 % 2"), 0)
  lu.assertEquals(exec("20 + 10 % 3"), 21)
  lu.assertEquals(exec("10 % 3 - 1"), 0)

  -- Add power higher than multiplicative:
  lu.assertEquals(exec("2^4"), 16)
  lu.assertEquals(exec("2^4 - 3^2 + 1"), 8)
  lu.assertEquals(exec("4 * 2^4 + 1"), 65)
end

function TestNewOps2()
  -- Add unary minus operator for negation
  lu.assertEquals(exec("-2"), -2)
  lu.assertEquals(exec("-2 + 13"), 11)
  lu.assertEquals(exec("2 + -13"), -11)
  lu.assertEquals(exec("-2 + -13"), -15)
  lu.assertEquals(exec("-2 + -13"), -15)
  lu.assertEquals(exec("-4^2"), 16)
  lu.assertEquals(exec("-(4^2)"), -16)

  -- Add comparison operators (bool as int 1=true, 0=false)
  lu.assertEquals(exec("2 > 2"), 0)
  lu.assertEquals(exec("3 > 2"), 1)
  lu.assertEquals(exec("2 < 3"), 1)
  lu.assertEquals(exec("3 < 3"), 0)
  lu.assertEquals(exec("2 >= 3"), 0)
  lu.assertEquals(exec("3 >= 3"), 1)
  lu.assertEquals(exec("2 <= 3"), 1)
  lu.assertEquals(exec("3 <= 3"), 1)
  lu.assertEquals(exec("2 == 3"), 0)
  lu.assertEquals(exec("3 == 3"), 1)
  lu.assertEquals(exec("2 != 3"), 1)
  lu.assertEquals(exec("3 != 3"), 0)

  -- Comparison ops have lower precedence than math
  lu.assertEquals(exec("2 > 4 - 3"), 1)
  lu.assertEquals(exec("2 >= 1 * 3"), 0)
  lu.assertEquals(exec("-12 - 12 != 4 * -6"), 0)
end

os.exit(lu.LuaUnit.run())
