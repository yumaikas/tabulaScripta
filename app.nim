import jester

import webConfig, views, store
import seqUtils, tables, strutils
from nativesockets import Port
import webapp/create, webapp/sheet, webapp/folder, webapp/form

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
  staticDir = "./static"

routes:
  get "/":
    withDb(DB_FILE):
      resp lsFolderView(db.getFolderItems(0))

  get "/script/@id":
    resp "TODO: Script by Id"

  post "/saveData/@sheetId":
    resp "TODO: Take a JSON object of kv pairs, and save it into the database, then return any updates that happened as a result of updating formulas"

  post "/getData/@sheetId":
    resp """TODO: Take JSON array of key ranges.
      A key range has the sheet guid, and then the 2D range of values to be selected from the sheet. An empty range gets *all* the values for the sheet.
    """
  extend formRoutes, "/form"
  extend folderRoutes, "/folder"
  extend sheetRoutes, "/sheet"
  extend creatorRoutes, "/create"
  
