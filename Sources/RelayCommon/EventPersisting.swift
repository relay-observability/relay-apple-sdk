//
//  EventPersisting.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// Protocol for writing Relay events to a persistent store (e.g. disk, memory, etc.).
public protocol EventPersisting {
    func write(_ events: [RelayEvent]) async
}
