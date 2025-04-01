//
//  NoOpMetricsEmitter.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import RelayCommon

/// A no-op implementation, used if the integrator does not supply an emitter.
public struct NoOpMetricsEmitter: MetricsEmitter {
    public init() {}

    public func emitMetric(name _: String, value _: Double, tags _: [String: TelemetryAttribute]?) {}
}
