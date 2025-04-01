@testable import RelayCore

public final actor MockRetryCoordinator: RetryCoordinator {
    private(set) var enqueueCallCount = 0
    private(set) var retryLoopCallCount = 0

    public func enqueue(_ write: PendingWrite) {
        enqueueCallCount += 1
    }
    
    public func retryLoop() {
        retryLoopCallCount += 1
    }
}
