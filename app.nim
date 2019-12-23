import jester

import webConfig, views, store
import seqUtils, tables, strutils
from nativesockets import Port

var bindAddr = "localhost"

if not BIND_LOCAL_ONLY:
  bindAddr = "0.0.0.0"

proc init() =
  withDb(DB_FILE):
    db.setup()
init()

settings:
  port = nativesockets.Port(webConfig.PORT)
  bindAddr = bindAddr

routes:
  get "/":
    # TODO: This is a test view for now
    resp homeView(@[
      FolderEntry(id:(-1), name:"Test Sheet", entryType: etSheet),
      FolderEntry(id:(-2), name:"Test Sheet 1", entryType: etSheet)
    ])
  get "/sheet/-1":
    let cells = newTable(@[
        ((1, 1), CellContent(content: "Test", isUserReadOnly: false)),
        ((1, 2), CellContent(content: "Test 1", isUserReadOnly: false)),
        ((1, 3), CellContent(content: "test 2", isUserReadOnly: false)),
        ((1, 4), CellContent(content: "Foo", isUserReadOnly: false)),
        ((37, 5), CellContent(content: "Crackers", isUserReadOnly: false))
        ])

    resp sheetView(SheetEntry(id: (-1), name: "Test Sheet", cells: cells))
  get "/create/@folderId":
    # TODO: Build up the current folder hierarchy
    resp createView((@"folderId").parseInt)

  get "/folder/@id":
    resp "TODO: A list of the items under this folder"
     
  get "/form/@id":
    resp "TODO: Form by Id"

  get "/edit/form/@id":
    resp "TODO: Show form editor"

  get "/sheet/@id":
    withDb(DB_FILE):
      let sheet = db.getSheet(@"id".parseInt)
      resp sheetView(sheet)

  get "/script/@id":
    resp "TODO: Script by Id"

  post "/create/form/@folderId":
    withDb(DB_FILE):
      let formData = request.formData
      assert "name" in formData
      let formId = db.createForm(formData["name"].body)
      redirect("/form/" & $formId)

  post "/create/sheet/@folderId":
    withDb(DB_FILE):
      let formData = request.formData
      assert "name" in formData
      let sheetId = db.createSheet(formData["name"].body)
      redirect("/sheet/" & $sheetId)

  post "/create/folder":
    resp "TODO: Redirect to newly created folder"
  post "/create/script/":
    resp "TODO: Redirect to newly created script"


  post "/saveData/@sheetId":
    resp "TODO: Take a JSON object of kv pairs, and save it into the database, then return any updates that happened as a result of updating formulas"

  post "/getData/@sheetId":
    resp """TODO: Take JSON array of key ranges.
      A key range has the sheet guid, and then the 2D range of values to be selected from the sheet. An empty range gets *all* the values for the sheet.
    """
  
