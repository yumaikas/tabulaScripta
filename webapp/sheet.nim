import ".."/store, ".."/webConfig, ".."/viewbase
import strutils, strformat, tables
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

router sheetRoutes:
  get "/view/@id":
    resp sheetSPA((@"id").parseInt)
  # get "/api/@id":
    # resp 
    #[
  get "/@id":
    withDb(DB_FILE):
      let sheet = db.getSheet(@"id".parseInt)
      resp sheetView(sheet)
      ]#
