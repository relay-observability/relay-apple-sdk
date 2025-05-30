//
//  LifecycleObserver.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

public protocol LifecycleObserver {
    func observeWillResignActive(_ handler: @escaping () -> Void)
}
