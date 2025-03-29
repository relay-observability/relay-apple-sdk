import XCTest
@testable import RelayCore

final class RetryPolicyTests: XCTestCase {

    enum DummyError: Error { case fail }

    func testCustomPolicyEvaluatesCorrectly() {
        let policy = RetryPolicy.custom { error in
            if case DummyError.fail = error {
                return true
            }
            return false
        }

        switch policy {
        case .custom(let evaluator):
            XCTAssertTrue(evaluator(DummyError.fail))
        default:
            XCTFail("Expected custom policy")
        }
    }

    func testExponentialBackoffStoresValues() {
        let policy = RetryPolicy.exponentialBackoff(retries: 3, initialDelay: 0.5)

        switch policy {
        case .exponentialBackoff(let retries, let delay):
            XCTAssertEqual(retries, 3)
            XCTAssertEqual(delay, 0.5)
        default:
            XCTFail("Expected exponential backoff policy")
        }
    }
}
