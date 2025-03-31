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
struct JSONEventSerializer: EventSerializer {
    private let debug: Bool

    private var outputFormat: JSONEncoder.OutputFormatting {
        debug ? [.prettyPrinted, .sortedKeys] : []
    }

    func encode(_ events: [RelayEvent]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormat
        return try encoder.encode(events)
    }

    func decode(_ data: Data) throws -> [RelayEvent] {
        let decoder = JSONDecoder()
        return try decoder.decode([RelayEvent].self, from: data)
    }
}
