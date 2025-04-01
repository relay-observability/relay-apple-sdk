import Foundation
import RelayCommon

public final class MockEventSerializer: EventSerializer {
    public var encodeCallCount = 0
    public var decodeCallCount = 0

    public var shouldThrow = false
    public var shouldFailOnce = false
    public var shouldAlwaysFail = false

    public private(set) var lastEncodedEvents: [RelayEvent] = []
    public private(set) var lastDecodedData: Data?

    public init() {}

    public func encode(_ events: [RelayEvent]) throws -> Data {
        encodeCallCount += 1
        lastEncodedEvents = events

        if shouldAlwaysFail || (shouldFailOnce && encodeCallCount == 1) || shouldThrow {
            throw NSError(domain: "mock.serializer.encode", code: -1)
        }

        return Data("encoded-\(events.count)".utf8)
    }

    public func decode(_ data: Data) throws -> [RelayEvent] {
        decodeCallCount += 1
        lastDecodedData = data

        if shouldThrow {
            throw NSError(domain: "mock.serializer.decode", code: -2)
        }

        // Return dummy decoded events
        return [RelayEvent.mock(name: "decoded")]
    }
}
