import Foundation
@testable import RelayCore

final class MockWriter: EventPersisting {
    private let delay: TimeInterval
    var captured: [[RelayEvent]] = []

    init(delay: TimeInterval = 0.0) {
        self.delay = delay
    }

    func write(_ events: [RelayEvent]) async {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        captured.append(events)
    }
}
