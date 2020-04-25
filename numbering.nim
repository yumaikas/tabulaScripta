
# This module is here because it might end up being used in a number of places,
proc numToAlpha*(num: int): string =
  if num <= 26:
    return $chr(num + 64)
  var acc: int = num
  result = ""
  var d = acc div 26
  var rem = acc mod 26
  if rem == 0:
    rem = 26
    dec(d)
  return numToAlpha(d) & numToAlpha(rem)


when isMainModule:
  discard
  # TODO: Tests

