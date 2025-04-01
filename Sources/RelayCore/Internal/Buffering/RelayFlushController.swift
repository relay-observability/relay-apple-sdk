//
//  RelayFlushController.swift
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

/// A scheduler that periodically flushes a `RelayEventBuffer`.
///
/// `RelayFlushController` is responsible for invoking `flush()` on a `RelayEventBuffer`
/// at a fixed time interval using Swift Concurrency. It also hooks into the application
/// lifecycle to flush any pending events when the app is about to move to the background.
///
/// This actor is designed to be decoupled and testable. While `RelayEventBuffer` handles
/// in-memory event storage and batched flushing, this controller handles **when** those
/// flushes occur.
///
/// By separating timing logic from buffer logic, the system gains modularity, composability,
/// and improved testability.
///
/// - Note: This controller uses non-blocking `Task.sleep` for scheduling instead of timers.
/// - Important: Always call `stop()` when shutting down to cancel the flush task.
///
/// Example usage:
///
/// ```swift
/// let flushController = RelayFlushController(interval: 5.0, lifecycleObserver: observer)
/// flushController.start(buffer: buffer)
/// ```
///
/// - SeeAlso: `RelayEventBuffer`, `LifecycleObserver`
actor RelayFlushController {
    private var flushTask: Task<Void, Never>?
    private let interval: TimeInterval
    private let lifecycleObserver: LifecycleObserver

    /// Creates a new flush controller that triggers flushes on a set interval and app background.
    ///
    /// - Parameters:
    ///   - interval: Time interval (in seconds) between flushes. Default is 5 seconds.
    ///   - lifecycleObserver: An observer for app lifecycle events used to flush on background.
    init(interval: TimeInterval = 5.0, lifecycleObserver: LifecycleObserver) {
        self.interval = interval
        self.lifecycleObserver = lifecycleObserver
    }

    /// Starts the periodic flush loop using Swift Concurrency.
    ///
    /// This schedules a background task that repeatedly calls `flush()` on the provided
    /// buffer using `Task.sleep(nanoseconds:)` for interval-based timing. The task is
    /// suspendable, cancelable, and runs independently of the main thread.
    ///
    /// In addition, a one-time flush will be triggered when the app is about to resign
    /// active (e.g., when sent to the background), ensuring that in-memory telemetry
    /// is persisted before the app is suspended.
    ///
    /// - Parameter buffer: The `RelayEventBuffer` to flush at regular intervals.
    func start(buffer: RelayEventBuffer) {
        flushTask?.cancel()

        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                await buffer.flush()
            }
        }

        lifecycleObserver.observeWillResignActive {
            Task {
                await buffer.flush()
            }
        }
    }

    /// Stops the periodic flush loop and cancels any scheduled tasks.
    ///
    /// This should be called when the buffer is being torn down (e.g., on app shutdown
    /// or test cleanup) to prevent orphaned background tasks from continuing to run.
    func stop() {
        flushTask?.cancel()
        flushTask = nil
    }
}
