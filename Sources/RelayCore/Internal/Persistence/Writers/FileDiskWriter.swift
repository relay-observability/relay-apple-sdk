//
//  FileDiskWriter.swift
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

/// An actor-based file writer that writes batches of events to disk.
/// It rotates files when a file reaches configured limits and delegates cleanup to a separate actor.
/// It also integrates a `RetryCoordinator` for handling transient write failures.
final actor FileDiskWriter: EventPersisting {

    // MARK: - Supporting Types

    enum Error: Swift.Error, Sendable {
        case noCurrentFile
        case fileCreationFailed(reason: String)
    }

    private struct CurrentFile {
        let url: URL
        var eventCount: Int
        var size: Int
    }

    // MARK: - Dependencies and Configuration

    private let directory: URL
    private let serializer: EventSerializer
    private let retryPolicy: RetryPolicy
    private let scheduler: Scheduler
    private let fileSystem: FileSystem
    private let config: FileDiskWriterConfiguration
    private let cleanupManager: CleanupManager
    private let retryCoordinator: RetryCoordinator
    private let criticalErrorHandler: CriticalErrorHandler?

    // MARK: - State

    private var currentFile: CurrentFile?

    // MARK: - Initialization

    /// Initializes a new FileDiskWriter.
    ///
    /// - Parameters:
    ///   - directory: The directory URL where event files will be stored.
    ///   - serializer: An object conforming to `EventSerializer` used to encode events into `Data`.
    ///   - retryPolicy: The policy for retrying failed writes.
    ///   - scheduler: An object conforming to `Scheduler` to offload blocking I/O operations.
    ///   - fileSystem: An object conforming to `FileSystem` for abstracting file operations.
    ///   - config: A configuration object containing thresholds for file rotation, retention, etc.
    ///   - cleanupManager: A dedicated actor responsible for cleaning up expired files and enforcing disk usage limits.
    ///   - persistentStorage: Optional storage for persisting pending writes for crash recovery.
    init(
        directory: URL,
        serializer: EventSerializer,
        retryPolicy: RetryPolicy = .none,
        retryCoordinator: RetryCoordinator,
        scheduler: Scheduler = DefaultScheduler(),
        fileSystem: FileSystem = DefaultFileSystem(),
        config: FileDiskWriterConfiguration = .init(),
        cleanupManager: CleanupManager,
        persistentStorage: PendingWriteStorage? = nil,
        criticalErrorHandler: CriticalErrorHandler? = nil
    ) {
        self.directory = directory
        self.serializer = serializer
        self.retryPolicy = retryPolicy
        self.scheduler = scheduler
        self.fileSystem = fileSystem
        self.config = config
        self.cleanupManager = cleanupManager
        self.criticalErrorHandler = criticalErrorHandler
        self.retryCoordinator = retryCoordinator
    }

    // MARK: - Writing

    func write(_ events: [RelayEvent]) async {
        do {
            let data = try serializer.encode(events)
            try await rotateFileIfNeeded(newDataSize: data.count, newEventCount: events.count)

            guard let file = currentFile else {
                throw Error.noCurrentFile
            }

            await retryCoordinator.enqueue(PendingWrite(data: data, url: file.url))

            // Update current file state only on a successful write.
            currentFile?.eventCount += events.count
            currentFile?.size += data.count

            config.metricsEmitter.emitMetric(
                name: "file.write.success",
                value: Double(events.count),
                tags: nil
            )

            await cleanupManager.performCleanup()
        } catch {
            config.metricsEmitter.emitMetric(
                name: "file.write.failure",
                value: 1,
                tags: ["error": .string(FileWriteFailureReason(error: error).rawValue)]
            )

            print("❌ Failed to write events: \(error)")
            print("❌ Failure Reason: \(FileWriteFailureReason(error: error).rawValue)")
        }
    }

    // MARK: - Rotation

    /// Rotates the current file if appending new data would exceed configured limits.
    private func rotateFileIfNeeded(newDataSize: Int, newEventCount: Int) async throws {
        if currentFile == nil {
            currentFile = try createNewFile()
            return
        }

        guard let file = currentFile else { return }

        let rotationPolicy = FileRotationPolicy(
            maxSize: config.maxFileSize,
            maxEvents: config.maxEventsPerFile
        )

        if rotationPolicy.shouldRotate(
            currentSize: file.size,
            currentEvents: file.eventCount,
            newDataSize: newDataSize,
            newEventCount: newEventCount
        ) {
            currentFile = try createNewFile()
            config.metricsEmitter.emitMetric(name: "file.rotation", value: 1, tags: nil)
        }
    }

    /// Creates a new file for writing events.
    private func createNewFile() throws -> CurrentFile {
        let filename = config.fileNamingStrategy(Date())
        let fileURL = directory.appendingPathComponent(filename)
        do {
            try fileSystem.writeAtomically(data: Data(), to: fileURL, options: [.atomic])
        } catch {
            throw Error.fileCreationFailed(reason: error.localizedDescription)
        }
        return CurrentFile(url: fileURL, eventCount: 0, size: 0)
    }
}

