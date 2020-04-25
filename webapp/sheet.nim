import ".."/store, ".."/webConfig, ".."/viewbase
import strutils, tables, json
from strformat import fmt
import jester

# Algorithm is a nim port of https://stackoverflow.com/a/2652855/823592

proc sheetSPA*(sheetId: int): string =
  return pageBase(fmt"""
  <div id="sheetApp"></div>
  <input type="hidden" id="sheetId" name="sheetId" value="{$sheetId}"/>
  <script src="/sheetApp.js"></script>
""")

proc sheetJson*() =
  discard

type cellToSave* = object

  input*: string
  output*: string
  attrs*: Table[string, string]

type cellSaveRequest* = object 
  cells*: seq[cellToSave]

router sheetRoutes:
  import json
  get "/view/@id":
    resp sheetSPA((@"id").parseInt)
  get "/api/data/@id":
    withDb(DB_FILE):
      let sheet = db.getSheet(@"id".parseInt)
      # TODO: Add in something that handles formulas here
      resp(Http200, $(%*(sheet)), "application/json")
  post "/api/data/@id":
    withDb(DB_FILE):
      let sheetId = (@"id").parseInt
      let saveReq = parseJson(request.body).to(cellSaveRequest)
      var cells = newSeq[Cell]()
      for c in saveReq.cells:
        cells.add(Cell(
        # TODO: Finish this up
        ))
      db.saveCells(sheetId, cells);
      # This needs to respond with 
      resp(Http200, "", "text/html")
