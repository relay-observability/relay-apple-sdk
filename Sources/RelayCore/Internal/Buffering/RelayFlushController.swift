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

/// A controller that manages the cadence of flushes from a `RelayEventBuffer`.
///
/// `RelayFlushController` is responsible for periodically flushing the event buffer—both on a timer
/// and during critical lifecycle events. This decouples the scheduling logic from the buffer itself,
/// improving testability and separation of concerns.
///
/// ### Flush Strategies:
/// - **Timer-Based Flush:** Triggers flushes at a fixed interval using a `Scheduler` (default: every 5 seconds).
/// - **Lifecycle-Based Flush:** Hooks into app lifecycle events (via `LifecycleObserver`) and flushes on background.
/// - **Manual Flush:** Exposes a `flush()` method for on-demand flushes by external components.
///
/// ### Design Rationale:
/// - The `RelayEventBuffer` is passed into `start(buffer:)` rather than the initializer.
///   This allows:
///   - Separation of **construction** and **execution**
///   - Flexible **test configuration** (buffer, scheduler, lifecycle observer)
///   - Support for **resetting or swapping buffers** without recreating the controller
/// - Lifecycle observation and periodic scheduling are **only activated when `start()` is called**, avoiding early or duplicated subscriptions.
///
/// ### Usage:
/// ```swift
/// let flushController = RelayFlushController(interval: 5.0, lifecycleObserver: observer, scheduler: scheduler)
/// flushController.start(buffer: eventBuffer)  // Begin flushing
/// await flushController.flush()               // Optionally flush immediately
/// flushController.stop()                      // Cancel background flushes on shutdown
/// ```
actor RelayFlushController {
    private var flushTask: Task<Void, Never>?
    private let interval: TimeInterval
    private let lifecycleObserver: LifecycleObserver
    private let scheduler: Scheduler
    private var buffer: EventBuffer?

    /// Creates a new flush controller that triggers flushes at a given interval and during critical lifecycle events.
    ///
    /// - Parameters:
    ///   - interval: The time interval (in seconds) between flushes. Default is 5 seconds.
    ///   - lifecycleObserver: An observer for app lifecycle events to trigger flushes on background.
    ///   - scheduler: A `Scheduler` to coordinate flush timing. Can be a test scheduler or custom implementation.
    init(
        interval: TimeInterval = 5.0,
        lifecycleObserver: LifecycleObserver,
        scheduler: Scheduler = DefaultScheduler()
    ) {
        self.interval = interval
        self.lifecycleObserver = lifecycleObserver
        self.scheduler = scheduler
    }

    /// Starts the flush loop using the provided `EventBuffer`.
    ///
    /// This method:
    /// - Stores a reference to the provided event buffer
    /// - Starts a periodic task to flush it using the scheduler
    /// - Hooks into app lifecycle events to flush when the app resigns active
    ///
    /// - Parameter buffer: The buffer that holds events to be flushed. Required to begin scheduling.
    ///
    /// > Important: `start(buffer:)` **must be called after construction** to begin flushing.
    /// > You can safely call `start(buffer:)` more than once; previous flush tasks will be cancelled.
    func start(buffer: EventBuffer) {
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

                    // Avoid tight-looping if the scheduler keeps failing.
                    do {
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
    /// Call this when an immediate flush is needed (e.g. app shutdown, significant event).
    /// If no buffer has been provided via `start(buffer:)`, this method does nothing.
    func flush() async {
        guard let buffer = self.buffer else { return }
        await buffer.flush()
    }

    /// Stops the periodic flush loop and cancels any scheduled flush tasks.
    ///
    /// Call this during app teardown or when the controller is no longer needed.
    /// Safe to call multiple times.
    func stop() {
        flushTask?.cancel()
        flushTask = nil
    }
}
