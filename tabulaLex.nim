import strutils
import strtabs
import tables

type 
  token* = ref object
    message*: string
    value*: string
  tokenFunc* = proc(message: string): token

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
  # Build up current token until we hit a space, a [ or a "
  var idx = 0;
  proc eatSpace() =
    if idx >= code.len:
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
      
      result = tokVal(code.substr(idx+1, seekIdx - 1))
      idx = seekIdx + 1
      return
    if c == '"':
      var seekIdx = idx + 1
      while code[seekIdx] != '"':
        inc(seekIdx)
        if seekIdx >= len(code):
          tokDie("Unclosed '\"'!")
      result = tokVal(code.substr(idx + 1, seekIdx - 1))
      idx = seekIdx + 1
      return
    var seekIdx = idx + 1
    while seekIdx < len(code) and not(isSpace(code[seekIdx])):
      inc(seekIdx)
      if seekIdx >= len(code):
        result = tokVal(code.substr(idx, seekIdx - 1))
        idx = seekIdx + 1
        return
    result = tokVal(code.substr(idx, seekIdx - 1))
    idx = seekIdx + 1
    return

  return nextToken

