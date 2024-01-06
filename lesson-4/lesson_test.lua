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

-- CP 5 / Error messages with line numbers
-- Extend [lang] to provide error messages with line numbers for malformatted
-- inputs.
function TestErrorMessagesWithLineNumber()
  print("foo")
  print("bar")
  lang.parse("hello = 1");

  print(pt.pt(console))
end

os.exit(lu.LuaUnit.run())
