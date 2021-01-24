import strutils

type
  ObjectCode* = enum
    ocInt8, ocInt32, ocInt64
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
      of ocInt8: i16: int8
      of ocInt32: i32: int
      of ocInt64: i64: int64

      of ocFloat64: f64: float64

      of ocString: str: string
      of ocChar: chr: char
      of ocArray: arr: ObjectArray
      of ocInstance: ins: ObjectInstance
      
      else: discard

# constructors -> Object

# int8-64
proc newObject*(value: int8): Object = Object(code: ocInt8, i16: value)
proc newObject*(value: int): Object = Object(code: ocInt32, i32: value)
proc newObject*(value: int64): Object = Object(code: ocInt64, i64: value)

# float64
proc newObject*(value: float64): Object = Object(code: ocFloat64, f64: value)

# sequences
proc newObject*(value: string): Object = Object(code: ocString, str: value)
proc newObject*(value: char): Object = Object(code: ocChar, chr: value)
proc newObject*(value: ObjectArray): Object = Object(code: ocArray, arr: value)

# custom instance, null
proc newObject*(value: ObjectInstance): Object = Object(code: ocInstance, ins: value)
proc newObject*(): Object = Object(code: ocNull)

# null
let null* = newObject()

# converters -> Object

# int8-64
converter toObject*(value: int8): Object = newObject(value)
converter toObject*(value: int): Object = newObject(value)
converter toObject*(value: int64): Object = newObject(value)

# float64
converter toObject*(value: float64): Object = newObject(value)

# sequences
converter toObject*(value: string): Object = newObject(value)
converter toObject*(value: char): Object = newObject(value)
converter toObject*(value: ObjectArray): Object = newObject(value)

# custom instance, null
converter toObject*(value: ObjectInstance): Object = newObject(value)

# operators -> Object

# echo myObj

proc `$`*(self: Object): string =
  case self.code
    of ocInt8: $self.i16
    of ocInt32: $self.i32
    of ocInt64: $self.i64

    of ocFloat64: $self.f64

    of ocString: self.str
    of ocChar: $self.chr
    of ocArray: $self.arr

    of ocInstance: $self.ins
    
    else: "(null)"

# myObj as Type

proc `as`*(self: Object, T: typedesc): T =
  when T is int16: self.i16
  elif T is int32: self.i32
  elif T is int64: self.i64

  elif T is float64: self.f64
  
  elif T is string: self.str
  elif T is char: self.chr
  elif T is ObjectArray: self.arr

  else: self.ins

# myObj == myObj1

proc `==`*(left: Object, right: Object): bool =
  if left.code != right.code:
    return
  case left.code
    of ocInt8: left.i16 == right.i16
    of ocInt32: left.i32 == right.i32
    of ocInt64: left.i64 == right.i64
    
    of ocFloat64: left.f64 == right.f64

    of ocString: left.str == right.str
    of ocChar: left.chr == right.chr
    of ocArray: left.arr == right.arr

    of ocInstance: left.ins == right.ins
    
    else: true

# myObj != myObj1

proc `!=`*(left: Object, right: Object): bool =  not(left != right)


# constructors -> ObjectInstance

proc newObjectInstance*(instance: pointer, typeSize: int, typeName: string): ObjectInstance =
  ObjectInstance(typeSize: typeSize, instance: instance, runtimeID: typeName)

proc newObjectInstance*[T](instance: var T): ObjectInstance =
  ObjectInstance(typeSize: sizeof(instance), instance: addr(instance), runtimeID: $T)

proc newObjectInstance*[T](instance: T): ObjectInstance =
  ObjectInstance(typeSize: sizeof(instance), instance: unsafeAddr(instance), runtimeID: $T)