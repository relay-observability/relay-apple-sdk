import Foundation

/// A protocol that defines how to schedule asynchronous work.
public protocol Scheduler {
    func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T
}

/// The default scheduler using Swift concurrency's Task.detached.
public struct DefaultScheduler: Scheduler {
    public func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        try await Task.detached(priority: .background) {
            try await operation()
        }.value
    }
}

/// An alternative scheduler using DispatchQueue.
/// This is provided as an example; you can swap it in for testing or if needed.
public struct DispatchQueueScheduler: Scheduler {
    public func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                Task {
                    do {
                        let result = try await operation()
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
