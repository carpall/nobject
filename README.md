#### Here a simple object for allow dynamic typing in nim
#### Object is allocated on the stack, it is built on a variant object
#### It supports the following types: int8, int32, int64, float64, string, char, array of Object, custom instances (like structs)
#### This is a simple library to use and manage it by code. You can use it in structs, vars, etc..
#### It supports even operator like `as` for conversions, implicit conversions (example: `var u: Object = true; assert u`)
