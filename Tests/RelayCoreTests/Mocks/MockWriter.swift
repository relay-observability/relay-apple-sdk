@testable import RelayCore

final class MockWriter: EventPersisting {
    var captured: [[RelayEvent]] = []
    
    func write(_ events: [RelayEvent]) async {
        captured.append(events)
    }
}
