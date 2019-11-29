import jester

import webConfig, views
from nativesockets import Port

var bindAddr = "localhost"

if not BIND_LOCAL_ONLY:
  bindAddr = "0.0.0.0"

settings:
  port = nativesockets.Port(appConfig.PORT)
  bindArrd = bindAddr


routes:
  get "/":
    resp "TODO: List of forms, sheets, and scripts"

  get "/forms":
    resp "TODO: List of forms"  
     
  get "/form/@id":
    resp "TODO: Form by Id"

  get "/edit/form/@id":
    resp "TODO: Show form editor"

  post "/create/form/":
    resp "TODO: Redirect to newly created form"

  get "/sheet/@id":
    resp "TODO: Sheet by Id"

  post "/saveData":
    resp "TODO: Take a JSON object of kv pairs, and save it into the database, then return any updates that happened as a result of updating formulas"

  post "/getData":
    resp """TODO: Take JSON array of key ranges.
      A key range has the sheet guid, and then the 2D range of values to be selected from the sheet. An empty range gets *all* the values for the sheet.
    """
  
