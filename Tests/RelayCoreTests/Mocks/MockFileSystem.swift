//
//  MockFileSystem.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation
import RelayCommon

final class MockFileSystem: FileSystem {
    var files: [URL: Data] = [:]

    func append(data: Data, to url: URL) throws {
        if let existing = files[url] {
            files[url] = existing + data
        } else {
            files[url] = data
        }
    }

    func writeAtomically(data: Data, to url: URL, options _: Data.WritingOptions) throws {
        files[url] = data
    }

    func contentsOfDirectory(at _: URL,
                             includingPropertiesForKeys _: [URLResourceKey]?,
                             options _: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
        return Array(files.keys)
    }

    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        // Use the URL string as a key to get Data size and fake creation date.
        guard let url = URL(string: path), let data = files[url] else {
            throw NSError(domain: "MockFileSystem", code: 0, userInfo: nil)
        }
        // For simplicity, we'll assign a fixed creation date.
        return [
            .size: data.count,
            .creationDate: Date(timeIntervalSince1970: 1000) // fixed value for tests
        ]
    }

    func removeItem(at url: URL) throws {
        files.removeValue(forKey: url)
    }
}

// MARK: - Mock Cleanup Manager

final actor MockCleanupManager {
    private(set) var cleanupCalled = false

    func performCleanup() async {
        cleanupCalled = true
    }
}
