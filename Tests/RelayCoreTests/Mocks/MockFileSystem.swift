import Foundation

@testable import RelayCore

final class MockFileSystem: FileSystem {
    var files: [URL: Data] = [:]

    func append(data: Data, to url: URL) throws {
        if let existing = files[url] {
            files[url] = existing + data
        } else {
            files[url] = data
        }
    }
    
    func writeAtomically(data: Data, to url: URL, options: Data.WritingOptions) throws {
        files[url] = data
    }
    
    func contentsOfDirectory(at url: URL,
                             includingPropertiesForKeys keys: [URLResourceKey]?,
                             options: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
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
