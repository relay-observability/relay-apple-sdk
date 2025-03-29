//
//  FileDiskWriter.swift
//  RelayCore
//
//  Created on March 28, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import Foundation

public final class FileDiskWriter: EventPersisting {
    private let directory: URL
    private let serializer: EventSerializer
    private let retryPolicy: RetryPolicy

    public init(directory: URL, serializer: EventSerializer, retryPolicy: RetryPolicy = .none) {
        self.directory = directory
        self.serializer = serializer
        self.retryPolicy = retryPolicy
    }

    public func write(_ events: [RelayEvent]) {
        let filename = "events_\(Date().timeIntervalSince1970).json"
        let fileURL = directory.appendingPathComponent(filename)

        do {
            let data = try serializer.encode(events)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Failed to write events: \(error)")
            // TODO: Apply retry logic here using retryPolicy
        }
    }
}
