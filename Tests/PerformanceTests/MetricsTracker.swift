//
//  MetricsTracker.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

actor MetricsTracker {
    private var totalAdded = 0
    private var totalDropped = 0
    private var addLatencies: [TimeInterval] = []
    private var flushLatencies: [TimeInterval] = []
    private var flushCounts = 0

    func recordAdd(duration: TimeInterval) {
        totalAdded += 1
        addLatencies.append(duration)
    }

    func recordDrop() {
        totalDropped += 1
    }

    func recordFlush(duration: TimeInterval) {
        flushLatencies.append(duration)
        flushCounts += 1
    }

    func reset() {
        totalAdded = 0
        totalDropped = 0
        addLatencies.removeAll()
        flushLatencies.removeAll()
        flushCounts = 0
    }

    func report(totalRuns: Int) {
        print("=== Relay Ring Buffer Benchmark Summary ===")
        print("Total Runs: \(totalRuns)")
        print("Total Events Added: \(totalAdded)")
        print("Total Events Dropped: \(totalDropped)")
        print("Total Flushes: \(flushCounts)")

        printLatencyStats(label: "Enqueue", values: addLatencies)
        printLatencyStats(label: "Flush", values: flushLatencies)
    }

    private func printLatencyStats(label: String, values: [TimeInterval]) {
        guard !values.isEmpty else {
            print("\(label) Latency: No data recorded.")
            return
        }

        let avg = average(of: values)
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        let p95 = percentile(values, 0.95)
        let p99 = percentile(values, 0.99)

        print(String(format: "\n\(label) Latency (ms):"))
        print(String(format: "  Avg:   %.3f", avg * 1000))
        print(String(format: "  Min:   %.3f", min * 1000))
        print(String(format: "  Max:   %.3f", max * 1000))
        print(String(format: "  p95:   %.3f", p95 * 1000))
        print(String(format: "  p99:   %.3f", p99 * 1000))
    }

    private func average(of values: [TimeInterval]) -> TimeInterval {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func percentile(_ values: [TimeInterval], _ percentile: Double) -> TimeInterval {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let rank = Int(Double(sorted.count - 1) * percentile)
        return sorted[rank]
    }
}
