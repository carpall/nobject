import unittest

import nobject

type
  X = ref object
    y: object

var x: ref X = X(y: "")

test "Comparing Objects Test":
  let obj: Object = 2
  let obj1: Object = null
  echo obj == obj1
test "Instance Test":
  type
    Person = object
      name: string
      age: uint8
  var me = Person(name: "Ciao")
  let obj: Object = newObject[Person](me)
  assert (obj as Person).name == "Ciao"
test "Bool Test":
  var u: Object = true
  assert u
test "Add Test":
  test "add string":
    var s: Object = "1"
    assert s+"2" == "12"