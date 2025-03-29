import XCTest
@testable import RelayCore

final class JSONEventSerializerTests: XCTestCase {

    func testCanEncodeEventsToJSON() throws {
        let events = [
            RelayEvent.mock(id: "1", name: "test"),
            RelayEvent.mock(id: "2", name: "load")
        ]
        let serializer = JSONEventSerializer()
        let data = try serializer.encode(events)
        XCTAssertFalse(data.isEmpty)
    }
}
