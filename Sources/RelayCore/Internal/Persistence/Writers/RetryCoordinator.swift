import Foundation
import RelayCommon

// MARK: - Persistent Storage Protocol

/// Abstracts a persistent storage mechanism for crash recovery or transient offline conditions.
protocol PendingWriteStorage {
    func persist(_ write: PendingWrite)
}

// MARK: - Pending Write Structure

/// Represents a pending file write.
struct PendingWrite {
    let data: Data
    let url: URL
    var attempts: Int = 0
    let createdAt: Date = .init()
}

// MARK: - Retry Coordinator

final actor RetryCoordinator {
    // MARK: - Dependencies

    private let fileSystem: FileSystem
    private let scheduler: Scheduler
    private let metricsEmitter: MetricsEmitter
    private let maxAttempts: Int
    /// Base delay in seconds used for exponential backoff.
    private let baseDelay: TimeInterval
    private let persistentStorage: PendingWriteStorage?
    
    /// Delegate to notify higher layers of permanent failures.
    private var criticalErrorHandler: CriticalErrorHandler?
    
    // MARK: - Internal State
    
    private var queue: [PendingWrite] = []
    private var isRunning: Bool = false
    
    // MARK: - Initialization
    
    init(
        fileSystem: FileSystem,
        scheduler: Scheduler,
        metricsEmitter: MetricsEmitter,
        maxAttempts: Int = 5,
        baseDelay: TimeInterval = 0.5,
        persistentStorage: PendingWriteStorage? = nil,
        criticalErrorHandler: CriticalErrorHandler? = nil
    ) {
        self.fileSystem = fileSystem
        self.scheduler = scheduler
        self.metricsEmitter = metricsEmitter
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.persistentStorage = persistentStorage
        self.criticalErrorHandler = criticalErrorHandler
    }
    
    // MARK: - API
    
    func enqueue(_ write: PendingWrite) {
        queue.append(write)
        if !isRunning {
            retryLoop()
        }
    }
    
    func retryLoop() {
        guard !isRunning else { return }
        isRunning = true
        runRetryLoop()
    }
    
    private func runRetryLoop() {
        Task.detached { [weak self] in
            await self?.processQueue()
        }
    }
    
    private func processQueue() async {
        while let pending = dequeueNext() {
            await retry(pending)
        }
        markStopped()
    }
    
    private func dequeueNext() -> PendingWrite? {
        return queue.isEmpty ? nil : queue.removeFirst()
    }
    
    private func markStopped() {
        isRunning = false
    }
    
    // MARK: - Retry Logic
    
    private func retry(_ write: PendingWrite) async {
        var currentWrite = write  // Local mutable copy to update attempts.
        var delay = baseDelay
        
        while currentWrite.attempts < maxAttempts {
            do {
                try await scheduler.schedule {
                    try self.fileSystem.append(data: currentWrite.data, to: currentWrite.url)
                }
                
                // Emit success metric including maxAttempts for observability.
                metricsEmitter.emitMetric(
                    name: "file.write.retry_attempt",
                    value: 1,
                    tags: ["status": .string("success"), "max_attempts": .string("\(maxAttempts)")]
                )
                return
            } catch {
                currentWrite.attempts += 1
                metricsEmitter.emitMetric(
                    name: "file.write.retry_attempt",
                    value: 1,
                    tags: ["status": .string("failed"), "max_attempts": .string("\(maxAttempts)")]
                )
                
                // Error classification: if the error is persistent, exit immediately.
                if isPersistent(error: error) {
                    metricsEmitter.emitMetric(
                        name: "file.write.retry_exceeded",
                        value: 1,
                        tags: ["max_attempts": .string("\(maxAttempts)"), "reason": .string("persistent")]
                    )
                    criticalErrorHandler?.handleCriticalError(error)
                    persistFailedWrite(currentWrite)
                    return
                }
                
                // Check if max attempts have been reached.
                if currentWrite.attempts >= maxAttempts {
                    metricsEmitter.emitMetric(
                        name: "file.write.retry_exceeded",
                        value: 1,
                        tags: ["max_attempts": .string("\(maxAttempts)")]
                    )
                    criticalErrorHandler?.handleCriticalError(error)
                    persistFailedWrite(currentWrite)
                    return
                }
                
                // Exponential backoff with jitter.
                // TODO: Consider making the jitter factor configurable.
                let jitter = Double.random(in: 0...(delay * 0.2))
                let sleepTime = UInt64((delay + jitter) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: sleepTime)
                delay *= 2
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Determines if an error is persistent (non-recoverable) or transient.
    private func isPersistent(error: Error) -> Bool {
        // TODO: Implement actual error classification logic (e.g. checking for disk full or permission denied errors).
        // For demonstration purposes, we'll treat all errors as transient.
        return false
    }
    
    /// Persists a failed write for crash recovery or handling transient offline conditions.
    private func persistFailedWrite(_ write: PendingWrite) {
        persistentStorage?.persist(write)
        // TODO: Add additional handling if persistence fails.
    }
}
