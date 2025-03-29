import XCTest
@testable import RelayCore

final class FileDiskWriterTests: XCTestCase {

    func testWritesEventsToDisk() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let serializer = JSONEventSerializer()
        let writer = FileDiskWriter(directory: tempDir, serializer: serializer)
        let events = [RelayEvent.mock(), RelayEvent.mock()]

        writer.write(events)

        let contents = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        XCTAssertEqual(contents.count, 1)

        let data = try Data(contentsOf: contents[0])
        XCTAssertFalse(data.isEmpty)
    }
}
