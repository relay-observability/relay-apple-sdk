//
//  Scheduler.swift
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

/// The default scheduler using Swift concurrency's Task.detached.
public struct DefaultScheduler: Scheduler {
    public func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        try await Task.detached(priority: .background) {
            try await operation()
        }.value
    }
}
