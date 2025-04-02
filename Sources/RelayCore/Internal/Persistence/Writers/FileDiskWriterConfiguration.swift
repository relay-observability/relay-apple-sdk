//
//  FileDiskWriterConfiguration.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

public typealias FileNamingStrategy = @Sendable (Date) -> String

/// Configuration for the FileDiskWriter.
/// These settings control file rotation and cleanup.
public struct FileDiskWriterConfiguration: Sendable {
    /// Maximum file size in bytes before rotation occurs.
    public var maxFileSize: Int
    /// Maximum number of events to write in one file.
    public var maxEventsPerFile: Int
    /// Maximum total disk usage in bytes for event files.
    public var maxTotalDiskUsage: Int
    /// How long files should be kept before being considered expired (in seconds).
    public var fileRetentionDuration: TimeInterval
    /// A closure that takes the current Date and returns a file name.
    public var fileNamingStrategy: FileNamingStrategy
    /// Maximum number of retry attempts when writing events to disk fails.
    public var maxAttempts: Int = 5
    /// The number of milliseconds to wait after the first write failure by default.
    /// The default value is 50 milliseconds (ms).
    public var initialDelay: TimeInterval = 50 / 1000
    /// Emits metrics about the SDK.
    public var metricsEmitter: MetricsEmitter

    public init(
        maxFileSize: Int = 1_000_000, // 1 MB per file
        maxEventsPerFile: Int = 1000, // 1000 events per file
        maxTotalDiskUsage: Int = 10_000_000, // 10 MB total storage for files
        fileRetentionDuration: TimeInterval = 7 * 24 * 3600, // 7 days
        metricsEmitter: MetricsEmitter = NoOpMetricsEmitter(),
        fileNamingStrategy: @escaping FileNamingStrategy = { date in
            // Default: use timestamp-based file naming with a unique UUID to avoid collisions with .dat extension
            "events_\(Int(date.timeIntervalSince1970))_\(UUID().uuidString).dat"
        }
    ) {
        self.maxFileSize = maxFileSize
        self.maxEventsPerFile = maxEventsPerFile
        self.maxTotalDiskUsage = maxTotalDiskUsage
        self.fileRetentionDuration = fileRetentionDuration
        self.metricsEmitter = metricsEmitter
        self.fileNamingStrategy = fileNamingStrategy
    }

    // TODO: Decide if this I want to provide configurations or just suggest the default to reduce the number of configurations needed
    public static let `default`: FileDiskWriterConfiguration = .init()
}
