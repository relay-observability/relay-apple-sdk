//
//  RelayEventID.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open‐source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/**
 A strongly-typed identifier for a RelayEvent.

 This structure enforces that each RelayEvent is identified by a UUID in production,
 ensuring type safety and consistency. For unit testing and rapid prototyping, it conforms
 to `ExpressibleByStringLiteral` so that simple string literals (e.g. "1", "test") can be
 used to generate a deterministic UUID. This approach preserves performance and safety in
 production while offering convenience in tests.

 In production, initialize RelayEventID with a valid UUID. If an invalid UUID string is
 provided, a deterministic UUID is generated from the string’s hash.
 */
public struct RelayEventID: RawRepresentable, Codable, Hashable, ExpressibleByStringLiteral, Sendable {
    /// The underlying UUID value.
    public let rawValue: UUID

    /// Creates a new RelayEventID from a UUID.
    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    /// Creates a new RelayEventID from a string.
    /// - Parameter uuidString: A string representing a UUID, or an arbitrary string in test mode.
    ///   If the string is a valid UUID, that value is used. Otherwise, a deterministic UUID is generated.
    public init(uuidString: String) {
        if let uuid = UUID(uuidString: uuidString) {
            self.rawValue = uuid
        } else {
            let generatedUUIDString = Self.makeUUIDString(from: uuidString)
            guard let generatedUUID = UUID(uuidString: generatedUUIDString) else {
                fatalError("Failed to generate a valid UUID from string: \(uuidString)")
            }
            self.rawValue = generatedUUID
        }
    }

    /// Initializes a RelayEventID using a string literal.
    /// This initializer is primarily for testing convenience.
    public init(stringLiteral value: String) {
        self.init(uuidString: value)
    }

    /// Generates a deterministic UUID string from an arbitrary string.
    /// This method converts the string's hash value into a 32-character hexadecimal string
    /// and formats it as a UUID (8-4-4-4-12). This ensures that even non-UUID strings yield
    /// a valid UUID, preserving production type safety.
    private static func makeUUIDString(from string: String) -> String {
        let hash = string.hashValue.magnitude
        let hex = String(format: "%032llx", hash)
        
        // swiftlint:disable line_length
        let uuidString = "\(hex.prefix(8))-\(hex.dropFirst(8).prefix(4))-\(hex.dropFirst(12).prefix(4))-\(hex.dropFirst(16).prefix(4))-\(hex.dropFirst(20).prefix(12))"
        // swiftlint:enable line_length
        
        return uuidString
    }
}
