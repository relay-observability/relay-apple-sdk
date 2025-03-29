//
//  RelayFlushController.swift
//  RelayCore
//

import Foundation

actor RelayFlushController {
    private var flushTask: Task<Void, Never>?
    private let interval: TimeInterval
    private let lifecycleObserver: LifecycleObserver

    init(interval: TimeInterval = 5.0, lifecycleObserver: LifecycleObserver) {
        self.interval = interval
        self.lifecycleObserver = lifecycleObserver
    }

    /// Starts the periodic flush loop using Swift Concurrency.
    ///
    /// This method schedules a background task that flushes the provided `RelayEventBuffer`
    /// at regular intervals using `Task.sleep`, which is a suspending, non-blocking sleep
    /// function provided by Swift Concurrency. This approach avoids blocking threads or
    /// requiring explicit timers.
    ///
    /// The task is safely cancellable and automatically suspended between flushes. It will
    /// flush one last time if the app is sent to the background (via lifecycle observation).
    ///
    /// - Parameter buffer: The in-memory event buffer to flush on a schedule.
    func start(buffer: RelayEventBuffer) {
        // Cancel any existing flush loop
        flushTask?.cancel()

        flushTask = Task {
            while !Task.isCancelled {
                // Uses non-blocking sleep to wait for the interval duration
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

    func stop() {
        flushTask?.cancel()
        flushTask = nil
    }
}
