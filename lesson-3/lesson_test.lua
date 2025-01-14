local lang = require "interpreter"
local lu = require "luaunit"

local function extractFirstVarName(ast)
  return (ast.exp or {}).var
end

-- CP 2 / Rules for Identifiers
-- Extend [lang] to support underscores in variable names
function TestCheckIsValidIdentifier()
  local names = { "apple", "apple2", "apple_sauce", "_apple", "_2" }

  for i = 1, #names do
    local src = "return " .. names[i]
    local ast = lang.parse(src)
    lu.assertEquals(extractFirstVarName(ast), names[i])
  end
end

-- CP 5 / Empty Statement
-- Allow extra semicolons and empty blocks in the language
function TestOptionalExtraSemicolons()
  local samples = {
    "x = 2; y = 3; return x + y",
    "x = 2; y = 3;; return x + y",
    "x = 2; y = 3; return x + y;",
    "{x = 2; y = 3;}; return x + y",
    "{x = 2; y = 3;}; {}; return x + y",
  }

  for i = 1, #samples do
    local ast = lang.parse(samples[i])
    lu.assertNotNil(ast)
  end
end

-- CP 7 / Print Statement
-- Add an `@ exp` syntax for printing an expression
function TestPrintStatement()
  local samples = {
    "@12",
    "@ 12",
    "@ 3+14",
    "x = 4; @x",
  }

  print('should print 12, 12, 17, 4:')
  for i = 1, #samples do
    local ast = lang.parse(samples[i])
    local cmp = lang.compile(ast)
    lang.run(cmp, {}, {})
  end
end

-- CP 9 / Undefined variables
-- Throw when dereferencing a variable that has not been set
function TestUndefinedVarError()
  local samples = {
    { true,  "x = y", },
    { false, "x = 4; return x", },
    { true,  "return apple", },
  }


  for i = 1, #samples do
    local shouldThrow = samples[i][1]
    print("parse: " .. samples[i][2])
    local ast = lang.parse(samples[i][2])

    if shouldThrow then
      lu.assertError(lang.compile, ast)
    else
      local state = {}
      lang.run(lang.compile(ast), state, {})
      lu.assertNotNil(state[1])
    end
  end
end

os.exit(lu.LuaUnit.run())
