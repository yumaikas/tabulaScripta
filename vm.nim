import strtabs, tables, strutils
import tabulaLex


type 
  tabulaFunc = proc(vm: tabulaVM, next: tokenFunc)

  tabulaVM* = ref object
    stack*: seq[string]
    env*: TableRef[string, tabulaFunc]
    vals*: StringTableRef

proc initVMEnv(vm: tabulaVM) =

  template vmFunc(code: untyped): untyped =
    (proc (vmachine: tabulaVM, next: tokenFunc) =
      let vm {.inject.} = vmachine
      code
    )
  template binaryOp(code: untyped): untyped =
    vmFunc:
      let b {.inject.} = vm.stack.pop()
      let a {.inject.} = vm.stack.pop()
      vm.stack.add(code)

  template mathBinaryOp(code: untyped): untyped =
    vmFunc:
      let y {.inject.} = vm.stack.pop().parseFloat()
      let x {.inject.} = vm.stack.pop().parseFloat()
      vm.stack.add($code)

  vm.env["t"] = vmFunc(vm.stack.add($true))
  vm.env["f"] = vmFunc(vm.stack.add($false))
  vm.env["concat"] = binaryOp(a & b)
  vm.env["+"] = mathBinaryOp(x + y)
  vm.env["-"] = mathBinaryOp(x - y)
  vm.env["/"] = mathBinaryOp(x / y)
  vm.env["*"] = mathBinaryOp(x * y)

  vm.env["dup"] = proc(vm: tabulaVM, next: tokenFunc) =
    let val = vm.stack.pop()
    vm.stack.add(val)
    vm.stack.add(val)
  vm.env["echo"] = proc(vm: tabulaVM, next: tokenFunc) =
    echo vm.stack.pop()

proc tabulaExec(vm: tabulaVM, next: tokenFunc) =
  var tok = next("Read for Exec")
  while len(tok.message) <= 0:
    if vm.env.hasKey(tok.value):
      vm.env[tok.value](vm, next)
    else:
      vm.stack.add(tok.value)
    tok = next("Read for Exec")

proc initTabulaVM(): tabulaVM =
  var vm = tabulaVM()
  vm.stack = newSeq[string]()
  vm.env = newTable[string, tabulaFunc]()
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
  tabulaRun("1 2 + 3 * dup /")
