import Foundation

/// A protocol that defines how to schedule asynchronous work.
public protocol Scheduler {
    func schedule<T>(_ operation: @escaping () async throws -> T) async throws -> T
}
