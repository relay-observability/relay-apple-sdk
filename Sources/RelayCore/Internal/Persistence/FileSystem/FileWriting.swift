//
//  FileWriting.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// A protocol that abstracts file writing operations.
/// This allows the SDK to write data to disk without depending directly on FileHandle.
public protocol FileWriting: Sendable {
    /// Appends data to the file at the given URL.
    /// - Parameter data: The data to append.
    /// - Parameter url: The URL of the file to which data will be appended.
    func append(data: Data, to url: URL) throws

    /// Writes data to the file at the given URL atomically.
    /// - Parameter data: The data to write.
    /// - Parameter url: The URL of the file.
    /// - Parameter options: The writing options (defaults to atomic).
    func writeAtomically(data: Data, to url: URL, options: Data.WritingOptions) throws
}

/// The default implementation of FileWriting using FileHandle and Data.write.
public struct DefaultFileWriter: FileWriting {
    public init() {}

    public func append(data: Data, to url: URL) throws {
        // Attempt to open the file for appending.
        if let handle = try? FileHandle(forWritingTo: url) {
            // Seek to the end of the file.
            try handle.seekToEnd()
            // Write the data.
            try handle.write(contentsOf: data)
            try handle.close()
        } else {
            // If unable to open the file (it might not exist), perform an atomic write.
            try data.write(to: url, options: [.atomic])
        }
    }

    public func writeAtomically(data: Data, to url: URL, options: Data.WritingOptions = [.atomic]) throws {
        try data.write(to: url, options: options)
    }
}
