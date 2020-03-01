import htmlgen, strutils, json
import ".."/store, ".."/webConfig, ".."/jsreq, ".."/viewbase
import jester

proc createView*(folderId: int): string =
  proc btn(url, text: string): string =
    return button(formaction=url & $folderId, formmethod="POST", text)

  result = pageBase(
    form(enctype="multipart/form-data", `method`="POST",
      style("button { display: block; }"),
      label("Create a ",
      select(name="typeToCreate", id="thingToCreate",
        option(value="sheet", "Spreadsheet"),
        option(value="folder", "Folder"),
        option(value="form", "Form"),
        option(value="script", "Script")
      )),
      label("named: ",
        input(name="name", id="name", type="text")
      ),
      button(id="btnSubmit", "Submit"),
      # Load things up after the rest of the DOM has been defined
      requireScript("/scripts/create.js"),
      script("tabulaCreate.onload()")
  ))

router creatorRoutes:
  get "/@folderId":
    resp createView((@"folderId").parseInt)
  
  post "/api/@folderId":
    withDb(DB_FILE):
      let formData = request.formData
      let parentFolderId = (@"folderId").parseInt
      assert "name" in formData
      let name = formData["name"].body
      let entryType = formData["entryType"].body
      if entryType == "etForm":
        let formId = db.createForm(name, parentFolderId)
        resp $formId, "application/json"
      elif entryType == "etSheet":
        let formId = db.createSheet(name, parentFolderId)
        resp $formId, "application/json"
      elif entryType == "etFolder":
        let formId = db.createFolder(name, parentFolderId)
        resp $formId, "application/json"
      elif entryType == "etScript":
        let formId = db.createScript(name, parentFolderId)
        resp $formId, "application/json"
      else:
        resp Http400, "Invalid entryType!", "text/html"


