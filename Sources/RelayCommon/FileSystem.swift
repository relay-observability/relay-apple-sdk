import Foundation

/// A protocol that abstracts file operations, including writing and file management.
public protocol FileSystem: Sendable {
    // Writing operations.
    func append(data: Data, to url: URL) throws
    func writeAtomically(data: Data, to url: URL, options: Data.WritingOptions) throws

    // File management operations.
    func contentsOfDirectory(at url: URL,
                             includingPropertiesForKeys keys: [URLResourceKey]?,
                             options: FileManager.DirectoryEnumerationOptions) throws -> [URL]
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any]
    func removeItem(at url: URL) throws
}
