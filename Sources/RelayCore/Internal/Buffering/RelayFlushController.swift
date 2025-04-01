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

/// A controller that manages the cadence of flushes from a RelayEventBuffer.
///
/// `RelayFlushController` is responsible for periodically flushing the event buffer—both on a timer
/// and during critical lifecycle events. This decouples the timing logic from the buffer itself,
/// improving modularity and testability.
///
/// Features:
/// - **Timer-Based Flush:** Flushes the buffer at a configured interval (default is every 5 seconds).
/// - **Lifecycle-Based Flush:** Observes app lifecycle events (via `LifecycleObserver`)
///   and triggers a flush when the app is about to resign active (e.g. move to background).
/// - **Manual Flush:** Exposes a `flush()` method to allow external components to force a flush.
/// - **Cooperative Scheduling:** If a Scheduler is provided, flush tasks will be scheduled cooperatively.
/// - **Safe Shutdown:** The flush task is cancelable via `stop()`.
///
/// Example usage:
/// ```swift
/// let flushController = RelayFlushController(interval: 5.0, lifecycleObserver: observer, scheduler: myScheduler)
/// flushController.start(buffer: eventBuffer)
/// // Later on, an external component can manually trigger a flush:
/// await flushController.flush()
/// // On shutdown:
/// flushController.stop()
/// ```
actor RelayFlushController {
    private var flushTask: Task<Void, Never>?
    private let interval: TimeInterval
    private let lifecycleObserver: LifecycleObserver
    private let scheduler: Scheduler
    private var buffer: RelayEventBuffer?

    /// Creates a new flush controller that triggers flushes at a given interval and during critical lifecycle events.
    ///
    /// - Parameters:
    ///   - interval: The time interval (in seconds) between flushes. Default is 5 seconds.
    ///   - lifecycleObserver: An observer for app lifecycle events to trigger flushes on background.
    ///   - scheduler: An optional Scheduler to coordinate flush tasks. If nil, Task.sleep is used.
    init(
        interval: TimeInterval = 5.0,
        lifecycleObserver: LifecycleObserver,
        scheduler: Scheduler = DefaultScheduler()
    ) {
        self.interval = interval
        self.lifecycleObserver = lifecycleObserver
        self.scheduler = scheduler
    }

    /// Starts the flush loop using the provided `RelayEventBuffer`.
    ///
    /// This method stores the buffer reference, starts a periodic task to flush it, and hooks into
    /// lifecycle events so that a flush occurs when the app is about to resign active.
    ///
    /// - Parameter buffer: The RelayEventBuffer instance that holds events to be flushed.
    func start(buffer: RelayEventBuffer) {
        self.buffer = buffer
        flushTask?.cancel()

        flushTask = Task<Void, Never> {
            while !Task.isCancelled {
                do {
                    try await scheduler.schedule {
                        await self.flush()
                    }
                } catch {
                    // Log the error and optionally emit metrics.
                    print("Flush task error: \(error)")
                    
                    do {
                        // Optionally, if we have a metricsEmitter, emit a flush failure metric here.
                        // Wait for a short period to avoid a tight error loop.
                        try await Task.sleep(nanoseconds: UInt64(1_000_000_000)) // 1 second
                    } catch {
                        print("Sleep error: \(error)")
                    }
                    
                }
            }
        }

        // Trigger an immediate flush when the app is about to move to the background.
        lifecycleObserver.observeWillResignActive { [weak self] in
            Task { [weak self] in
                await self?.flush()
            }
        }
    }

    /// Manually triggers a flush of the event buffer.
    ///
    /// This method can be invoked externally to force an immediate flush.
    func flush() async {
        guard let buffer = self.buffer else { return }
        await buffer.flush()
    }

    /// Stops the periodic flush loop and cancels any scheduled flush tasks.
    ///
    /// Call this method during shutdown to clean up background tasks.
    func stop() {
        flushTask?.cancel()
        flushTask = nil
    }
}
