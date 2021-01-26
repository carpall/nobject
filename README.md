#### Here a simple object for allowing dynamic typing in nim
#### Object is built on a variant object
#### It supports the following types: int8, int32, int64, float64, string, char, array of Object, custom instances (like structs)
#### This is a simple library to use and manage it by code. You can use it in structs, vars, etc..
Example
```nim
# Stack allocation

var s: Object = "Hello"      # new object of type string
echo s                       # Hello, calling $
echo s.getType()             # ocString, where oc means ObjectCode
let x: Object = s of string  # true
s = x                        # changing type at runtime
if x:
  echo "Implicit convertion to bool"
```

Another example
```nim
type
  Person = object
    name: string
    age: uint8

var tmp = Person()
var me: Object = newObject(tmp)

var other = me
other.name = "?"

echo "Recovering name: ", (me as Person).name
assert me != other
```


Using it in types
```nim
type
  Node = object
    kind: uint8
    value: Object                 # Allowing Node recursion, normally illegal
  DynamicType = object
    node: Object

var dyn = DynamicType(node: null) # null = newObject(ocNull), declared in the module
var node = Node(value: null)
dyn.node = Node(value: newObject(node)) # type recursion
```