import strutils, htmlgen, os

# Assumes a path where client is the root
proc requireScript*(path: string): string {.compileTime.} =
  var f = staticRead(joinPath("client", path)).splitLines
  var output = newSeq[string]()
  for line in f:
    if not line.startsWith("// require: "):
      break
    let reqPath = line.replace("// require: ", "")
    output.add(script(src=reqPath))
  output.add(script(src=path))
  return output.join("\n")


var myGlobal = "junk"
proc requireScriptDebug*(path: string): string  =
  ## Should only work with threads *off*
  # Keep from compiling with "Theads:on"
  myGlobal = "junk"
  var f = open(joinPath("client", path))
  defer: f.close()
  var output = newSeq[string]()
  while true:
    let line = f.readLine()
    if not line.startsWith("// require: "):
      break
    let reqPath = line.replace("// require: ", "")
    output.add(script(src=reqPath))
  output.add(script(src=path))
  return output.join("\n")
    
when isMainModule:
  echo requireScript("/scripts/sheet.js")


