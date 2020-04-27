import os, strutils

proc envOrDefault(key, fallback: string): string =
  result = getEnv(key)
  if not existsEnv(key):
    result = fallback

let PORT*: int = envOrDefault("PORT", "19999").parseInt
let THEME*: string = envOrDefault("THEME", "AMBER")
let DB_FILE*: string = envOrDefault("DB_FILE", "tabula.sqlite")
let BIND_LOCAL_ONLY*: bool = envOrDefault("BIND_LOCAL_ONLY", "TRUE").toLowerAscii.parseBool
    
when isMainModule:
  echo "PORT=" & $PORT
  echo "THEME=" & THEME
  echo "DB_FILE=" & DB_FILE
  echo "BIND_LOCAL_ONLY=" & $BIND_LOCAL_ONLY
