//
//  StressTestRunner.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

@available(iOS 16.0, *)
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
