//
//  StressProfile.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

/// Defines standard stress test profiles for benchmarking Relay's RingBuffer performance.
/// These can be used to simulate real-world usage or stress-test under extreme conditions.

import Foundation

struct StressProfile {
    let name: String
    let concurrency: Int
    let eventRate: Int
    let duration: TimeInterval
    let bufferSize: Int
    let flushInterval: TimeInterval
    let exporterDelay: TimeInterval // e.g. simulate slow writer

    static let all: [StressProfile] = [
        .baseline,
        .typicalApp,
        .highLoad,
        .flushDelay,
        .stressTest,
        .burstTraffic,
        .tinyBuffer,
        .compression,
        .ciMode,
    ]

    static let baseline = StressProfile(
        name: "Baseline",
        concurrency: 4,
        eventRate: 1000,
        duration: 1.0,
        bufferSize: 500,
        flushInterval: 5.0,
        exporterDelay: 0.0
    )

    static let typicalApp = StressProfile(
        name: "Typical App",
        concurrency: 4,
        eventRate: 2000,
        duration: 10.0,
        bufferSize: 1000,
        flushInterval: 5.0,
        exporterDelay: 0.0
    )

    static let highLoad = StressProfile(
        name: "High Load",
        concurrency: 8,
        eventRate: 4000,
        duration: 10.0,
        bufferSize: 750,
        flushInterval: 3.0,
        exporterDelay: 0.0
    )

    static let flushDelay = StressProfile(
        name: "Flush Delay",
        concurrency: 4,
        eventRate: 2000,
        duration: 10.0,
        bufferSize: 500,
        flushInterval: 5.0,
        exporterDelay: 0.025
    )

    static let stressTest = StressProfile(
        name: "Stress Test",
        concurrency: 16,
        eventRate: 10000,
        duration: 30.0,
        bufferSize: 1000,
        flushInterval: 5.0,
        exporterDelay: 0.010
    )

    static let burstTraffic = StressProfile(
        name: "Burst Traffic",
        concurrency: 4,
        eventRate: 10000, // burst
        duration: 5.0,
        bufferSize: 500,
        flushInterval: 5.0,
        exporterDelay: 0.0
    )

    static let tinyBuffer = StressProfile(
        name: "Tiny Buffer",
        concurrency: 4,
        eventRate: 1000,
        duration: 5.0,
        bufferSize: 50,
        flushInterval: 5.0,
        exporterDelay: 0.0
    )

    static let compression = StressProfile(
        name: "Compression",
        concurrency: 4,
        eventRate: 1000,
        duration: 5.0,
        bufferSize: 500,
        flushInterval: 5.0,
        exporterDelay: 0.0
    )

    static let ciMode = StressProfile(
        name: "CI Mode",
        concurrency: 2,
        eventRate: 500,
        duration: 0.25,
        bufferSize: 250,
        flushInterval: 5.0,
        exporterDelay: 0.0
    )
}

extension StressProfile: CustomStringConvertible {
    var description: String {
        // swiftlint:disable line_length
        "\(name): \(concurrency) threads, \(eventRate)/s, \(duration)s, buffer=\(bufferSize), flush=\(flushInterval)s, delay=\(exporterDelay)s"
        // swiftlint:enable line_length
    }
}
