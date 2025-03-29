//
//  RelayEventBuffer.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open‐source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// An actor-based buffer that wraps a RingBuffer of RelayEvent objects.
/// It provides thread-safe, asynchronous event buffering and periodic flushing using dependency injection for persistence.
actor RelayEventBuffer {
    
    /// The underlying ring buffer storing RelayEvent instances.
    private var ringBuffer: RingBuffer<RelayEvent>
    
    /// The persistence layer to which events will be flushed.
    private let writer: EventPersisting
    
    /// A Task that periodically flushes the buffer.
    private var flushTask: Task<Void, Never>?
    
    /// The capacity of the buffer.
    internal let capacity: Int

    /// Creates a new RelayEventBuffer with a configurable capacity.
    /// - Parameters:
    ///   - capacity: The maximum number of events the buffer can hold.
    ///   - writer: The persistence component conforming to EventPersisting.
    ///   - dropPolicy: The policy used when the buffer is full. Defaults to .dropOldest.
    internal init(capacity: Int, writer: EventPersisting, dropPolicy: RingBuffer<RelayEvent>.DropPolicy = .dropOldest) {
        self.capacity = capacity
        self.ringBuffer = RingBuffer<RelayEvent>(capacity: capacity, dropPolicy: dropPolicy)
        self.writer = writer
    }
    
    /// Adds a new event to the buffer.
    /// - Parameter event: The RelayEvent to add.
    internal func add(_ event: RelayEvent) {
        ringBuffer.append(event)
    }
    
    /// Flushes the current buffer by taking a snapshot of all events, clearing the buffer, and writing the events to persistence.
    internal func flush() async {
        let events = ringBuffer.snapshot()
        ringBuffer.clear()
        await writer.write(events)
    }
    
    /// Starts a periodic flush loop that flushes the buffer at the specified interval.
    /// - Parameter interval: The time interval (in seconds) between flushes. Defaults to 5 seconds.
    internal func startFlush(interval: TimeInterval = 5.0) {
        flushTask?.cancel()
        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                await self.flush()
            }
        }
    }
    
    /// Stops the periodic flush loop.
    internal func stopFlush() async {
        flushTask?.cancel()
        // Await the cancellation to ensure the task finishes.
        _ = await flushTask?.value
        flushTask = nil
    }
}
