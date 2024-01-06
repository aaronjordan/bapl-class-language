local lang = require "interpreter"
local lu = require "luaunit"
local pt = require "pt"

-- 0. Redirect print() function for easier testability
local sysprint = print
local console = {}
local outputNumber = 1
console.write = function(str)
  console[outputNumber] = str
  outputNumber = outputNumber + 1
  sysprint(str) -- retain typical print too
end
print = console.write

local function loadFile(name)
  local file = io.open("./srcs/" .. name, "r")
  if (not file) then error('file not found') end
  local content = file:read("a")
  io.close(file)
  return content;
end

-- CP 5 / Error messages with line numbers
-- Extend [lang] to provide error messages with line numbers for malformatted
-- inputs.
function TestErrorMessagesWithLineNumber()
  local FILENAME = 1
  local ERR_MSG = 2

  local cases = {
    { "syntax_err_1.yum", "error near line 6" },
    { "syntax_err_2.yum", "error near line 5" },
  }

  for i = 1, #cases do
    lang.parse(loadFile(cases[i][FILENAME]))
    pt.pt(console)

    lu.assertStrContains(console[outputNumber - 1], cases[i][ERR_MSG]);
  end
end

-- CP 7 / Block comments
-- Extend [lang] to enable block comments.
function TestBlockComments()
  -- lang can parse file containing a block comment
  local fname = "with_comments.yum"

  local ast = lang.parse(loadFile(fname))
  lu.assertNotNil(ast)
end

-- CP 9 / Alternative for reserved words
-- Extend [lang] to identify uses of reserved words in a match-time capture.
function TestReservedWordAlternate()
  local fname = "reserved_word_invalid_use.yum"

  lang.parse(loadFile(fname))
  lu.assertStrContains(console[outputNumber - 2], "invalid use of reserved word")
  lu.assertStrContains(console[outputNumber - 1], "error near line 10")
end

os.exit(lu.LuaUnit.run())
