//
//  RelayEvent.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// A generic telemetry event that Relay plugins emit and exporters handle.
public struct RelayEvent {
    public let name: String
    public let timestamp: Date

    // TODO: - Benchmark impact of AnyCodable for high frequency events
    public let attributes: [String: AnyCodable]

    public init(name: String, timestamp: Date = Date(), attributes: [String: AnyCodable]) {
        self.name = name
        self.timestamp = timestamp
        self.attributes = attributes
    }
}
