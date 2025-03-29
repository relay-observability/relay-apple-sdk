# 🗺️ Relay SDK – Project Roadmap

Relay is a composable, vendor-neutral observability SDK for iOS. This roadmap outlines the major milestones and features planned to make Relay fast, extensible, and production-ready.

---

## ✅ Milestone 1: Core Infrastructure

> Foundation for Relay's plugin-based observability system.

- `RelayCore` with:
  - `RelayEvent`, `RelayPlugin`, `RelayExporter`
  - `RelayEventBuffer` (ring buffer-based)
  - `RelayFlushController`
- Simple `RelayDiskWriter` (static, no retry)
- Initial `Relay.configure { }` entry point
- Basic `ConsoleExporter`
- Git hooks, Makefile, CI, and contributor setup

---

## 🔄 Milestone 2: Pluggable Disk Persistence

> A robust, testable persistence system that supports retries, serialization, and batching.

- `EventPersisting` protocol
- `FileDiskWriter` with:
  - RetryPolicy
  - JSON serialization
  - Pluggable disk path
  - File batching and write strategy
- Flush-on-background and graceful shutdown
- Unit tests and simulated I/O failures
- Performance benchmarking: write throughput, latency

---

## 🎯 Milestone 3: UI Latency Plugin

> Add zero-config profiling for slow taps and UI latency.

- `RelayUIPlugin`
- Gesture instrumentation (e.g. tap-to-draw latency)
- Tap duration thresholds and slow tap classification
- Optional screen context enrichment
- Exporter integration (console/log for now)

---

## 🧩 Milestone 4: Database Instrumentation Plugins

> Profile real-world app data layers with minimal effort.

- `RelayCoreDataPlugin`
- `RelaySwiftDataPlugin`
- `RelayGRDBPlugin`
- Emit span events for save/fetch operations
- Auto-injection hooks (e.g. `NSManagedObjectContext`)
- Schema, table, fetch size, and latency metadata
- Performance tests on real-world workloads

---

## 🌐 Milestone 5: Network Instrumentation

> Add automatic profiling of URLSession requests.

- `RelayNetworkPlugin`
- URLSession swizzling / interception
- Track latency, headers, status code, response size
- Optional network reachability metadata
- Handle retry/multicast/delegate edge cases
- Export compatibility with OpenTelemetry span models

---

## 🛡 Milestone 6: Advanced Features & Resilience

> Improve reliability, customization, and exporter flexibility.

- Smart sampling agent (adaptive, remote-configurable)
- Exporter multiplexing (e.g. Console + OTel + Sentry)
- Flush on crash or termination
- Exporter batching and failover
- Disk usage limits and cleanup policies
- Memory pressure auto-flush fallback

---

## 🚀 Milestone 7: Public Beta Release

> Publish a fully functional, OSS-ready SDK for teams to use in production.

- Modular Swift Package structure
- Complete public API documentation
- Exporters: Console + OTel (MVP)
- Playground/test harness for simulating signal emission
- Full README, CODEOWNERS, LICENSE, CONTRIBUTING, ROADMAP
- Linear project board with epics + milestones
- GitHub Discussions + Issues templates
