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

local WORKDIR = os.getenv("DIR")
local function loadFile(name)
  local file = io.open((WORKDIR or ".") .. "/srcs/" .. name, "r")
  if (not file) then error('file not found') end
  local content = file:read("*a")
  io.close(file)
  return content;
end

function TestNotOperator()

end

os.exit(lu.LuaUnit.run())
