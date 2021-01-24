import unittest

import nobject
test "Comparing objects":
  let obj: Object = 2
  let obj1: Object = null
  echo "obj == obj1: ", obj == obj1
test "Instances":
  type
    Person = object
      name: string
      age: uint8
  let obj: ObjectInstance = newObjectInstance[Person](Person())
  echo "obj: ", obj