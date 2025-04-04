//
//  RelayBufferPressureTester.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation
import RelayCommon
@testable import RelayCore
import XCTest

final class RelayBufferPressureTester {
    private let buffer: RelayEventBuffer
    private let writer: MockWriter
    private let flushInterval: TimeInterval
    private var eventID = 0
    private let stats: MetricsTracker
    private let duration: TimeInterval
    private let eventRate: Int
    private let concurrency: Int
    private let exporterDelay: TimeInterval

    init(
        concurrency: Int,
        eventRate: Int,
        duration: TimeInterval,
        bufferSize: Int,
        flushInterval: TimeInterval,
        exporterDelay: TimeInterval,
        tracker: MetricsTracker
    ) {
        self.concurrency = concurrency
        self.eventRate = eventRate
        self.duration = duration
        self.flushInterval = flushInterval
        self.exporterDelay = exporterDelay
        stats = tracker

        writer = MockWriter(delay: exporterDelay)
        buffer = RelayEventBuffer(capacity: bufferSize, writer: writer)
    }

    @available(iOS 16.0, *)
    func runTest() async {
        let endTime = Date().addingTimeInterval(duration)

        // Start periodic flushing
        Task.detached {
            while Date() < endTime {
                try? await Task.sleep(for: .seconds(self.flushInterval))
                let start = Date()
                await self.buffer.flush()
                await self.stats.recordFlush(duration: Date().timeIntervalSince(start))
            }
        }

        // Start concurrent event producers
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< concurrency {
                group.addTask {
                    while Date() < endTime {
                        let id = await self.nextID()
                        let event = RelayEvent.mock(name: "event\(id)")
                        let start = Date()
                        await self.buffer.add(event)
                        await self.stats.recordAdd(duration: Date().timeIntervalSince(start))
                        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 / UInt64(self.eventRate)))
                    }
                }
            }
        }

        // Final flush
        await buffer.flush()
    }

    private func nextID() async -> Int {
        defer { eventID += 1 }
        return eventID
    }
}
