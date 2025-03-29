//
//  RingBuffer.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// A high-performance, overwrite-safe, circular buffer for storing events in memory.
/// This structure is designed for use in an actor-based context, ensuring thread-safe access when wrapped in an actor.
/// It supports two drop policies:
/// - `.dropOldest`: Overwrite the oldest element when the buffer is full.
/// - `.dropNewest`: Ignore the new element when the buffer is full.
public struct RingBuffer<T: Sendable> {
    
    /// The policy used when the buffer is full.
    public enum DropPolicy {
        case dropOldest
        case dropNewest
    }
    
    private var buffer: [T?]
    private var head: Int = 0
    private var count: Int = 0
    
    /// The maximum number of elements the buffer can hold.
    public let capacity: Int
    /// The drop policy applied when the buffer is full.
    public let dropPolicy: DropPolicy
    
    /// Creates a new ring buffer with the given capacity and drop policy.
    /// - Parameters:
    ///   - capacity: The fixed capacity of the buffer. Must be greater than 0.
    ///   - dropPolicy: The policy to apply when the buffer is full. Defaults to `.dropOldest`.
    public init(capacity: Int, dropPolicy: DropPolicy = .dropOldest) {
        precondition(capacity > 0, "Capacity must be greater than 0")
        self.capacity = capacity
        self.dropPolicy = dropPolicy
        self.buffer = Array(repeating: nil, count: capacity)
    }
    
    /// Indicates whether the buffer is empty.
    public var isEmpty: Bool {
        isEmpty
    }
    
    /// Indicates whether the buffer is full.
    public var isFull: Bool {
        return count == capacity
    }
    
    /// The number of elements currently stored in the buffer.
    public var currentCount: Int {
        return count
    }
    
    /// Appends a new element to the buffer.
    /// - Parameter element: The element to append.
    /// - Note: If the buffer is full, the behavior depends on the `dropPolicy`.
    public mutating func append(_ element: T) {
        if isFull {
            switch dropPolicy {
            case .dropOldest:
                // Overwrite the oldest element.
                buffer[head] = element
                head = (head + 1) % capacity
            case .dropNewest:
                // Ignore the new element.
                return
            }
        } else {
            let index = (head + count) % capacity
            buffer[index] = element
            count += 1
        }
    }
    
    /// Returns a snapshot of the buffer's current elements in order.
    /// - Returns: An array containing the buffered elements in FIFO order.
    public func snapshot() -> [T] {
        var result = [T]()
        for i in 0..<count {
            let index = (head + i) % capacity
            if let element = buffer[index] {
                result.append(element)
            }
        }
        return result
    }
    
    /// Clears all elements from the buffer.
    public mutating func clear() {
        buffer = Array(repeating: nil, count: capacity)
        head = 0
        count = 0
    }
}
