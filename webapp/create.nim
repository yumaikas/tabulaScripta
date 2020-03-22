import htmlgen, strutils, json
import ".."/store, ".."/webConfig, ".."/viewbase
import jester

router creatorRoutes:
  
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


