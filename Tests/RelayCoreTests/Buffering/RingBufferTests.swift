import XCTest
@testable import RelayCore

final class RingBufferTests: XCTestCase {

    func testAppendFewerThanCapacity() {
        var buffer = RingBuffer<Int>(capacity: 5)
        buffer.append(10)
        buffer.append(20)
        buffer.append(30)
        XCTAssertEqual(buffer.snapshot(), [10, 20, 30])
        XCTAssertEqual(buffer.currentCount, 3)
        XCTAssertFalse(buffer.isFull)
        XCTAssertFalse(buffer.isEmpty)
    }
    
    func testAppendExactlyCapacity() {
        var buffer = RingBuffer<Int>(capacity: 3)
        buffer.append(1)
        buffer.append(2)
        buffer.append(3)
        XCTAssertEqual(buffer.snapshot(), [1, 2, 3])
        XCTAssertEqual(buffer.currentCount, 3)
        XCTAssertTrue(buffer.isFull)
    }
    
    func testDropOldestPolicy() {
        var buffer = RingBuffer<Int>(capacity: 3, dropPolicy: .dropOldest)
        buffer.append(1)
        buffer.append(2)
        buffer.append(3)
        // Buffer is full; appending a new element should drop the oldest element.
        buffer.append(4)
        XCTAssertEqual(buffer.snapshot(), [2, 3, 4])
        XCTAssertEqual(buffer.currentCount, 3)
    }
    
    func testDropNewestPolicy() {
        var buffer = RingBuffer<Int>(capacity: 3, dropPolicy: .dropNewest)
        buffer.append(1)
        buffer.append(2)
        buffer.append(3)
        // Buffer is full; appending a new element should be ignored.
        buffer.append(4)
        XCTAssertEqual(buffer.snapshot(), [1, 2, 3])
        XCTAssertEqual(buffer.currentCount, 3)
    }
    
    func testClearResetsBuffer() {
        var buffer = RingBuffer<String>(capacity: 3)
        buffer.append("a")
        buffer.append("b")
        buffer.append("c")
        XCTAssertFalse(buffer.isEmpty)
        buffer.clear()
        XCTAssertTrue(buffer.snapshot().isEmpty)
        XCTAssertEqual(buffer.currentCount, 0)
        XCTAssertTrue(buffer.isEmpty)
    }
    
    func testSnapshotOrderAfterWrapping() {
        var buffer = RingBuffer<Int>(capacity: 3, dropPolicy: .dropOldest)
        // Initial population
        buffer.append(1)
        buffer.append(2)
        buffer.append(3)
        // Overwrite begins: first two elements dropped
        buffer.append(4)
        buffer.append(5)
        XCTAssertEqual(buffer.snapshot(), [3, 4, 5])
    }
}
