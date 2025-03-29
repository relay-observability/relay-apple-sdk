import Foundation

/// Protocol for writing Relay events to a persistent store (e.g. disk, memory, etc.).
public protocol EventPersisting {
    func write(_ events: [RelayEvent])
}
