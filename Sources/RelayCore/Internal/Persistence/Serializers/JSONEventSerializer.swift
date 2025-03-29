//
//  JSONEventSerializer.swift
//  RelayCore
//

import Foundation

/// A simple, pluggable serializer that encodes an array of `RelayEvent` into JSON `Data`.
public final class JSONEventSerializer: EventSerializer {

    private let encoder: JSONEncoder

    public init(prettyPrinted: Bool = false) {
        self.encoder = JSONEncoder()
        if prettyPrinted {
            self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
    }

    public func encode(_ events: [RelayEvent]) throws -> Data {
        return try encoder.encode(events)
    }
}
