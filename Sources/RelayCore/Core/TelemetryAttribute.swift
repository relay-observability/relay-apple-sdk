//
//  TelemetryAttribute.swift
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
 An enumeration representing strongly-typed telemetry attribute values.

 `TelemetryAttribute` encapsulates the values used in Relay's telemetry events. It is designed to provide a
 type-safe and efficient alternative to fully dynamic solutions like `AnyCodable`, which can incur performance
 overhead due to runtime type checking and boxing. By using a strongly-typed enum, Relay ensures that high-frequency
 events (such as UI latency metrics, network request timings, and disk persistence events) are processed with minimal
 overhead.

 ## Intention
 - **Performance:** Avoids the runtime costs associated with type erasure, making it suitable for high-throughput
   telemetry scenarios.
 - **Type Safety:** Enforces compile-time checks and leverages Swift's strong typing to ensure that each attribute
   is used correctly.
 - **Extensibility:** While currently supporting `String`, `Int`, `Double`, and `Bool`, the enum can be extended
   to support additional types as needed.
 - **Interoperability:** Provides a `stringValue` computed property to convert attribute values to strings, which is
   useful when exporting to systems that require string-based key-value pairs.

 ## Design
 The enum offers a limited set of cases for common data types:
 - `.string(String)` for textual values.
 - `.int(Int)` for integer values.
 - `.double(Double)` for floating-point values.
 - `.bool(Bool)` for boolean values.

 Each case is encoded and decoded using a standard `JSONEncoder`/`JSONDecoder`, ensuring that the original type
 information is preserved internally. When required, the `stringValue` property converts any attribute to its string
 representation for export.

 ## Why Not Use AnyCodable?
 Using a type-erased solution like `AnyCodable` provides flexibility but comes at a significant performance cost:
 - **Runtime Overhead:** `AnyCodable` relies on dynamic type checking and reflection, which slows down encoding/decoding.
 - **Memory Overhead:** Boxing of values in `Any` can increase memory usage, which is critical in high-frequency,
   low-latency environments.
 - **Loss of Optimization:** Strongly-typed values allow the compiler and runtime to optimize code paths, which is
   lost when using a generic type erasure.

 ## Usage Example
 ```swift
 let attribute1: TelemetryAttribute = .string("example")
 let attribute2: TelemetryAttribute = .int(42)
 let attribute3: TelemetryAttribute = .double(3.14)
 let attribute4: TelemetryAttribute = .bool(true)

 print(attribute1.stringValue) // "example"
 print(attribute2.stringValue) // "42"
*/
public enum TelemetryAttribute: Codable, Hashable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    
    public var stringValue: String {
        switch self {
        case .string(let value): return value
        case .int(let value): return String(value)
        case .double(let value): return String(value)
        case .bool(let value): return String(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Unsupported TelemetryAttribute type"
            )
            throw DecodingError.typeMismatch(TelemetryAttribute.self, context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        }
    }
}
