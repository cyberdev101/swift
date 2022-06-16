// RUN: %target-run-simple-swift(-I %S/Inputs -Xfrontend -enable-experimental-cxx-interop)
//
// REQUIRES: executable_test
// REQUIRES: OS=macosx || OS=linux-gnu

import StdlibUnittest
import CustomSequence
import std

var CxxSequenceTestSuite = TestSuite("CxxSequence")

extension SimpleSequence.ConstIterator: UnsafeCxxInputIterator {
  // This should probably be synthesized from operator++.
  public func successor() -> Self {
    return SimpleSequence.ConstIterator(pointee + 1)
  }

  // This shouldn't be required, since operator== is defined on the C++ side.
  // However, without this decl it fails to typecheck, likely due to a lookup issue.
  public static func ==(lhs: SimpleSequence.ConstIterator, rhs: SimpleSequence.ConstIterator) -> Bool {
    return lhs.pointee == rhs.pointee
  }
}

extension SimpleSequence: CxxSequence {}

CxxSequenceTestSuite.test("SimpleSequence as Swift.Sequence") {
  let seq = SimpleSequence()
  let contains = seq.contains(where: { $0 == 3 })
  expectTrue(contains)

  var items: [Int32] = []
  for item in seq {
    items.append(item)
  }
  expectEqual([1, 2, 3, 4] as [Int32], items)
}

runAllTests()
