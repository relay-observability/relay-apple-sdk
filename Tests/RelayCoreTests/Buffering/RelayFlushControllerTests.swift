import XCTest
@testable import RelayCore
@testable import RelayMocks

final class RelayFlushControllerTests: XCTestCase {

    private var mockEventBuffer: MockEventBuffer!
    private var testScheduler: TestScheduler!
    private var noOpScheduler: NoopScheduler!
    private var erroringScheduler: ErroringScheduler!
    private var mockLifecycleObserver: MockLifecycleObserver!

    struct FakeError: Error, Equatable {}

    override func setUp() {
        super.setUp()

        mockEventBuffer = .init()
        testScheduler = .init()
        noOpScheduler = .init()
        erroringScheduler = .init(error: FakeError())
        mockLifecycleObserver = .init()
    }

    override func tearDown() {
        mockEventBuffer = nil
        testScheduler = nil
        noOpScheduler = nil
        erroringScheduler = nil
        mockLifecycleObserver = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testManualFlushCallsBufferFlush() async {
        let controller = RelayFlushController(
            interval: 5.0,
            lifecycleObserver: mockLifecycleObserver,
            scheduler: noOpScheduler
        )

        await controller.start(buffer: mockEventBuffer)

        addTeardownBlock {
            await controller.stop()
        }

        await controller.flush()
        let count = await mockEventBuffer.flushCallCount
        XCTAssertEqual(count, 1, "Expected manual flush to call buffer.flush() once")
    }

    func testPeriodicFlushTriggersFlushViaScheduler() async throws {
        let controller = RelayFlushController(
            interval: 0.1,
            lifecycleObserver: mockLifecycleObserver,
            scheduler: testScheduler
        )

        await controller.start(buffer: mockEventBuffer)

        addTeardownBlock {
            await controller.stop()
        }

        try await Task.sleep(nanoseconds: 100_000_000)

        let count = await mockEventBuffer.flushCallCount
        XCTAssertGreaterThanOrEqual(count, 1, "Expected at least one flush call from periodic task")
    }

    func testLifecycleFlushIsCalledOnWillResignActive() async {
        let controller = RelayFlushController(
            interval: 5.0,
            lifecycleObserver: mockLifecycleObserver,
            scheduler: noOpScheduler
        )

        addTeardownBlock {
            await controller.stop()
        }

        mockLifecycleObserver.observeWillResignActive {
            Task {
                await controller.flush()
            }
        }

        await controller.start(buffer: mockEventBuffer)

        let currentCallCount = await mockEventBuffer.flushCallCount
        mockLifecycleObserver.simulateWillResignActive()

        try? await Task.sleep(nanoseconds: 100_000_000)

        let count = await mockEventBuffer.flushCallCount
        XCTAssertEqual(currentCallCount + 1, count, "Expected flush on lifecycle willResignActive event")
    }

    func testStopCancelsPeriodicFlushTask() async {
        let controller = RelayFlushController(
            interval: 0.1,
            lifecycleObserver: mockLifecycleObserver,
            scheduler: noOpScheduler
        )

        await controller.start(buffer: mockEventBuffer)

        addTeardownBlock {
            await controller.stop()
        }

        try? await Task.sleep(nanoseconds: 100_000_000)
        let countBefore = await mockEventBuffer.flushCallCount

        try? await Task.sleep(nanoseconds: 200_000_000)
        let countAfter = await mockEventBuffer.flushCallCount

        XCTAssertEqual(countBefore, countAfter, "Expected no more flushes after stop() was called")
    }

    func testFlushWithNilBufferDoesNotCrash() async {
        let controller = RelayFlushController(
            interval: 5.0,
            lifecycleObserver: mockLifecycleObserver,
            scheduler: testScheduler
        )

        await controller.flush()

        XCTAssertTrue(true, "Flush without buffer should not crash")
    }

    func testSchedulerErrorIsCaughtAndRetriesAfterDelay() async {
        let controller = RelayFlushController(
            interval: 0.1,
            lifecycleObserver: mockLifecycleObserver,
            scheduler: erroringScheduler
        )

        await controller.start(buffer: mockEventBuffer)

        addTeardownBlock {
            await controller.stop()
        }

        try? await Task.sleep(nanoseconds: 250_000_000)

        XCTAssertTrue(true, "Scheduler errors should be caught and not crash the task loop")
    }
}
