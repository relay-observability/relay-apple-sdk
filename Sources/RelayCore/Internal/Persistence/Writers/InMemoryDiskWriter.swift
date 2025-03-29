import Foundation

/// A testable, non-persistent writer that just stores events in memory.
public final class InMemoryDiskWriter: EventPersisting {
    public private(set) var events: [RelayEvent] = []

    public init() {}

    public func write(_ events: [RelayEvent]) {
        self.events.append(contentsOf: events)
    }

    public func clear() {
        events.removeAll()
    }
}
