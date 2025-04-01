//
//  RelayEventBufferTests.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import RelayCommon
@testable import RelayCore
@testable import RelayMocks
import XCTest

final class RelayEventBufferTests: XCTestCase {
    
    private var mockWriter: MockWriter!
    
    override func setUp() {
        super.setUp()
        
        mockWriter = MockWriter()
    }
    
    override func tearDown() {
        mockWriter = nil
        super.tearDown()
    }
    
    func testFlushWithNoEventsDoesNotWrite() async {
        let buffer = makeBuffer()

        await buffer.flush()
        XCTAssertEqual(mockWriter.captured.count, 0, "Expected no flushes with empty buffer")
    }

    func testAddAndFlush() async throws {
        let buffer = makeBuffer()

        await buffer.add(RelayEvent.mock(name: "event1"))
        await buffer.add(RelayEvent.mock(name: "event2"))
        await buffer.add(RelayEvent.mock(name: "event3"))

        await buffer.flush()

        XCTAssertEqual(mockWriter.captured.count, 1, "Expected one flush call")
        let events = mockWriter.captured[0]
        XCTAssertEqual(events.count, 3, "Expected three events flushed")
        XCTAssertEqual(events.map(\.name), ["event1", "event2", "event3"])
    }

    func testPeriodicFlush() async throws {
        let buffer = makeBuffer()

        // Start periodic flush with a 1-second interval.
        await buffer.startFlush(interval: 1.0)

        await buffer.add(RelayEvent.mock(name: "event1"))
        await buffer.add(RelayEvent.mock(name: "event2"))

        // Wait 1.5 seconds to allow at least one flush to occur.
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // Stop the flush task explicitly in an async context.
        await buffer.stopFlush()

        XCTAssertGreaterThanOrEqual(mockWriter.captured.count, 1, "Expected at least one periodic flush")
        if let firstFlush = mockWriter.captured.first {
            XCTAssertEqual(firstFlush.count, 2, "Expected first flush to capture two events")
        }
    }
    
    func testStartFlushCancelsPreviousTask() async throws {
        let buffer = makeBuffer()

        await buffer.startFlush(interval: 0.5)
        let firstID = await buffer.flushTaskID

        await buffer.startFlush(interval: 0.5)
        let secondID = await buffer.flushTaskID

        XCTAssertNotEqual(firstID, secondID, "Expected a new flush task ID to replace the old one")
    }

    func testStopFlushIsIdempotent() async {
        let buffer = makeBuffer()

        await buffer.startFlush(interval: 1.0)
        await buffer.stopFlush()
        await buffer.stopFlush() // Should not crash
        XCTAssertTrue(true, "Calling stopFlush() multiple times should not fail")
    }

    /// This test validates the thread-safety of RelayEventBuffer.add(_:) under high concurrency.
    /// Correct drop policy under overflow (.dropOldest)
    /// Accurate flush behavior -- doesn't duplicate or miss records beyond buffer limits
    func testConcurrentAdds() async throws {
        let buffer = makeBuffer(capacity: 100)
        let addCount = 1000

        // Spawn 1,000 concurrent tasks, each adding their own mock event.
        // This stresses thread-safety and tests how the buffer handles concurrent writes.
        await withTaskGroup(of: Void.self) { group in
            for i in 0 ..< addCount {
                group.addTask {
                    await buffer.add(RelayEvent.mock(name: "event\(i)"))
                }
            }
        }

        // Triggers a flush: the buffer sends all currently-held events to the writer.
        await buffer.flush()

        // Asserts that only one batch of events was written to the writer.
        // With a capacity of 100 and using .dropOldest policy, expect only the last 100 events.
        // The other 900 events were dropped to make room for the last 100.
        XCTAssertEqual(mockWriter.captured.count, 1, "Expected one flush call")
        let events = mockWriter.captured.first ?? []
        XCTAssertEqual(events.count, 100, "Expected buffer to hold 100 events due to capacity")
    }

    func testStopFlushCancelsPeriodicTask() async throws {
        let buffer = makeBuffer()

        await buffer.startFlush(interval: 1.0)
        await buffer.add(RelayEvent.mock(name: "event1"))

        // Wait for one flush cycle.
        try await Task.sleep(nanoseconds: 1_200_000_000)
        await buffer.stopFlush()
        let capturedCountAfterStop = mockWriter.captured.count

        // Wait additional time to ensure no new flushes occur.
        try await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertEqual(
            mockWriter.captured.count,
            capturedCountAfterStop,
            "Expected no additional flushes after stopFlush"
        )
    }
    
    private func makeBuffer(capacity: Int = 5) -> RelayEventBuffer {
        RelayEventBuffer(capacity: capacity, writer: mockWriter)
    }
}
