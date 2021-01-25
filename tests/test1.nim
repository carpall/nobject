import unittest

import nobject
test "Comparing Objects Test ^":
  let obj: Object = 2
  let obj1: Object = null
  echo "obj == obj1: ", obj == obj1
test "Instance Test ^":
  type
    Person = object
      name: string
      age: uint8
  var me = Person(name: "Ciao")
  let obj: Object = newObject[Person](me)
  echo "obj: ", (obj as Person)
test "Bool Test ^":
  var u: Object = true
  if u:
    echo "!"
  echo u
test "Add Test ^":
  test "add string ^":
    var s: Object = "1"
    echo s+"2"