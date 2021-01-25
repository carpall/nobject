import strutils, strformat, sequtils

type
  ObjectCode* = enum
    ocInt8, ocInt32, ocInt64
    ocBool
    ocFloat64
    ocString, ocChar, ocArray
    ocInstance, ocNull
  ObjectArray* = seq[Object]
  ObjectInstance* = object
    runtimeID: string
    typeSize: int
    instance: pointer
  Object* = object
    case code: ObjectCode:
      of ocInt8: i8: int8
      of ocInt32: i32: int
      of ocInt64: i64: int64

      of ocBool: u1: bool

      of ocFloat64: f64: float64

      of ocString: str: string
      of ocChar: chr: char
      of ocArray: arr: ObjectArray
      of ocInstance: ins: ObjectInstance
      
      else: discard
  ObjectError* = ref ValueError

# ObjectError

proc error(msg: string) {.noreturn.} = raise ObjectError(msg: msg)

# constructors -> ObjectInstance

proc newObjectInstance*(instance: pointer, typeSize: int, typeName: string): ObjectInstance =
  ObjectInstance(typeSize: typeSize, instance: instance, runtimeID: typeName)

proc newObjectInstance*[T](instance: var T): ObjectInstance =
  ObjectInstance(typeSize: sizeof(instance), instance: addr(instance), runtimeID: $T)

# operators -> ObjectInstance

# echo myObj

proc `$`*(self: ObjectInstance): string =
  self.runtimeID

# myObj == myObj1

proc `==`*(left: ObjectInstance, right: ObjectInstance): bool =
  left.runtimeID == right.runtimeID and equalMem(left.instance, right.instance, left.typeSize)

# myObj != myObj1

proc `!=`*(left: ObjectInstance, right: ObjectInstance): bool =  not(left != right)


# constructors -> Object

# int8-64
proc newObject*(value: int8): Object = Object(code: ocInt8, i8: value)
proc newObject*(value: int): Object = Object(code: ocInt32, i32: value)
proc newObject*(value: int64): Object = Object(code: ocInt64, i64: value)

# bool
proc newObject*(value: bool): Object = Object(code: ocBool, u1: value)

# float64
proc newObject*(value: float64): Object = Object(code: ocFloat64, f64: value)

# sequences
proc newObject*(value: string): Object = Object(code: ocString, str: value)
proc newObject*(value: char): Object = Object(code: ocChar, chr: value)
proc newObject*(value: ObjectArray): Object = Object(code: ocArray, arr: value)

# custom instance, null
proc newObject*[T](value: var T): Object = Object(code: ocInstance, ins: newObjectInstance(value)) 
proc newObject*(): Object = Object(code: ocNull)

# null
let null* = newObject()

# converters -> ... to Object

# int8-64
converter toObject*(value: int8): Object = newObject(value)
converter toObject*(value: int): Object = newObject(value)
converter toObject*(value: int64): Object = newObject(value)

# bool
converter toObject*(value: bool): Object = newObject(value)

# float64
converter toObject*(value: float64): Object = newObject(value)

# sequences
converter toObject*(value: string): Object = newObject(value)
converter toObject*(value: char): Object = newObject(value)
converter toObject*(value: ObjectArray): Object = newObject(value)

# operators -> Object

# echo myObj

proc `$`*(self: Object): string =
  case self.code
    of ocInt8: $self.i8
    of ocInt32: $self.i32
    of ocInt64: $self.i64

    of ocBool: $self.u1

    of ocFloat64: $self.f64

    of ocString: self.str
    of ocChar: $self.chr
    of ocArray: $self.arr

    of ocInstance: $self.ins
    
    else: "(null)"

# private
proc expectType(self: Object, expected: ObjectCode) =
  if self.code != expected:
    error(fmt"Unsupported operation: tried to convert type `{self.code}` in `{expected}`")

proc convert[T](self: ObjectInstance): T = cast[ptr T](self.instance)[]

# myObj as Type

proc `as`*(self: Object, T: typedesc): T =
  when T is int16:
    self.expectType(ocInt8)
    self.i8
  elif T is int:
    self.expectType(ocInt32)
    self.i32
  elif T is int64:
    self.expectType(ocInt64)
    self.i64

  elif T is bool:
    self.expectType(ocBool)
    self.u1
  
  elif T is float64:
    self.expectType(ocFloat64)
    self.f64
  
  elif T is string:
    self.expectType(ocString)
    self.str
  elif T is char:
    self.expectType(ocChar)
    self.chr
  elif T is ObjectArray:
    self.expectType(ocArray)
    self.arr

  else:
    self.expectType(ocInstance)
    convert[T](self.ins)

