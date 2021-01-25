import unittest

import nobject

type
  Person = object
    name: string
    age: uint8
  Person2 = object

test "Comparing Objects Test":
  let obj: Object = 2
  let obj1: Object = null
  assert obj != obj1
test "Instance Test":
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
  test "add seq":
    var s: Object = @[null, "1"]
    assert s+(@[null, "2"]) == @[null, "1", null, "2"]
  test "add int":
    var i: Object = 1
    assert i+2 == 3
test "Comparing Test":
  var p = Person(name: "ciao")
  var t: Object = newObject(p)
  assert t of Person
  assert not(t of Person2)