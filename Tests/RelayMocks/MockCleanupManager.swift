@testable import RelayCore

public final actor MockCleanupManager: CleanupManager {
    public private(set) var performCleanupCallCount = 0
    
    public func performCleanup() async {
        performCleanupCallCount += 1
    }
}
