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

/// The default implementation of FileSystem using FileManager.
public struct DefaultFileSystem: FileSystem {
    public init() {}
    
    public func append(data: Data, to url: URL) throws {
        if let handle = try? FileHandle(forWritingTo: url) {
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
            try handle.close()
        } else {
            try data.write(to: url, options: [.atomic])
        }
    }
    
    public func writeAtomically(
        data: Data,
        to url: URL,
        options: Data.WritingOptions = [.atomic]
    ) throws {
        try data.write(to: url, options: options)
    }
    
    public func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]? = nil,
        options: FileManager.DirectoryEnumerationOptions = .skipsHiddenFiles
    ) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: options)
    }
    
    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        return try FileManager.default.attributesOfItem(atPath: path)
    }
    
    public func removeItem(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
