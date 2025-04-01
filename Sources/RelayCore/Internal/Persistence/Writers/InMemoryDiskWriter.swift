//
//  InMemoryDiskWriter.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation
import RelayCommon

/// A testable, non-persistent writer that just stores events in memory.
public final class InMemoryDiskWriter: EventPersisting {
    public private(set) var events: [RelayEvent] = []

    public init() {}

    public func write(_ events: [RelayEvent]) {
        self.events.append(contentsOf: events)
    }

    public func clear() {
        events.removeAll()
    }
}
