import htmlgen, strutils
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

  post "/form/@folderId":
    withDb(DB_FILE):
      let formData = request.formData
      let parentFolderId = (@"folderId").parseInt
      assert "name" in formData
      let formId = db.createForm(formData["name"].body, parentFolderId)
      redirect("/form/" & $formId)

  post "/sheet/@folderId":
    withDb(DB_FILE):
      let formData = request.formData
      let parentFolderId = (@"folderId").parseInt
      assert "name" in formData
      let sheetId = db.createSheet(formData["name"].body, parentFolderId)
      redirect("/form/" & $sheetId)

  post "/folder/@folderId":
    withDb(DB_FILE):
      let formData = request.formData
      let parentFolderId = (@"folderId").parseInt
      assert "name" in formData
      let folderId = db.createFolder(formData["name"].body, parentFolderId)
      redirect("/folder/" & $folderId)

  post "/script/@folderId":
    withDb(DB_FILE):
      let formData = request.formData
      let parentFolderId = (@"folderId").parseInt
      assert "name" in formData
      let folderId = db.createScript(formData["name"].body, parentFolderId)
      redirect("/script/" & $folderId)


