import strtabs, tables, strutils
import tabulaLex

type 
  TabulaType = enum
    tNumber,
    tInt,
    tString,
    tBool,
    tTable, # TabulaTables are 1/2d collections of cells
    tObject, # tObjects, for now, are HashTable[TabulaValue, TabulaValue] ? I know that I want to make them more capable than PISC tables...
    tFunc

  TabulaTable = TableRef[(int, int), TabulaValue]

  TabulaFunc = proc(vm: tabulaVM, next: tokenFunc)

  TabulaValue = ref object
    case ttype: TabulaType
    of tInt: intValue: int
    of tNumber: numValue: float
    of tString: strValue: string
    of tBool: boolValue: bool
    of tTable: tableValue: TabulaTable
    of tObject: objectValue: TableRef[ref TabulaValue, ref TabulaValue]
    of tFunc: funcValue: TabulaFunc

  tabulaVM* = ref object
    stack*: seq[TabulaValue]
    env*: TableRef[string, TabulaFunc]
    vals*: StringTableRef

proc `$`(me: TabulaValue): string =
  result = (case me.ttype:
    of tString: me.strValue
    of tInt: $(me.intValue)
    of tNumber: $(me.numValue)
    of tBool: $(me.boolValue)
    else:
      $(me))


proc push(vm: tabulaVM, b: bool) =
  vm.stack.add(TabulaValue(ttype: tBool, boolValue: b))
  
proc push(vm: tabulaVM, s: string) =
  vm.stack.add(TabulaValue(ttype: tString, strValue: s))

proc push(vm: tabulaVM, i: int) =
  vm.stack.add(TabulaValue(ttype: tInt, intValue: i))

proc push(vm: tabulaVM, f: float) =
  vm.stack.add(TabulaValue(ttype: tNumber, numValue: f))

proc push(vm: tabulaVM, tVal: TabulaValue) =
  vm.stack.add(tVal)

proc tEq(tVal: TabulaValue, b: bool): bool =
  result = tVal.ttype == tBool and tVal.boolValue == b

proc tEq(tVal: TabulaValue, i: int): bool =
  result = tVal.ttype == tInt and tVal.intValue == i

proc tEq(tVal: TabulaValue, f: float): bool =
  result = tVal.ttype == tNumber and tVal.numValue == f

proc tEq(tVal: TabulaValue, str: string): bool =
  result = tVal.ttype == tString and tVal.strValue == str

proc tabulaExec(vm: tabulaVM, next: tokenFunc)

proc initVMEnv(vm: tabulaVM) =

  template vmFunc(code: untyped): untyped =
    (proc (vmachine: tabulaVM, nextFn: tokenFunc) =
      var vm {.inject.} = vmachine
      let next {.inject.} = nextFn
      code
    )
  template binaryOp(code: untyped): untyped =
    vmFunc:
      let b {.inject.} = vm.stack.pop()
      let a {.inject.} = vm.stack.pop()
      vm.push(code)

  template mathBinaryOp(code: untyped): untyped =
    vmFunc:
      let yVal = vm.stack.pop()
      let ty = yVal.ttype
      let xVal = vm.stack.pop()
      let tx = xVal.ttype
      if tx == tNumber and ty == tNumber:
        let y {.inject.} = yVal.numValue
        let x {.inject.} = xVal.numValue
        vm.push(code)
      elif tx == tInt and ty == tInt:
        let y {.inject.} = yVal.intValue
        let x {.inject.} = xVal.intValue
        vm.push(code)
      else:
        raise newException(Exception, "Cannot do path to non-numbers or numbers that do not have matching types!")

  vm.env["t"] = vmFunc(vm.push(true))
  vm.env["f"] = vmFunc(vm.push(false))
  vm.env["concat"] = binaryOp($a & $b)
  vm.env["+"] = mathBinaryOp(x + y)
  vm.env["-"] = mathBinaryOp(x - y)
  vm.env["/"] = mathBinaryOp(x / y)
  vm.env["*"] = mathBinaryOp(x * y)

  vm.env["dup"] = vmFunc:
    let val = vm.stack.pop()
    vm.push(val)
    vm.push(val)
  vm.env["echo"] = proc(vm: tabulaVM, next: tokenFunc) =
    echo vm.stack.pop()
  vm.env["if:"] = vmFunc:
    let cond = next("expected condition!")
    let trueArm = next("expected true if-arm!")
    let falseArm = next("expected false if-arm!")
    vm.tabulaExec(tokenize(cond.value))
    let condVal = vm.stack.pop()
    if condVal.tEq(true):
      vm.tabulaExec(tokenize(trueArm.value))
    else:
      vm.tabulaExec(tokenize(falseArm.value))

proc tabulaExec(vm: tabulaVM, next: tokenFunc) =
  var tok = next("Read for Exec")
  while len(tok.message) <= 0:
    if vm.env.hasKey(tok.value):
      vm.env[tok.value](vm, next)
    else:
      vm.push(tok.value)
    tok = next("Read for Exec")

proc initTabulaVM(): tabulaVM =
  var vm = tabulaVM()
  vm.stack = newSeq[TabulaValue]()
  vm.env = newTable[string, TabulaFunc]()
  vm.vals = newStringTable(modeCaseInsensitive)
  return vm

proc tabulaRun*(code: string) =
  var vm = initTabulaVM()
  initVMEnv(vm)
  tabulaExec(vm, tokenize(code))
  echo vm.stack

when isMainModule:
  tabulaRun("f  f  t  echo")
  tabulaRun("[f]  f  t  echo")
  tabulaRun("[f][test]echo")
  echo("Skipped math test")
  # tabulaRun("1 2 + 3 * dup /")
  tabulaRun("if: t [1][0]")
