//
//  EventBuffer.swift
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

/// A thread-safe, actor-based abstraction for buffering and flushing `RelayEvent` instances.
///
/// `EventBuffer` defines a common interface for internal and testable implementations of event buffering logic.
/// This protocol is designed to be conformed to by an `actor`, providing built-in safety across concurrent calls
/// to `add`, `flush`, or flush scheduling.
///
/// ### Responsibilities:
/// - **Event Buffering:** Collects incoming `RelayEvent` values asynchronously via `add(_:)`.
/// - **Flush Coordination:** Sends collected events to a persistence layer when flushed.
/// - **Periodic Flushing:** Supports a periodic flush loop triggered via `startPeriodicFlush(interval:)`.
/// - **Safe Shutdown:** Gracefully cancels any background flush tasks when `stopFlush()` is called.
///
/// ### Design Notes:
/// - This protocol is intended to be implemented by actor types such as `RelayEventBuffer`.
/// - It supports **cooperative periodic flushing**, but leaves scheduling details to the implementation.
/// - Used by `RelayFlushController` and other lifecycle-aware orchestrators.
///
/// ### Example:
/// ```swift
/// let buffer: EventBuffer = RelayEventBuffer(capacity: 100, writer: myWriter)
/// await buffer.add(RelayEvent(name: "launch"))
/// await buffer.flush() // Forces immediate flush
/// buffer.startPeriodicFlush(interval: 5.0) // Optional background flush
/// ```
public protocol EventBuffer: Actor {
    
    #if DEBUG
    /// A unique identifier for the currently active periodic flush task.
    ///
    /// Used only for test introspection and task deduplication. Safe to ignore in production logic.
    var flushTaskID: UUID? { get }
    #endif

    /// The maximum number of events the buffer can hold before older events are discarded.
    ///
    /// This controls the size of the underlying ring buffer (or other bounded storage).
    var capacity: Int { get }

    /// Adds a new event to the buffer.
    ///
    /// This operation is non-blocking and safe to call from concurrent async contexts.
    /// If the buffer is full, the oldest event may be dropped (depending on implementation).
    ///
    /// - Parameter event: The `RelayEvent` to store.
    func add(_ event: RelayEvent) async

    /// Flushes the current buffer to the persistence layer.
    ///
    /// This operation atomically removes all events from the buffer and writes them
    /// to the configured writer. If the buffer is empty, the flush is a no-op.
    func flush() async

    /// Starts a background flush loop that flushes the buffer at the specified interval.
    ///
    /// This method may spawn a cooperative background task using `Task.sleep` or a custom scheduler.
    /// If a periodic flush task is already active, it may be cancelled and replaced.
    ///
    /// - Parameter interval: The time interval (in seconds) between flushes. Defaults to 5 seconds.
    func startPeriodicFlush(interval: TimeInterval)

    /// Stops the currently active periodic flush task, if any.
    ///
    /// This should be called when the app moves to background or is shutting down.
    /// Safe to call multiple times. The implementation should cancel any scheduled flush loops and clean up.
    func stopFlush() async
}

extension EventBuffer {
    /// Convenience method for starting a periodic flush with a default 5-second interval.
    public func startPeriodicFlush(interval: TimeInterval = 5.0) {
        self.startPeriodicFlush(interval: interval)
    }
}
