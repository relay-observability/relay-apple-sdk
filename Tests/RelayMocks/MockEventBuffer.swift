import Foundation
import RelayCommon

@testable import RelayCore

actor MockEventBuffer: EventBuffer {

    private(set) var addedEvents: [RelayEvent] = []
    private(set) var flushCallCount = 0
    private(set) var startPeriodicFlushCallCount = 0
    private(set) var stopFlushCallCount = 0
    private(set) var lastInterval: TimeInterval?

    #if DEBUG
    var flushTaskID: UUID? = UUID()
    #endif

    let capacity: Int

    init(capacity: Int = 10) {
        self.capacity = capacity
    }

    func add(_ event: RelayEvent) async {
        addedEvents.append(event)
    }

    func flush() async {
        flushCallCount += 1
    }

    func startPeriodicFlush(interval: TimeInterval) {
        startPeriodicFlushCallCount += 1
        lastInterval = interval
    }

    func stopFlush() async {
        stopFlushCallCount += 1
    }
}
