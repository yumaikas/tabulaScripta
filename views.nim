import store, webConfig, jsreq, viewbase
import sugar, strutils, strformat, tables
import htmlgen, markdown

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
  