# myObj == myObj1

proc `==`*(left: Object, right: Object): bool =
  if left.code != right.code:
    return
  case left.code
    of ocInt8: left.i8 == right.i8
    of ocInt32: left.i32 == right.i32
    of ocInt64: left.i64 == right.i64
    
    of ocBool: left.u1 and right.u1

    of ocFloat64: left.f64 == right.f64

    of ocString: left.str == right.str
    of ocChar: left.chr == right.chr
    of ocArray: left.arr == right.arr

    of ocInstance: left.ins == right.ins
    
    else: true

# myObj != myObj1

proc `!=`*(left: Object, right: Object): bool = not(left != right)

# myObj < myObj1

proc `<`*(left: Object, right: Object): bool =
  if left.code != right.code:
    error(fmt"Incompatible types: tried to perform op `<` between types `{left.code}` and `{right.code}`")
  case left.code
    of ocInt8: left.i8 < right.i8
    of ocInt32: left.i32 < right.i32
    of ocInt64: left.i64 < right.i64
    
    of ocFloat64: left.f64 < right.f64
    
    else:
      error(fmt"Incompatible type: tried to perform op `<` on type `{left.code}`")

# myObj > myObj1

proc `>`*(left: Object, right: Object): bool =
  if left.code != right.code:
    error(fmt"Incompatible types: tried to perform op `>` between types `{left.code}` and `{right.code}`")
  case left.code
    of ocInt8: left.i8 > right.i8
    of ocInt32: left.i32 > right.i32
    of ocInt64: left.i64 > right.i64
    
    of ocFloat64: left.f64 > right.f64
    
    else:
      error(fmt"Incompatible type: tried to perform op `>` on type `{left.code}`")

# myObj <= myObj1

proc `<=`*(left: Object, right: Object): bool =
  if left.code != right.code:
    error(fmt"Incompatible types: tried to perform op `<=` between types `{left.code}` and `{right.code}`")
  case left.code
    of ocInt8: left.i8 <= right.i8
    of ocInt32: left.i32 <= right.i32
    of ocInt64: left.i64 <= right.i64
    
    of ocFloat64: left.f64 <= right.f64
    
    else:
      error(fmt"Incompatible type: tried to perform op `<=` on type `{left.code}`")

# myObj >= myObj1

proc `>=`*(left: Object, right: Object): bool =
  if left.code != right.code:
    error(fmt"Incompatible types: tried to perform op `>=` between types `{left.code}` and `{right.code}`")
  case left.code
    of ocInt8: left.i8 >= right.i8
    of ocInt32: left.i32 >= right.i32
    of ocInt64: left.i64 >= right.i64
    
    of ocFloat64: left.f64 >= right.f64
    
    else:
      error(fmt"Incompatible type: tried to perform op `>=` on type `{left.code}`")

# myObj + myObj1

proc `+`*(left: Object, right: Object): Object =
  if left.code != right.code:
    error(fmt"Incompatible types: tried to perform op `+` between types `{left.code}` and `{right.code}`")
  case left.code
    of ocInt8: newObject(left.i8 + right.i8)
    of ocInt32: newObject(left.i32 + right.i32)
    of ocInt64: newObject(left.i64 + right.i64)
    
    of ocFloat64: newObject(left.f64 + right.f64)

    of ocString: newObject(left.str & right.str)
    of ocArray: newObject(left.arr & right.arr)
    
    else:
      error(fmt"Incompatible type: tried to perform op `+` on type `{left.code}`")

# myObj - myObj1

proc `-`*(left: Object, right: Object): Object =
  if left.code != right.code:
    error(fmt"Incompatible types: tried to perform op `-` between types `{left.code}` and `{right.code}`")
  case left.code
    of ocInt8: newObject(left.i8 - right.i8)
    of ocInt32: newObject(left.i32 - right.i32)
    of ocInt64: newObject(left.i64 - right.i64)
    
    of ocFloat64: newObject(left.f64 - right.f64)
    
    else:
      error(fmt"Incompatible type: tried to perform op `-` on type `{left.code}`")

# converters -> Object to ... -> not all due to ambiguous calls

# bool
converter toObject*(self: Object): bool =
  self.expectType(ocBool)
  self.u1