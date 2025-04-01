//
//  CleanupManager.swift
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

final actor CleanupManager {
    private let directory: URL
    private let fileSystem: FileSystem
    private let config: FileDiskWriterConfiguration
    private let cleanupErrorHandler: ((Error) -> Void)?

    init(directory: URL,
         fileSystem: FileSystem,
         config: FileDiskWriterConfiguration,
         cleanupErrorHandler: ((Error) -> Void)? = nil) {
        self.directory = directory
        self.fileSystem = fileSystem
        self.config = config
        self.cleanupErrorHandler = cleanupErrorHandler
    }

    struct FileInfo {
        let fileURL: URL
        let fileSize: Int
        let creationDate: Date
    }

    /// Performs cleanup by removing expired files and ensuring total disk usage is under the limit.
    func performCleanup() async {
        do {
            // Remove expired files.
            let files = try fileSystem.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )
            let expirationDate = Date().addingTimeInterval(-config.fileRetentionDuration)
            for file in files {
                if let attributes = try? fileSystem.attributesOfItem(atPath: file.path),
                   let creationDate = attributes[.creationDate] as? Date,
                   creationDate < expirationDate {
                    try fileSystem.removeItem(at: file)
                }
            }

            // Enforce total disk usage limit.
            let remainingFiles = try fileSystem.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )

            var totalUsage = 0
            var fileInfos: [FileInfo] = []
            for file in remainingFiles {
                let attrs = try fileSystem.attributesOfItem(atPath: file.path)
                if let size = attrs[.size] as? Int,
                   let creationDate = attrs[.creationDate] as? Date {
                    totalUsage += size
                    fileInfos.append(FileInfo(fileURL: file, fileSize: size, creationDate: creationDate))
                }
            }

            if totalUsage > config.maxTotalDiskUsage {
                let sortedFiles = fileInfos.sorted { $0.creationDate < $1.creationDate }
                for fileInfo in sortedFiles {
                    try fileSystem.removeItem(at: fileInfo.fileURL)
                    totalUsage -= fileInfo.fileSize
                    if totalUsage <= config.maxTotalDiskUsage { break }
                }
            }
        } catch {
            // TODO: Decide how the SDK should handle errors
            // We can delegate errors, collect metrics, or silently fail
            // We could have an optional error handler that is called with any error that occurs during cleanup
            // If no error handler is provided, cleanup errors are silently ignored, ensuring that the cleanup process is best-effort without affect the rest of the SDK
            // The goal is to keep th SDK lightweight while allowing flexibility for production usage.
            cleanupErrorHandler?(error)
        }
    }
}
