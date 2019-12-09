import jester

import webConfig, views, store, seqUtils
from nativesockets import Port

var bindAddr = "localhost"

if not BIND_LOCAL_ONLY:
  bindAddr = "0.0.0.0"

settings:
  port = nativesockets.Port(webConfig.PORT)
  bindAddr = bindAddr


routes:
  get "/":
    # TODO: This is a test view for now
    resp homeView(@[
      FolderEntry(id:0, name:"Test Sheet", entryType: etSheet),
      FolderEntry(id:1, name:"Test Sheet 1", entryType: etSheet)
    ])


  get "/folder/@id":
    resp "TODO: A list of the items under this folder"
     
  get "/form/@id":
    resp "TODO: Form by Id"

  get "/edit/form/@id":
    resp "TODO: Show form editor"

  post "/create/form/":
    resp "TODO: Redirect to newly created form"

  get "/sheet/@id":
    resp "TODO: Sheet by Id"
  get "/script/@id":
    resp "TODO: Script by Id"

  post "/saveData":
    resp "TODO: Take a JSON object of kv pairs, and save it into the database, then return any updates that happened as a result of updating formulas"

  post "/getData":
    resp """TODO: Take JSON array of key ranges.
      A key range has the sheet guid, and then the 2D range of values to be selected from the sheet. An empty range gets *all* the values for the sheet.
    """
  
