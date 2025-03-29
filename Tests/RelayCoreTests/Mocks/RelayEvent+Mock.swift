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
