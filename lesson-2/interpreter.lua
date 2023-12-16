local lpeg = require "lpeg"
local pt = require "pt"

----------------------------------------------------
local function node(num)
  return { tag = "number", val = tonumber(num) }
end

local space = lpeg.S(" \t\n") ^ 0

local b10int = lpeg.R("09") ^ 1
local fp = "." * lpeg.R("09") ^ 1
local enot = lpeg.S("eE") * lpeg.S("+-") ^ -1 * b10int
local tail = fp + enot

local b10num = b10int * tail ^ -1 / node
local b16 = ("0" * lpeg.S("xX") * lpeg.R("09", "AF", "af") ^ 1) / node
local numeral = b16 + b10num * space

local OP = "(" * space
local CP = ")" * space

local opC = lpeg.C(lpeg.P ">=" + "<=" + "==" + "!=" + ">" + "<") * space
local opA = lpeg.C(lpeg.S "+-") * space
local opM = lpeg.C(lpeg.S "*/%") * space
local opE = lpeg.C(lpeg.S "^") * space
local opPre = lpeg.C(lpeg.S "-") * space


-- Convert a list {n1, "+", n2, "+", n3, ...} into a tree
-- {...{ op = "+", e1 = {op = "+", e1 = n1, n2 = n2}, e2 = n3}...}
local function foldBin(lst)
  local tree = lst[1]
  for i = 2, #lst, 2 do
    tree = { tag = "binop", e1 = tree, op = lst[i], e2 = lst[i + 1] }
  end
  return tree
end

local function foldPrefix(lst)
  return { tag = "prefix", op = lst[1], e1 = lst[2] }
end

local factor = lpeg.V "factor"
local pre = lpeg.V "pre"
local pow = lpeg.V "pow"
local term = lpeg.V "term"
local exp = lpeg.V "exp"
local comp = lpeg.V "comp"

grammar = lpeg.P { "comp",
  factor = numeral + OP * comp * CP,
  pre = lpeg.Ct(opPre * factor) / foldPrefix + factor,
  pow = lpeg.Ct(pre * (opE * pre) ^ 0) / foldBin,
  term = lpeg.Ct(pow * (opM * pow) ^ 0) / foldBin,
  exp = lpeg.Ct(term * (opA * term) ^ 0) / foldBin,
  comp = lpeg.Ct(exp * (opC * exp) ^ 0) / foldBin,
}

grammar = space * grammar * -1

local function parse(input)
  return grammar:match(input)
end

----------------------------------------------------

local function addCode(state, op)
  local code = state.code
  code[#code + 1] = op
end


local ops = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "div",
  ["%"] = "mod",
  ["^"] = "pow",
  [">"] = "gt",
  ["<"] = "lt",
  [">="] = "gte",
  ["<="] = "lte",
  ["=="] = "eq",
  ["!="] = "ne",
}

local pre = {
  ["-"] = "neg",
}

local function codeExp(state, ast)
  if ast.tag == "number" then
    addCode(state, "push")
    addCode(state, ast.val)
  elseif ast.tag == "prefix" then
    codeExp(state, ast.e1)
    addCode(state, pre[ast.op])
  elseif ast.tag == "binop" then
    codeExp(state, ast.e1)
    codeExp(state, ast.e2)
    addCode(state, ops[ast.op])
  else
    error("invalid tree")
  end
end

local function compile(ast)
  local state = { code = {} }
  codeExp(state, ast)
  return state.code
end

----------------------------------------------------

local function logOutput(result)
  print("\t=> " .. result)
end

local function run(code, stack)
  local pc = 1
  local top = 0
  while pc <= #code do
    local args = code[pc] == "push" and code[pc + 1] or ""
    print("[op" .. pc .. "]: " .. code[pc] .. "(" .. args .. ")")
    if code[pc] == "push" then
      pc = pc + 1
      top = top + 1
      stack[top] = code[pc]
    elseif code[pc] == "add" then
      stack[top - 1] = stack[top - 1] + stack[top]
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "sub" then
      stack[top - 1] = stack[top - 1] - stack[top]
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "mul" then
      stack[top - 1] = stack[top - 1] * stack[top]
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "div" then
      stack[top - 1] = stack[top - 1] / stack[top]
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "mod" then
      stack[top - 1] = stack[top - 1] % stack[top]
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "pow" then
      stack[top - 1] = stack[top - 1] ^ stack[top]
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "gt" then
      stack[top - 1] = stack[top - 1] > stack[top] and 1 or 0
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "lt" then
      stack[top - 1] = stack[top - 1] < stack[top] and 1 or 0
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "gte" then
      stack[top - 1] = stack[top - 1] >= stack[top] and 1 or 0
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "lte" then
      stack[top - 1] = stack[top - 1] <= stack[top] and 1 or 0
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "eq" then
      stack[top - 1] = stack[top - 1] == stack[top] and 1 or 0
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "ne" then
      stack[top - 1] = stack[top - 1] ~= stack[top] and 1 or 0
      top = top - 1
      logOutput(stack[top])
    elseif code[pc] == "neg" then
      stack[top] = -stack[top]
      logOutput(stack[top])
    else
      error("unknown instruction")
    end
    pc = pc + 1
  end
end


-- local input = io.read("a")
-- local ast = parse(input)
-- print(pt.pt(ast))
-- local code = compile(ast)
-- print(pt.pt(code))
-- local stack = {}
-- run(code, stack)
-- print(stack[1])

return {
  parse = parse,
  compile = compile,
  run = run,
}
