//
//  RelayEvent+Mock.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

//
//  RelayEvent+Mock.swift
//  Relay
//
//  Created by Caleb Davis on 3/29/25.
//

import Foundation

@testable import RelayCore

extension RelayEvent {
    static func mock(
        id: RelayEventID = RelayEventID(rawValue: UUID()),
        name: String = "mock.event",
        timestamp: Date = Date(),
        attributes: [String: TelemetryAttribute] = [:]
    ) -> RelayEvent {
        RelayEvent(
            id: id,
            name: name,
            timestamp: timestamp,
            attributes: attributes
        )
    }
}
