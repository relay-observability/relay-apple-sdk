//
//  CompressedJSONSerializer.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

struct CompressedEventSerializer: EventSerializer {
    let base: EventSerializer
    let compressor: DataCompressor

    func encode(_ events: [RelayEvent]) throws -> Data {
        let raw = try base.encode(events)
        return try compressor.compress(raw)
    }

    func decode(_ data: Data) throws -> [RelayEvent] {
        let raw = try compressor.decompress(data)
        return try base.decode(raw)
    }
}
