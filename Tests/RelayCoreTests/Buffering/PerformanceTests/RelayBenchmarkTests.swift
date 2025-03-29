import XCTest

/// This file is commented out to avoid long CI times.
/// You can run `testBufferUnderPressure` to view the bechmark results in PERFORMANCE.md
final class RelayBenchmarkTests: XCTestCase {
    /// Relay Buffer Pressure Test Results (Example)
    ///
    /// Total Events Added: 20,911
    /// Total Events Dropped: 0
    /// Avg Enqueue Latency: 0.003 ms
    /// Total Flushes: 1
    /// Avg Flush Latency: 0.173 ms
    ///
    /// ### Interpretation:
    /// - **High Throughput**: The buffer successfully handled ~2,000+ events per second with zero data loss.
    /// - **No Drops**: Indicates the buffer capacity and flush interval are well-tuned for the simulated workload.
    /// - **Low Latency**:
    ///   - Enqueue latency averaged ~3 microseconds, suggesting minimal contention and efficient synchronization.
    ///   - Flush latency was under 1 ms, showing fast serialization and export handling.
    /// - **Flush Frequency**: Only one flush occurred, likely due to the test duration and flush interval settings.
    ///
    /// ### Summary:
    /// These results confirm the buffer is performant, drop-free under the test conditions, and ready for more advanced behaviors
    /// like noise reduction, event prioritization, and adaptive sampling.
    func testBufferUnderPressure() async throws {
        guard ProcessInfo.processInfo.environment["ENABLE_RELAY_BENCHMARKS"] == "1" else {
            throw XCTSkip("Benchmark test skipped by default. Set ENABLE_RELAY_BENCHMARKS=1 to enable.")
        }

        let tracker = MetricsTracker()

        // Customize profile as needed
        let profile = StressProfile(
            name: "Manual Benchmark",
            concurrency: 4,
            eventRate: 1000,
            duration: 1.0,
            bufferSize: 500,
            flushInterval: 5.0,
            exporterDelay: 0.0
        )

        for i in 1...1000 {
            let tester = RelayBufferPressureTester(
                concurrency: profile.concurrency,
                eventRate: profile.eventRate,
                duration: profile.duration,
                bufferSize: profile.bufferSize,
                flushInterval: profile.flushInterval,
                exporterDelay: profile.exporterDelay,
                tracker: tracker
            )

            await tester.runTest()

            if i % 100 == 0 {
                print("Finished run \(i)/1000")
            }
        }

        await tracker.report(totalRuns: 1_000)
    }

}
