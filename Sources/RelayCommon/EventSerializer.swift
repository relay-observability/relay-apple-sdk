//
//  EventSerializer.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

public protocol EventSerializer {
    func encode(_ events: [RelayEvent]) throws -> Data

    func decode(_ data: Data) throws -> [RelayEvent]
}
