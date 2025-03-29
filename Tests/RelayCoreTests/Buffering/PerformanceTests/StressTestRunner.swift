import Foundation

struct StressTestRunner {
    let tracker = MetricsTracker()

    func runAll() async {
        for profile in StressProfile.all {
            print("\n\u{1F4CB} Running profile: \(profile)\n")

            let tester = RelayBufferPressureTester(
                concurrency: profile.concurrency,
                eventRate: profile.eventRate,
                duration: profile.duration,
                bufferSize: profile.bufferSize,
                flushInterval: profile.flushInterval,
                exporterDelay: profile.exporterDelay,
                tracker: tracker
            )

            await tester.runTest()
            await tracker.report(totalRuns: 1)
            await tracker.reset()
        }
    }
}

// MARK: - Example Usage in XCTest

// In your test:
// func testStressMatrix() async throws {
//     let runner = StressTestRunner()
//     await runner.runAll()
// }
