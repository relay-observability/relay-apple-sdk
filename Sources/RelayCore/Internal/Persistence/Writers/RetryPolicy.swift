//
//  RetryPolicy.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

public enum RetryPolicy {
    case none
    case exponentialBackoff(retries: Int, initialDelay: TimeInterval)
    case custom((_ error: Error) -> Bool)
}
