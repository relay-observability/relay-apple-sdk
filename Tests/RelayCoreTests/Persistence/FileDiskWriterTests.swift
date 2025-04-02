//
//  FileDiskWriterTests.swift
//  RelayCoreTests
//
//  Created on March 30, 2025 as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//

import XCTest
import RelayCommon
@testable import RelayCore
@testable import RelayMocks

final class FileDiskWriterTests: XCTestCase {
    
    private var mockFileSystem: MockFileSystem!
    private var mockSerializer: MockEventSerializer!
    private var mockRetryCoordinator: MockRetryCoordinator!
    private var mockCleanupManager: MockCleanupManager!
    private var mockMetricsEmitter: MockMetricsEmitter!
    private var mockCriticalErrorHandler: MockCriticalErrorHandler!

    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()

        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        mockFileSystem = MockFileSystem()
        mockSerializer = MockEventSerializer()
        mockRetryCoordinator = MockRetryCoordinator()
        mockCleanupManager = MockCleanupManager()
        mockMetricsEmitter = MockMetricsEmitter()
        mockCriticalErrorHandler = MockCriticalErrorHandler()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        
        super.tearDown()
    }

    func makeWriter(configure: ((inout FileDiskWriterConfiguration) -> Void)? = nil) -> FileDiskWriter {
        var config = FileDiskWriterConfiguration(metricsEmitter: mockMetricsEmitter)
        
        configure?(&config)

        return FileDiskWriter(
            directory: tempDirectory,
            serializer: mockSerializer,
            retryPolicy: .none,
            retryCoordinator: mockRetryCoordinator,
            scheduler: NoopScheduler(),
            fileSystem: mockFileSystem,
            config: config,
            cleanupManager: mockCleanupManager,
            persistentStorage: nil,
            criticalErrorHandler: mockCriticalErrorHandler
        )
    }

    func testSuccessfulWriteEmitsMetricAndUpdatesFile() async {
        let writer = makeWriter()
        let events = [RelayEvent.mock(), RelayEvent.mock()]

        await writer.write(events)

        let enqueueCallCount = await mockRetryCoordinator.enqueueCallCount
        let performCleanupCallCount = await mockCleanupManager.performCleanupCallCount
        
        XCTAssertEqual(mockSerializer.encodeCallCount, 1)
        XCTAssertEqual(enqueueCallCount, 1)
        XCTAssertEqual(performCleanupCallCount, 1)
        XCTAssertEqual(mockMetricsEmitter.metrics["file.write.success"], 2)
    }

    func testWriteFailsSerializationEmitsFailureMetric() async {
        mockSerializer.shouldThrow = true
        let writer = makeWriter()

        await writer.write([RelayEvent.mock()])

        XCTAssertEqual(mockMetricsEmitter.metrics["file.write.failure"], 1)
    }

    func testRotationOccursWhenThresholdExceeded() async {
        let writer = makeWriter {
            $0.maxFileSize = 1 // Force immediate rotation
        }
        await writer.write([RelayEvent.mock()])
        await writer.write([RelayEvent.mock()])

        XCTAssertEqual(mockMetricsEmitter.metrics["file.rotation"], 1)
    }

    func testWriteFailsWithNoCurrentFileEmitsFailure() async {
        let writer = makeWriter()
        mockFileSystem.shouldFailCreate = true

        await writer.write([RelayEvent.mock()])

        XCTAssertEqual(mockMetricsEmitter.metrics["file.write.failure"], 1)
    }
}
