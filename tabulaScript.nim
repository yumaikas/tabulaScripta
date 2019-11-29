import strutils
import strtabs
import tables

type token* = ref object
  message*: string
  value*: string

proc tokMsg(msg: string): token =
  result = token(message: msg)

proc tokVal(value: string): token =
  result = token(value: value)

type TokenException = object of Exception

proc tokDie(msg: string) =
  raise newException(TokenException, msg)

proc isSpace(c: char): bool =
  return c == ' ' or c == '\t' or c == '\r' or c == '\n'

proc tokenize*(code: string): proc(message: string): token =
  var tok = ""
  
  # Build up current token until we hit a space, a [ or a "
  
  var idx = 0;
  proc eatSpace() =
    if idx > code.len:
      return
    while isSpace(code[idx]):
      if idx >= code.len: return
      idx += 1

  proc nextToken(message: string): token =
    eatSpace()
    if (idx >= code.len): return tokMsg("EOF!")
    var c = code[idx]
    if c == '[':
      var seekIdx = idx
      var depth = 1
      while depth > 0:
        inc(seekIdx)
        if seekIdx >= len(code):
          tokDie("Unclosed '[' string")
        if code[seekIdx] == '[': inc(depth)
        if code[seekIdx] == ']': dec(depth)
        if depth < 0: tokDie("Unexpected ]")
      
      result = tokVal(code.substr(idx+1, seekIdx))
      idx = seekIdx + 1
      return
    if c == '"':
      var seekIdx = idx + 1
      while code[seekIdx] != '"':
        inc(seekIdx)
        if seekIdx >= len(code):
          tokDie("Unclosed '\"'!")
      result = tokVal(code.substr(idx + 1, seekIdx))
      idx = seekIdx + 1
      return
    var seekIdx = idx + 1
    while not(isSpace(code[seekIdx])):
      inc(seekIdx)
      if seekIdx >= len(code):
        result = tokVal(code.substr(idx, seekIdx))
        idx = seekIdx
        return
    result = tokVal(code.substr(idx, seekIdx))
    idx = seekIdx
    return

  return nextToken

#[
proc tabulaRun*(
  code: string,
  stack: var seq[string],
  env: var TableRef[string, proc(next: proc():token, vals: StringTableRef)],
  vals: StringTableRef) =
]#


proc tabulaExec(
  next: proc(): token,
  stack: var seq[string],
  env: var TableRef[string, proc(next: proc():token, vals: StringTableRef)],
  vals: var StringTableRef) =
  var tok = next()
  while len(tok.message) <= 0:
    if env.hasKey(tok.value):
      env[tok.value](next, vals)
    else:
      stack.add(tok.value)
    tok = next()

proc initTabulaEnv(stack: seq[string]): TableRef[string, proc(next: proc():token, vals: StringTableRef)] =
  var env = newTable[string, proc(next: proc():token, vals: StringTableRef)]()
  env["t"] = proc(next: proc(): token, vals: StringTableRef) =
    stack.add($true)
  env["f"] = proc(next: proc(): token, vals: StringTableRef) =
    stack.add($false)
  env["echo"] = proc(next: proc(): token, vals: StringTableRef) =
    echo stack.pop()



proc tabulaRun*(code: string) =
  var stack = newSeq[string]()
  var vals = newStringTable(modeCaseSensitive)
  var env = initTabulaEnv(stack)
  var inext = tokenize(code)
  proc next(): token = inext("dummy")
  tabulaExec(next, stack, env, vals)
  echo stack.repr

when isMainModule:
  tabulaRun("f f t echo")
