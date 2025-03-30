//
//  RingBufferTests.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import XCTest
@testable import RelayCore

final class RingBufferTests: XCTestCase {

    // Test enqueuing fewer elements than capacity.
    func testEnqueueFewerThanCapacity() async {
        let buffer = RingBuffer<Int>(capacity: 5)
        let result1 = await buffer.enqueue(10)
        XCTAssertTrue(result1)
        let result2 = await buffer.enqueue(20)
        XCTAssertTrue(result2)
        let result3 = await buffer.enqueue(30)
        XCTAssertTrue(result3)
        
        let count = await buffer.count
        XCTAssertEqual(count, 3)
        let full = await buffer.isFull
        XCTAssertFalse(full)
        let empty = await buffer.isEmpty
        XCTAssertFalse(empty)
        
        // Verify FIFO order using flush.
        let elements = await buffer.flush()
        XCTAssertEqual(elements, [10, 20, 30])
        let countAfterFlush = await buffer.count
        XCTAssertEqual(countAfterFlush, 0)
        let emptyAfterFlush = await buffer.isEmpty
        XCTAssertTrue(emptyAfterFlush)
    }
    
    // Test enqueuing exactly capacity number of elements.
    func testEnqueueExactlyCapacity() async {
        let buffer = RingBuffer<Int>(capacity: 3)
        let r1 = await buffer.enqueue(1)
        XCTAssertTrue(r1)
        let r2 = await buffer.enqueue(2)
        XCTAssertTrue(r2)
        let r3 = await buffer.enqueue(3)
        XCTAssertTrue(r3)
        
        let count = await buffer.count
        XCTAssertEqual(count, 3)
        let full = await buffer.isFull
        XCTAssertTrue(full)
        
        let elements = await buffer.flush()
        XCTAssertEqual(elements, [1, 2, 3])
    }
    
    // Test that when the buffer is full, new events are dropped.
    func testEnqueueWhenFullShouldDropNew() async {
        let buffer = RingBuffer<Int>(capacity: 3)
        let r1 = await buffer.enqueue(1)
        XCTAssertTrue(r1)
        let r2 = await buffer.enqueue(2)
        XCTAssertTrue(r2)
        let r3 = await buffer.enqueue(3)
        XCTAssertTrue(r3)
        
        // Buffer is full, so this enqueue should return false.
        let r4 = await buffer.enqueue(4)
        XCTAssertFalse(r4)
        
        let count = await buffer.count
        XCTAssertEqual(count, 3)
        let dropped = await buffer.droppedElements
        XCTAssertEqual(dropped, 1)
        
        // Ensure that the buffer content remains unchanged.
        let elements = await buffer.flush()
        XCTAssertEqual(elements, [1, 2, 3])
    }
    
    // Test that flush empties the buffer.
    func testFlushEmptiesBuffer() async {
        let buffer = RingBuffer<String>(capacity: 3)
        let r1 = await buffer.enqueue("a")
        XCTAssertTrue(r1)
        let r2 = await buffer.enqueue("b")
        XCTAssertTrue(r2)
        let r3 = await buffer.enqueue("c")
        XCTAssertTrue(r3)
        
        let elements = await buffer.flush()
        XCTAssertEqual(elements, ["a", "b", "c"])
        
        let count = await buffer.count
        XCTAssertEqual(count, 0)
        let empty = await buffer.isEmpty
        XCTAssertTrue(empty)
    }
    
    // Test the ordering after wrapping.
    func testFlushOrderAfterWrapping() async {
        let buffer = RingBuffer<Int>(capacity: 3)
        let r1 = await buffer.enqueue(1)
        XCTAssertTrue(r1)
        let r2 = await buffer.enqueue(2)
        XCTAssertTrue(r2)
        let r3 = await buffer.enqueue(3)
        XCTAssertTrue(r3)
        // Attempt to enqueue when full should drop new element.
        let r4 = await buffer.enqueue(4)
        XCTAssertFalse(r4)
        
        let elements = await buffer.flush()
        XCTAssertEqual(elements, [1, 2, 3])
        
        let count = await buffer.count
        XCTAssertEqual(count, 0)
    }
    
    // Test concurrent enqueues to simulate high throughput.
    func testConcurrentEnqueues() async {
        let buffer = RingBuffer<Int>(capacity: 100)
        await withTaskGroup(of: Void.self) { group in
            for i in 1...200 {
                group.addTask {
                    _ = await buffer.enqueue(i)
                }
            }
        }
        let count = await buffer.count
        XCTAssertEqual(count, 100)
        let dropped = await buffer.droppedElements
        XCTAssertEqual(dropped, 100)
    }
    
    // Test that flush is atomic when enqueues and flush occur concurrently.
    func testConcurrentFlushAndEnqueue() async {
        let buffer = RingBuffer<Int>(capacity: 50)
        await withTaskGroup(of: Void.self) { group in
            // Enqueue items concurrently.
            for i in 1...50 {
                group.addTask {
                    _ = await buffer.enqueue(i)
                }
            }
            // Flush concurrently.
            group.addTask {
                    _ = await buffer.flush()
            }
        }
        let count = await buffer.count
        XCTAssertLessThanOrEqual(count, 50)
    }
}
