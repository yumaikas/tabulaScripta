import ".."/store, ".."/webConfig, ".."/viewbase
import strutils, strformat, tables, htmlgen
import jester

# Algorithm is a nim port of https://stackoverflow.com/a/2652855/823592
proc numToAlpha(num: int): string =
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

proc colHeader(idx: int): CellContent =
  return CellContent(
    content: "<em>" & numToAlpha(idx) & "</em>",
    isUserReadOnly: true)

proc rowHeader(idx: int): CellContent =
  return CellContent(
    content:"<em>" & $idx & "</em>",
    isUserReadOnly: true)

proc sheetView*(sheet: SheetEntry): string =
  var output = newSeq[string]()
  output.add(h2("Tabula Scripta &gt; " & sheet.name))
  let extents = sheet.computeExtents()
  # Prepare the border rows/cells
  sheet.cells[(0,0)] = CellContent(isUserReadOnly: true)
  for rowIdx in 1..extents.rowMax:
    sheet.cells[(0, rowIdx)] = rowHeader(rowIdx)
  for colIdx in 1..extents.colMax:
    sheet.cells[(colIdx, 0)] = colHeader(colIdx)

  output.add("<table class=\"spreadSheet\">")
  for rowIdx in 0..extents.rowMax:
    output.add("<tr>")
    for colIdx in 0..extents.colMax:
      let cellKey = (colIdx, rowIdx)
      if not(sheet.cells.hasKey(cellKey)):
        output.add("<td>")
        output.add(input(`type`="text", value=""))
        output.add("</td>")
        continue
      let cell = sheet.cells[cellKey]
      output.add("<td>")
      if cell.isUserReadOnly:
        output.add(cell.content)
      else:
        output.add(input(`type`="text", value=cell.content))
      output.add("</td>")
    output.add("</tr>")
  result = pageBase(output.join(""))

router sheetRoutes:
  get "/@id":
    withDb(DB_FILE):
      let sheet = db.getSheet(@"id".parseInt)
      resp sheetView(sheet)