/*
 
 File Disk Writer Design:
 
 - Actor based concurrency
    FileDiskWriter is a final actor, which guarantees isolation and thread-safety. Perfect for concurrent telemetry.
 - Injection of components
    FileSystem, Scheduler, CleanupManager, and EventSerializer are all injected. This makes testing and extensibility very clean.
 - File Rotation
    File rotation based on event count and file size is implemented and looks robust.
 - Clean File State Tracking
    currentFile, totalEvents, and totalBytes are simple and well-contained state.
 - Metrics Hook
    Emitting metrics like file.write.success, file.write.failure, file.rotation is excellent for monitoring.
 - Compression Support
    With CompressedEventSerializer, you’ve added gzip without polluting core writer logic.
 
 Task list Remaining:
 1. Retry Policy Implementation
    - There's backoff or retry queue
    - There's no logic for how long to retry or when to give up
    - It's unclear how I track failed batches or persisted retry attempts
    - Offline mode?
 
    Suggestions:
    - Create a RetryQueue or PendingWriteBuffer for failed writes
    - Use exponential backoff, jitter, or attempt count tracking
    - Persist failed batches to disk if recovery across launches is desired (low priority unless needed)
    - Consider emtting metrtics: `file.write.retry_attempt`, `file.write.retry_execeeded`
 2. Flush Timing / App Lifecycle
    - It's unclear if the writer:
        - flushes on app background
        - batches writes periodically
        - integrates with an external FlushController
 
    Suggestions:
        - Abstract flush coordination into FlushController
        - Inject an AppLifecycleObserver so background flush is testable and platform-neutral
        - Allow external flush() calls for manual triggers (e.g. after  cricial events)

 3. Backpresure / Drop Strategy
    - What happens when writing fails repeatedly (e.g. disk full or permission denied)?
        - Right now, it might just keep retrying indefinitely
    
    Suggestions:
    - Drop events with a warning after N attempts
    - Add a `DropPolicy` with options like `.warnAndDiscard`, `.persistFailedEvents`
 4. File Cleanup Enhancements
    - `CleanupManager` should:
        - track maximum number of files or disk quota
        - cleanup older files safely (FIFO)
 
    Sugestions:
        - Add policies like maxFileAge or maxTotalDiskBytes
        - Unit-test file cleanup behavior on threshold breach
 5. Improve Loggging
     - Inject a logger or define a RelayLogger protocol
     - Allow logs to be suppressed or routed to a backend
     - Consider adding a FileDiskWriterDelegate for more flexible hooks
 6. Unit tests
     - Write success + failure
     - Rotation based on size + count
     - Retry flow (i.e. simulate failures)
     - File cleanup behavior
     - Compression roundtrip with decode
 */
