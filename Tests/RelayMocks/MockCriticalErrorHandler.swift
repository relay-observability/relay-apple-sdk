import RelayCommon

final class MockCriticalErrorHandler: CriticalErrorHandler {
    func handleCriticalError(_ error: Swift.Error) {
        // No-op for now
    }
}
