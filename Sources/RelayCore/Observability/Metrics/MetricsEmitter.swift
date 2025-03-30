//
//  MetricsEmitter.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

/// A protocol for emitting SDK metrics. Implementers can forward metrics to a monitoring backend.
public protocol MetricsEmitter: Sendable {
    /// Emits a metric with a name, value, and optional tags.
    func emitMetric(name: String, value: Double, tags: [String: TelemetryAttribute]?)
}
