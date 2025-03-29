import Foundation

public enum RetryPolicy {
    case none
    case exponentialBackoff(retries: Int, initialDelay: TimeInterval)
    case custom((_ error: Error) -> Bool)
}
