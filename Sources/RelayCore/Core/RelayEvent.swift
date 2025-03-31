//
//  RelayEvent.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/**
 A generic telemetry event that Relay plugins emit and exporters handle.

 This struct represents a telemetry event with a unique identifier, a name, a timestamp, and a set of attributes.
 
 **Design Considerations:**
 - Uses strongly typed attributes via `TelemetryAttribute` instead of a fully dynamic type like `AnyCodable`.
 - This design preserves type information, enabling better performance and more precise handling in high-frequency scenarios,
   such as UI latency, network requests, and disk persistence.
 - The use of strongly typed attributes allows for optimized serialization and downstream processing, without the overhead of
   runtime type erasure.
 */
public struct RelayEvent: Codable, Sendable, Identifiable, Hashable {
    /// A unique identifier for the event.
    public let id: RelayEventID
    /// The name or type of the event.
    public let name: String
    /// The timestamp when the event occurred.
    public let timestamp: Date
    /// A dictionary of event attributes using strongly typed values.
    public let attributes: [String: TelemetryAttribute]

    /// Creates a new RelayEvent.
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new UUID.
    ///   - name: A descriptive name for the event.
    ///   - timestamp: The time of the event. Defaults to the current date and time.
    ///   - attributes: A dictionary of additional metadata. Defaults to an empty dictionary.
    public init(
        id: RelayEventID,
        name: String,
        timestamp: Date = Date(),
        attributes: [String: TelemetryAttribute] = [:]
    ) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.attributes = attributes
    }
}
