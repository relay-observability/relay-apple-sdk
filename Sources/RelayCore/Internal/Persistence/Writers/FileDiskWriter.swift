//
//  FileDiskWriter.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// An actor-based file writer that writes batches of events to disk.
/// It rotates files when a file reaches the configured limits and delegates cleanup to a separate actor.
/// The file writer supports configurable retry logic for transient write failures.
final actor FileDiskWriter: EventPersisting {
    
    // MARK: - Types
    
    /// Errors thrown by the FileDiskWriter.
    enum Error: Swift.Error, Sendable {
        /// Indicates that there is no current file available.
        case noCurrentFile
        /// Indicates that file creation failed, along with a description.
        case fileCreationFailed(reason: String)
    }
    
    /// Structure representing the current file being written to.
    private struct CurrentFile {
        /// The file URL.
        let url: URL
        /// The current number of events written to this file.
        var eventCount: Int
        /// The current file size in bytes.
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
    
    /// Holds the current file metadata.
    private var currentFile: CurrentFile?
    
    // MARK: - Initialization
    
    /// Initializes a new FileDiskWriter.
    ///
    /// - Parameters:
    ///   - directory: The directory URL where event files will be stored. All files will reside in this directory.
    ///   - serializer: An object conforming to `EventSerializer` used to encode events into `Data`.
    ///   - retryPolicy: The policy for retrying failed writes. Defaults to `.none`.
    ///   - scheduler: An object conforming to `Scheduler` to offload blocking I/O operations.
    ///   - fileSystem: An object conforming to `FileSystem` for abstracting file operations.
    ///   - config: A configuration object containing thresholds for file rotation, retention, etc.
    ///   - cleanupManager: A dedicated actor responsible for cleaning up expired files and enforcing disk usage limits.
    init(
        directory: URL,
        serializer: EventSerializer,
        retryPolicy: RetryPolicy = .none,
        scheduler: Scheduler = DefaultScheduler(),
        fileSystem: FileSystem = DefaultFileSystem(),
        config: FileDiskWriterConfiguration = .init(),
        cleanupManager: CleanupManager
    ) {
        self.directory = directory
        self.serializer = serializer
        self.retryPolicy = retryPolicy
        self.scheduler = scheduler
        self.fileSystem = fileSystem
        self.config = config
        self.cleanupManager = cleanupManager
    }
    
    // MARK: - Methods
    
    /// Writes a batch of events to disk.
    ///
    /// This method encodes the events, rotates files if needed (based on size and event count),
    /// attempts to write the data with retry logic for transient errors, and then delegates cleanup.
    ///
    /// - Parameter events: An array of `RelayEvent` instances to write.
    func write(_ events: [RelayEvent]) async {
        do {
            let data = try serializer.encode(events)
            try await rotateFileIfNeeded(newDataSize: data.count, newEventCount: events.count)
            
            guard let file = currentFile else {
                throw Error.noCurrentFile
            }
            
            // Attempt to write data with retry logic.
            try await attemptWrite(data: data, to: file.url)
            
            // Update current file state.
            currentFile?.eventCount += events.count
            currentFile?.size += data.count
            
            // Emit a metric for a successful write.
            config.metricsEmitter.emitMetric(name: "file.write.success", value: Double(events.count), tags: nil)
            
            // Delegate cleanup to the CleanupManager.
            await cleanupManager.performCleanup()
        } catch {
            // Map the error to a human-readable failure reason and emit a failure metric.
            config.metricsEmitter.emitMetric(
                name: "file.write.failure",
                value: 1,
                tags: ["error": .string(FileWriteFailureReason(error: error).rawValue)]
            )
            
            // In production, replace prints with a proper error handler.
            print("❌ Failed to write events: \(error)")
            print("❌ Failure Reason: \(FileWriteFailureReason(error: error).rawValue)")
            
            // TODO: Additional retry or error handling could be implemented here.
        }
    }
    
    // MARK: - Private Methods
    
    /// Rotates the current file if appending new data would exceed configured limits.
    ///
    /// - Parameters:
    ///   - newDataSize: The size in bytes of the new data to append.
    ///   - newEventCount: The number of new events to append.
    ///
    /// - Throws: An error if file rotation fails.
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
    ///
    /// - Returns: A `CurrentFile` representing the newly created file.
    ///
    /// - Throws: `Error.fileCreationFailed` if the file cannot be created.
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
    
    /// Attempts to write data to the specified file URL using the injected file system.
    ///
    /// This method implements retry logic based on the configured `retryPolicy`. Depending on the policy,
    /// it can either attempt immediate retries up to a maximum number of attempts or use exponential backoff.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - fileURL: The URL of the file to which data should be appended.
    ///
    /// - Throws: An error if all retry attempts fail.
    private func attemptWrite(data: Data, to fileURL: URL) async throws {
        var attempt = 0
        var delay: UInt64 = 0
        let maxAttempts: Int
        
        switch retryPolicy {
        case .none:
            maxAttempts = 1
        case .immediate(let attempts):
            maxAttempts = attempts
        case .exponentialBackoff(let retries, let initialDelay):
            maxAttempts = retries
            delay = UInt64(initialDelay * 1_000_000_000) // convert seconds to nanoseconds
        case .custom:
            // For custom policies, default to immediate retries.
            maxAttempts = 3
        }
        
        while attempt < maxAttempts {
            do {
                try await scheduler.schedule {
                    try self.fileSystem.append(data: data, to: fileURL)
                }
                // Successful write; exit the retry loop.
                return
            } catch {
                attempt += 1
                if attempt >= maxAttempts {
                    throw error
                }
                // For exponential backoff, wait before the next attempt.
                if case .exponentialBackoff = retryPolicy {
                    try await Task.sleep(nanoseconds: delay)
                    // Increase delay exponentially (e.g., double it).
                    delay *= 2
                } else {
                    // For immediate retries, you might choose a small fixed delay.
                    try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                }
            }
        }
    }
}

struct FileRotationPolicy {
    let maxSize: Int
    let maxEvents: Int

    func shouldRotate(currentSize: Int, currentEvents: Int, newDataSize: Int, newEventCount: Int) -> Bool {
        return currentSize + newDataSize > maxSize ||
               currentEvents + newEventCount > maxEvents
    }
}
