import Foundation
import RelayCommon
@testable import RelayCore

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
