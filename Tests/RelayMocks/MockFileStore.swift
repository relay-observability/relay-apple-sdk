import Foundation

/// A simple in‑memory file store that simulates file system operations.
public final class MockFileStore: @unchecked Sendable {
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
    func writeAtomically(data: Data, to url: URL, options _: Data.WritingOptions = [.atomic]) throws {
        files[url] = data
    }
}
