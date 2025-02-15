// RUN: %target-run-simple-swift( -Xfrontend -disable-availability-checking -parse-as-library)

// REQUIRES: concurrency
// REQUIRES: executable_test
// REQUIRES: concurrency_runtime

// Test requires _swift_task_enterThreadLocalContext which is not available 
// in the back deployment runtime.
// UNSUPPORTED: back_deployment_runtime
// UNSUPPORTED: back_deploy_concurrency

import _Concurrency
import StdlibUnittest

var tests = TestSuite("Time")

@main struct Main {
  static func main() async {
    tests.test("ContinuousClock sleep") {
      let clock = ContinuousClock()
      let elapsed = await clock.measure {
        try! await clock.sleep(until: .now + .milliseconds(100))
      }
      // give a reasonable range of expected elapsed time
      expectGT(elapsed, .milliseconds(90))
      expectLT(elapsed, .milliseconds(1000))
    }

    tests.test("ContinuousClock sleep with tolerance") {
      let clock = ContinuousClock()
      let elapsed = await clock.measure {
        try! await clock.sleep(until: .now + .milliseconds(100), tolerance: .milliseconds(100))
      }
      // give a reasonable range of expected elapsed time
      expectGT(elapsed, .milliseconds(90))
      expectLT(elapsed, .milliseconds(2000))
    }

    tests.test("ContinuousClock sleep longer") {
      let elapsed = await ContinuousClock().measure {
        try! await Task.sleep(until: .now + .seconds(1), clock: .continuous)
      }
      expectGT(elapsed, .seconds(1) - .milliseconds(90))
      expectLT(elapsed, .seconds(1) + .milliseconds(1000))
    }

    tests.test("SuspendingClock sleep") {
      let clock = SuspendingClock()
      let elapsed = await clock.measure {
        try! await clock.sleep(until: .now + .milliseconds(100))
      }
      // give a reasonable range of expected elapsed time
      expectGT(elapsed, .milliseconds(90))
      expectLT(elapsed, .milliseconds(1000))
    }

    tests.test("SuspendingClock sleep with tolerance") {
      let clock = SuspendingClock()
      let elapsed = await clock.measure {
        try! await clock.sleep(until: .now + .milliseconds(100), tolerance: .milliseconds(100))
      }
      // give a reasonable range of expected elapsed time
      expectGT(elapsed, .milliseconds(90))
      expectLT(elapsed, .milliseconds(2000))
    }

    tests.test("SuspendingClock sleep longer") {
      let elapsed = await SuspendingClock().measure {
        try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
      }
      expectGT(elapsed, .seconds(1) - .milliseconds(90))
      expectLT(elapsed, .seconds(1) + .milliseconds(1000))
    }

    tests.test("duration addition") {
      let d1 = Duration.milliseconds(500)
      let d2 = Duration.milliseconds(500)
      let d3 = Duration.milliseconds(-500)
      let sum = d1 + d2
      expectEqual(sum, .seconds(1))
      let comps = sum.components
      expectEqual(comps.seconds, 1)
      expectEqual(comps.attoseconds, 0)
      let adjusted = sum + d3
      expectEqual(adjusted, .milliseconds(500))
    }

    tests.test("duration subtraction") {
      let d1 = Duration.nanoseconds(500)
      let d2 = d1 - .nanoseconds(100)
      expectEqual(d2, .nanoseconds(400))
      let d3 = d1 - .nanoseconds(500)
      expectEqual(d3, .nanoseconds(0))
      let d4 = d1 - .nanoseconds(600)
      expectEqual(d4, .nanoseconds(-100))
    }

    tests.test("duration division") {
      let d1 = Duration.seconds(1)
      let halfSecond = d1 / 2
      expectEqual(halfSecond, .milliseconds(500))
    }

    tests.test("duration multiplication") {
      let d1 = Duration.seconds(1)
      let twoSeconds = d1 * 2
      expectEqual(twoSeconds, .seconds(2))
    }

    await runAllTestsAsync()
  }
}
