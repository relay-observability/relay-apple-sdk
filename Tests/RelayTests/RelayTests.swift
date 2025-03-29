@testable import Relay
import XCTest

final class RelayTests: XCTestCase {
    func test_validTest() {
        XCTAssertEqual(Relay.one.rawValue, 1)
    }
}
