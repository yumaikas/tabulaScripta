import db_sqlite, sequtils, strformat, strutils, os

type 
  Database* = ref object
    db*: DbConn

  # A cell for a spreadsheet
  Cell* = object
    col*: int
    row*: int
    content*: string


proc newDatabase*(filename = "tabulascripting.db"): Database =
  new result
  result.db = open(filename, "", "", "")

proc close*(database: Database) =
  database.db.close()

proc saveCells*(db: Database, SheetId: int, cells: seq[Cell]) =
  let conn = db.db
  for cell in cells:
    conn.exec(sql"""
      Insert Into Cells(SheetId, RowId, ColumnId, Content) 
      values (?,?,?,?);""",
      SheetId, cell.row, cell.col, cell.content )

type CellRange = object
  rowBegin*: int
  rowEnd*: int
  colBegin*: int
  colEnd*: int

proc initRange(rowBegin, rowEnd, colBegin, colEnd: int): CellRange =
  return CellRange(
    rowBegin: rowBegin,
    rowEnd: rowEnd,
    colBegin: colBegin,
    colEnd: colEnd)

# Don't think I need this here
#[
proc getGrid*(db: Database, SheetId: int, x,y,h,w: int: seq[seq[Cell]] =
  let r = initRange(x, y, x + h, y + w)
  let cells = db.getCells(SheetId, r)
  result = newSeq[seq[cell]]()
  result.setLen(w)
  for i in 0..w:

]#


proc getCells*(db: Database, SheetId: int, area: CellRange ): seq[Cell] =
  let conn = db.db
  result = newSeq[Cell]()
  let query = sql"""
  Select RowId, ColumnId, Content from Cells
  where SheetId = ?
    AND (RowId <= ? AND RowId >= ?) 
    AND (ColumnId <= ? AND ColumnId >= ?);
  """
  template args(SheetId: int, r: CellRange): untyped =
    @[$SheetId, $r.rowEnd, $r.rowBegin, $r.colEnd, $r.colBegin]

  for row in conn.fastRows(query, args(SheetId, area)):
    result.add(Cell(
      row: row[0].parseInt,
      col: row[1].parseInt,
      content: row[2]
    ))

proc setup*(database: Database) =
  let db = database.db
  db.exec(sql"""
  Create Table if not exists Sheets (
    SheetId INTEGER PRIMARY KEY,
    Name text,
    Created int, -- unix timestamp
    Updated int, -- unix timestamp
    Deleted int -- unix timestamp
  );""")

  db.exec(sql"""
  Create Table if not exists Cells (
    CellId INTEGER PRIMARY KEY,
    SheetId int,
    RowId int,
    ColumnId int,
    Content text,
    UNIQUE(SheetId, RowId, ColumnId) ON CONFLICT REPLACE
  );""")

  db.exec(sql"""
  Create Table if not exists Scripts (
    ScriptId INTEGER PRIMARY KEY,
    Name text,
    Content text,
    Created int, -- unix timestamp
    Updated int, -- unix timestamp
    Deleted int -- unix timestamp
  );""")

  db.exec(sql"""
  Create Table if not exists Forms (
    FormId INTEGER PRIMARY KEY,
    Name text,
    Content text,
    Created int, -- unix timestamp
    Updated int, -- unix timestamp
    Deleted int -- unix timestamp
  );
  """)

when isMainModule:
  var db = newDatabase("test.db")
  db.setup()

  db.saveCells(0, @[
    Cell(row:1, col:1, content: "A"),
    Cell(row:1, col:2, content: "B"),
    Cell(row:1, col:3, content: "C"),
    Cell(row:1, col:4, content: "D"),
    Cell(row:1, col:5, content: "E")
  ])
  echo db.getCells(0, initRange(1,1,2,4))
  db.close()
  removeFile("test.db")

