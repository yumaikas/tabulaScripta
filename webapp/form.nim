import htmlgen, strutils
import ".."/store, ".."/webConfig, ".."/jsreq, ".."/viewbase
import jester

proc formEditorView*(entry: FormEntry): string =
  var output = newSeq[string]()
  output.add(div(h2("&gt; " & entry.name)))
  output.add(textarea(
    id="script",
    entry.script
  ))
  result = pageBase(output.join(""))

router formRoutes:
  get "/edit/@formId":
    withDb(DB_FILE):
      resp formEditorView(db.getForm((@"formId").parseInt))
  get "/view/@formId":
    resp "TODO: Execute form script, show results"

