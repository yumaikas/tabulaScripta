import store, webConfig
import sugar, strutils, strformat
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
td {{ margin: 5px; }}
a {{ color: {link_color}; }}
a:visited {{ color: {visted_color}; }}
""")


proc pageBase(inner: string): string =
  return "<!DOCTYPE html>" & html(
    head(
      meta(charset="utf-8"),
      meta(name="viewport", content="width=device-width, initial-scale=1.0"),
    ),
    body(
      css(),
      inner
    )
  )

proc homeView*(links: seq[FolderEntry]): string =
  var output = newSeq[string]()

  output.add(h2("Tabula Scripta"))
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

  
