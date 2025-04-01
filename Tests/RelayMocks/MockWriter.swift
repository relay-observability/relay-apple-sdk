//
//  MockWriter.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation
import RelayCommon
@testable import RelayCore

public final class MockWriter: EventPersisting {
    private let delay: TimeInterval
    var captured: [[RelayEvent]] = []

    public init(delay: TimeInterval = 0.0) {
        self.delay = delay
    }

    public func write(_ events: [RelayEvent]) async {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        captured.append(events)
    }
}
