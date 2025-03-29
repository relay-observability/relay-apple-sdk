//
//  RelayPlugin.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//

import Foundation

/// A plugin is responsible for capturing events from a specific domain (e.g., Core Data, UI, etc.).
public protocol RelayPlugin {
    func start()
}
