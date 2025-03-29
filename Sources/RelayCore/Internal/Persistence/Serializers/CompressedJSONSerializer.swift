//
//  CompressedJSONSerializer.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// Stubbed implementation for compression support.
/// Future: Use Apple's Compression framework or zstd for performance.
public final class CompressedJSONSerializer: EventSerializer {
    public init() {}

    public func encode(_ events: [RelayEvent]) throws -> Data {
        // Stub: Just use normal JSON for now.
        let encoder = JSONEncoder()
        let data = try encoder.encode(events)
        // TODO: Apply compression (e.g. zlib, zstd)
        return data
    }
}
