//
//  UIKitLifecycleObserver.swift
//  RelayCore
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

#if canImport(UIKit)
    import UIKit

    public final class UIKitLifecycleObserver: LifecycleObserver {
        public init() {}

        public func observeWillResignActive(_ handler: @escaping () -> Void) {
            NotificationCenter.default.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: nil
            ) { _ in
                handler()
            }
        }
    }
#endif
