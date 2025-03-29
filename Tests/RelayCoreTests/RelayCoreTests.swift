@testable import RelayCore
import XCTest

final class RelayCoreTests: XCTestCase {
    func test_validTest() {
        XCTAssertEqual(RelayCore.one.rawValue, 1)
    }
}
