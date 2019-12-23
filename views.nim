import store, webConfig
import sugar, strutils, strformat, tables
import htmlgen, markdown

proc css*(): string =
  # TODO: make this select from a list of themes, or pull from the database
  var back_color = "#191e2a"
  var fore_color = "#21EF9F"
  var link_color = "aqua"
  var visted_color = "darkcyan"
  if THEME == "AQUA":
    discard
  elif THEME == "AUTUMN":
    back_color = "#2a2319"
    fore_color = "#EFC121"
    link_color = "F0FF00"
    visted_color = "#a5622a"
  elif THEME == "AMBER":
    back_color = "black"
    fore_color = "yellow"
    link_color = "yellow"
    visted_color = "#f1ad14"

  # Right now, the implicit default theme is AQUA, if we don't recognize the current theme.

  return style(&"""
body {{
  max-width: 800px;
  width: 90%;
}}
body,input,textarea {{
  font-family: Iosevka, monospace;
  background: {back_color};
  color: {fore_color};
}}
table {{
  border-collapse: collapse;
}}
table input {{
  border: none;
}}
tr {{
  min-height: 20px;
}}
td {{
  margin: 5px;
  border: 1px solid {fore_color};
  min-width: 2em;
  min-height: 1em;
}}
a {{ color: {link_color}; }}
a:visited {{ color: {visted_color}; }}
""")

proc pageBase(inner: string, showHeader: bool = true): string =
  return "<!DOCTYPE html>" & html(
    head(
      meta(charset="utf-8"),
      meta(name="viewport", content="width=device-width, initial-scale=1.0"),
    ),
    body(
      css(),
      h2("Tabula Scripta"),
      inner
    )
  )

proc homeView*(links: seq[FolderEntry]): string =
  var output = newSeq[string]()

  template emitLink(link: FolderEntry, urlPrefix: string) =
    output.add(h3(a(href=(urlPrefix & $link.id), link.name)))
  for link in links:
    output.add("<div>")
    case link.entryType:
      of etFolder: emitLink(link, "/folder/")
      of etForm: emitLink(link, "/form/")
      of etSheet: emitLink(link, "/sheet/")
      of etScript: emitLink(link, "/script")
    output.add("</div>")
  output.add(a(href="/create/0", "Create New..."))
  result = pageBase(output.join(""))

proc createView*(folderId: int): string =
  proc btn(url, text: string): string =
    return button(formaction=url & $folderId, formmethod="POST", text)

  result = pageBase(
    form(enctype="multipart/form-data", action="POST",
      style("button { display: block; }"),
      label("Name:", input(name="name", id="name", type="text")),
      btn("/create/sheet/", "Create Spreadsheet"),
      btn("/create/form/", "Create Form"),
      btn("/create/folder/", "Create Folder"),
      btn("/create/script/", "Create Script"),
  ))

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

  output.add("<table>")
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
  
# HTML inputs for editing various fields on ideas

# proc notesEditor(idea: Idea): string =
#  return textarea(name="notes", rows="50", cols="75", idea.content)

proc tableWith(inner: () -> string): string =
  var output = newSeq[string]()
  output.add("<table>")
  output.add(inner())
  output.add("</table>")
  return output.join("\n")


proc errorPage*(message: string): string =
  return pageBase(message)
  
