//
//  MockWriter.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation
@testable import RelayCore

final class MockWriter: EventPersisting {
    private let delay: TimeInterval
    var captured: [[RelayEvent]] = []

    init(delay: TimeInterval = 0.0) {
        self.delay = delay
    }

    func write(_ events: [RelayEvent]) async {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        captured.append(events)
    }
}

/// A simple in‑memory file store that simulates file system operations.
final class MockFileStore: @unchecked Sendable {
    /// Stores file data mapped by URL.
    var files: [URL: Data] = [:]
    
    public init() {}
    
    /// Simulates appending data to a file.
    func append(data: Data, to url: URL) throws {
        if let existingData = files[url] {
            files[url] = existingData + data
        } else {
            files[url] = data
        }
    }
    
    /// Simulates an atomic write to a file.
    func writeAtomically(data: Data, to url: URL, options: Data.WritingOptions = [.atomic]) throws {
        files[url] = data
    }
}

/// A mock file writer that implements FileWriting by leveraging the MockFileStore.
struct MockFileWriter: FileWriting {
    let fileStore: MockFileStore

    init(fileStore: MockFileStore = MockFileStore()) {
        self.fileStore = fileStore
    }
    
    func append(data: Data, to url: URL) throws {
        try fileStore.append(data: data, to: url)
    }
    
    func writeAtomically(data: Data, to url: URL, options: Data.WritingOptions = [.atomic]) throws {
        try fileStore.writeAtomically(data: data, to: url, options: options)
    }
}
