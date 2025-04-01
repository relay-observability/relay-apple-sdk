import RelayCommon

/// A scheduler for use in tests that immediately executes any scheduled operation without delay.
public struct TestScheduler: Scheduler {
    public init() {}

    public func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        return try await operation()
    }
}

/// A scheduler that always throws the provided error when asked to schedule an operation.
/// Useful for testing error handling in flush loops or retries.
public struct ErroringScheduler: Scheduler {
    private let error: Error

    public init(error: Error) {
        self.error = error
    }

    public func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        throw error
    }
}

/// A test scheduler that never executes scheduled operations.
/// Useful in unit tests where you want to disable periodic scheduling entirely.
public final class NoopScheduler: Scheduler {
    public init() {}

    public func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        throw CancellationError() // or your own no-op behavior
    }
}
