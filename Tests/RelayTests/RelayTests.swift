//
//  RelayTests.swift
//  RelayTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

@testable import Relay
import XCTest

final class RelayTests: XCTestCase {
    func test_validTest() {
        XCTAssertEqual(Relay.one.rawValue, 1)
    }
}
