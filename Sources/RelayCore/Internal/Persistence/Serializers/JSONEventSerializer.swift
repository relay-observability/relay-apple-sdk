//
//  JSONEventSerializer.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
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
