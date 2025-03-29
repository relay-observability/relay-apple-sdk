//
//  RelayExporter.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

/// A type that handles exporting events to a backend or logging system.
public protocol RelayExporter {
    func export(_ event: RelayEvent)
}
