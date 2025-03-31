//
//  RingBuffer.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// A thread-safe, actor-based ring buffer with fixed capacity.
/// - Note: The element type must conform to `Sendable` for safe concurrent usage.
actor RingBuffer<T: Sendable> {
    private var buffer: [T?]
    private var head: Int = 0
    private var tail: Int = 0
    private var isBufferFull: Bool = false
    private let capacity: Int

    /// Optionally tracks how many elements were dropped due to the buffer being full.
    private(set) var droppedElements: Int = 0

    /// Creates a new ring buffer with the specified capacity.
    /// - Parameter capacity: The maximum number of elements the buffer can hold.
    init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than zero")
        self.capacity = capacity
        buffer = Array(repeating: nil, count: capacity)
    }

    /// Enqueues an element into the ring buffer.
    /// - Parameter element: The element to add.
    /// - Returns: `true` if the element was enqueued; `false` if the buffer is full.
    @discardableResult
    func enqueue(_ element: T) -> Bool {
        if isFull {
            droppedElements += 1
            return false
        }
        buffer[tail] = element
        tail = (tail + 1) % capacity
        if tail == head {
            isBufferFull = true
        }
        return true
    }

    /// Dequeues an element from the buffer.
    /// - Returns: The dequeued element, or `nil` if the buffer is empty.
    func dequeue() -> T? {
        guard !isEmpty else { return nil }
        let element = buffer[head]
        buffer[head] = nil // Clear the slot to aid memory management.
        head = (head + 1) % capacity
        isBufferFull = false
        return element
    }

    /// Indicates whether the ring buffer is empty.
    var isEmpty: Bool {
        head == tail && !isBufferFull
    }

    /// Indicates whether the ring buffer is full.
    var isFull: Bool {
        head == tail && isBufferFull
    }

    /// The current number of elements in the buffer.
    var count: Int {
        if isBufferFull {
            return capacity
        }
        if tail >= head {
            return tail - head
        }
        return capacity - head + tail
    }

    /// Flushes all elements from the buffer in FIFO order.
    /// - Returns: An array containing all dequeued elements.
    func flush() -> [T] {
        var elements: [T] = []
        while let element = dequeue() {
            elements.append(element)
        }
        return elements
    }
}
