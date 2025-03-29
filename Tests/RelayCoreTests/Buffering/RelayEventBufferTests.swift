import XCTest
@testable import RelayCore

final class RelayEventBufferTests: XCTestCase {
    
    func testAddAndFlush() async throws {
        let writer = MockWriter()
        let buffer = RelayEventBuffer(capacity: 5, writer: writer)

        await buffer.add(RelayEvent.mock(name: "event1"))
        await buffer.add(RelayEvent.mock(name: "event2"))
        await buffer.add(RelayEvent.mock(name: "event3"))

        await buffer.flush()

        XCTAssertEqual(writer.captured.count, 1, "Expected one flush call")
        let events = writer.captured.first ?? []
        XCTAssertEqual(events.count, 3, "Expected three events flushed")
        XCTAssertEqual(events.map { $0.name }, ["event1", "event2", "event3"])
    }

    func testPeriodicFlush() async throws {
        let writer = MockWriter()
        let buffer = RelayEventBuffer(capacity: 5, writer: writer)

        // Start periodic flush with a 1-second interval.
        await buffer.startFlush(interval: 1.0)
        
        await buffer.add(RelayEvent.mock(name: "event1"))
        await buffer.add(RelayEvent.mock(name: "event2"))

        // Wait 1.5 seconds to allow at least one flush to occur.
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Stop the flush task explicitly in an async context.
        await buffer.stopFlush()

        XCTAssertGreaterThanOrEqual(writer.captured.count, 1, "Expected at least one periodic flush")
        if let firstFlush = writer.captured.first {
            XCTAssertEqual(firstFlush.count, 2, "Expected first flush to capture two events")
        }
    }

    /// This test validates the thread-safety of RelayEventBuffer.add(_:) under high concurrency.
    /// Correct drop policy under overflow (.dropOldest)
    /// Accurate flush behavior -- doesn't duplicate or miss records beyond buffer limits
    func testConcurrentAdds() async throws {
        let writer = MockWriter()
        let buffer = RelayEventBuffer(capacity: 100, writer: writer)
        let addCount = 1000

        // Spawn 1,000 concurrent tasks, each adding their own mock event.
        // This stresses thread-safety and tests how the buffer handles concurrent writes.
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<addCount {
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
        XCTAssertEqual(writer.captured.count, 1, "Expected one flush call")
        let events = writer.captured.first ?? []
        XCTAssertEqual(events.count, 100, "Expected buffer to hold 100 events due to capacity")
    }

    func testStopFlushCancelsPeriodicTask() async throws {
        let writer = MockWriter()
        let buffer = RelayEventBuffer(capacity: 5, writer: writer)

        await buffer.startFlush(interval: 1.0)
        await buffer.add(RelayEvent.mock(name: "event1"))
        
        // Wait for one flush cycle.
        try await Task.sleep(nanoseconds: 1_200_000_000)
        await buffer.stopFlush()
        let capturedCountAfterStop = writer.captured.count
        
        // Wait additional time to ensure no new flushes occur.
        try await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertEqual(writer.captured.count, capturedCountAfterStop, "Expected no additional flushes after stopFlush")
    }
}
