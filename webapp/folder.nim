import htmlgen, strutils
import ".."/store, ".."/webConfig, ".."/jsreq, ".."/viewbase
import jester

proc lsFolderView*(links: seq[FolderEntry]): string =
  var output = newSeq[string]()
  template emitLink(link: FolderEntry, urlPrefix: string) =
    output.add(h3(a(href=("/" & urlPrefix & "/" & $link.id), link.name), "(" & urlPrefix.capitalizeAscii & ")"))
  for link in links:
    output.add("<div>")
    case link.entryType:
      of etFolder: emitLink(link, "folder")
      of etForm: emitLink(link, "form")
      of etSheet: emitLink(link, "sheet")
      of etScript: emitLink(link, "script")
    output.add("</div>")
  output.add(a(href="/create/0", "Create New..."))
  result = pageBase(output.join(""))

router folderRoutes:
  get "/@folderId":
    withDb(DB_FILE):
      resp lsFolderView(db.getFolderItems((@"folderId").parseInt))

