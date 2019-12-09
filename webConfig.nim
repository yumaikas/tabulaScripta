import os, strutils

proc envOrDefault(key, fallback: string): string =
  result = getEnv(key)
  if not existsEnv(key):
    result = fallback

let PORT*: int = envOrDefault("PORT", "19999").parseInt
let THEME*: string = envOrDefault("THEME", "AQUA")
let DB_FILE*: string = envOrDefault("DB_FILE", "tabula.sqlite")
let BIND_LOCAL_ONLY*: bool = envOrDefault("BIND_LOCAL_ONLY", "TRUE").toLowerAscii.parseBool
    
