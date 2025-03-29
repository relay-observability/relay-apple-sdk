✅ Disk Writer Project Task Breakdown (Linear-style)

🔹 Phase 1 – Prototype (Current)

	•	✅ Use enum-based RelayDiskWriter with static write(_:) method
	•	Add print logging for flush confirmation
	•	Wire into RelayEventBuffer.flush() as temporary disk writer

🔹 Phase 2 – Protocol + Concrete Writer

	•	🔧 Create EventPersisting protocol with write(_:) method
	•	🔧 Create FileDiskWriter class implementing EventPersisting
	•	🔧 Add support for configurable disk path (via initializer)
	•	🔧 Wire RelayEventBuffer to accept injected EventPersisting instance
	•	✅ Write unit tests for FileDiskWriter basic write functionality
	•	🧪 Write unit tests for file creation, write contents, directory checks

🔹 Phase 3 – Retry & Error Handling

	•	🔧 Define RetryPolicy enum with .none, .exponentialBackoff, .custom
	•	🔧 Implement retry logic in FileDiskWriter
	•	✅ Add retry backoff with max retry attempts
	•	✅ Write unit tests for retry edge cases and error propagation
	•	🧪 Simulate file I/O failure and verify retry is triggered

🔹 Phase 4 – Pluggable Serialization

	•	🔧 Define EventSerializer protocol with encode(_:) throws -> Data
	•	🔧 Create JSONEventSerializer as the default implementation
	•	🔧 Allow injection of serializer into FileDiskWriter
	•	✅ Unit test JSON output matches expected schema
	•	🧪 Add snapshot testing for encoded event payloads

🔹 Phase 5 – File Rotation & Export Pipeline

	•	🔧 Add logic to write event batches to timestamped files
	•	🔧 Implement disk file rotation by:
	•	File size
	•	Age (time-based)
	•	Max file count
	•	🔧 Add export readiness flag to file metadata
	•	🔧 Create stub DiskExportQueue to coordinate file uploads
	•	✅ Unit test file rotation and batch handling
	•	🧪 Verify rotation triggers at thresholds

🔹 Phase 6 – Performance & Durability

	•	🧪 Profile write performance for 1K, 5K, 10K events
	•	🧪 Benchmark serialization throughput per format
	•	🧪 Test memory impact during rapid add() + flush() cycles
	•	✅ Implement flush-on-background hook
	•	✅ Add crash-safe flush option (write in-progress file to disk atomically)

🔹 Phase 7 – Mocks & Testing Infra

	•	🔧 Create MockDiskWriter for use in unit tests
	•	🔧 Create InMemoryDiskWriter for test environments
	•	✅ Add integration test: RelayEventBuffer → DiskWriter → ExportQueue
	•	✅ Validate disk cleanup policies work as expected

🧭 Optional Later

	•	Add DiskWriterMetricsCollector for exported bytes, file count, flush time
	•	Add encryption support via EncryptedSerializer
	•	Add compression support (gzip, zstd)