import Foundation

public protocol EventSerializer {
    func encode(_ events: [RelayEvent]) throws -> Data
}
