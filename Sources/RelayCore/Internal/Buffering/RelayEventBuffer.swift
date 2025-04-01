//
//  RelayEventBuffer.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation
import RelayCommon

/// An actor-based buffer that wraps a RingBuffer of RelayEvents.
/// It provides thread-safe, asynchronous event buffering and periodic flushing using dependency injection for persistence.
actor RelayEventBuffer: EventBuffer {
    /// The underlying ring buffer storing RelayEvent instances.
    private var ringBuffer: RingBuffer<RelayEvent>

    /// The persistence layer to which events will be flushed.
    private let writer: EventPersisting

    /// A Task that periodically flushes the buffer.
    private var flushTask: Task<Void, Never>?
    
    #if DEBUG
    internal var flushTaskID: UUID?
    #endif

    /// The capacity of the buffer.
    let capacity: Int

    /// Creates a new RelayEventBuffer with a configurable capacity.
    /// - Parameters:
    ///   - capacity: The maximum number of events the buffer can hold.
    ///   - writer: The persistence component conforming to EventPersisting.
    init(capacity: Int, writer: EventPersisting) {
        self.capacity = capacity
        ringBuffer = RingBuffer<RelayEvent>(capacity: capacity)
        self.writer = writer
    }

    /// Adds a new event to the buffer.
    /// - Parameter event: The RelayEvent to add.
    func add(_ event: RelayEvent) async {
        let success = await ringBuffer.enqueue(event)
        if !success {
            // Optionally log or handle the dropped event scenario.
            // The RingBuffer already tracks the number of dropped events.
            // TODO: Figure out if we want to do anything here.
        }
    }

    /// Flushes the current buffer by atomically removing all events and writing them to persistence.
    func flush() async {
        let events = await ringBuffer.flush()
        // Only attempt to write if there are events.
        if !events.isEmpty {
            await writer.write(events)
        }
    }

    /// Starts a periodic flush loop that flushes the buffer at the specified interval.
    /// - Parameter interval: The time interval (in seconds) between flushes. Defaults to 5 seconds.
    func startFlush(interval: TimeInterval = 5.0) {
        flushTask?.cancel()
        
        #if DEBUG
        flushTaskID = UUID()
        let currentID = flushTaskID
        #endif
        
        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                
                #if DEBUG
                guard self.flushTaskID == currentID else { break }
                #endif

                await self.flush()
            }
        }
    }

    /// Stops the periodic flush loop.
    func stopFlush() async {
        flushTask?.cancel()
        _ = await flushTask?.value
        flushTask = nil
    }
}
