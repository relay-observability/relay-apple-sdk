# Relay

**Relay** is a modular, vendor-neutral observability SDK for iOS apps.  
It automatically instruments performance and behavioral signals — and routes them wherever you already observe your app.

## ✨ Why Relay?

Most apps already use multiple SDKs for analytics, performance, crash reporting, and logs.  
**Relay doesn’t compete — it enhances.**

- 📦 **Modular** — Use only the plugins you need (GRDB, Core Data, SwiftData, SwiftUI, etc.)
- 🎯 **Automatic** — No manual spans or logs needed
- 🔌 **Pluggable Exporters** — OpenTelemetry, Datadog, console, custom analytics — your choice
- 🧠 **Smart Sampling** — Built-in noise reduction and tunable signal control
- 🚦 **Kill Switch Support** — Runtime toggle for any plugin
- 🧰 **Developer Playground** — Simulate observability signals in dev without shipping


## 🧱 Architecture

```
[Plugin]
  → [SamplingPolicy]
  → [NoiseReducer]
  → [Exporter]
```

Each Relay plugin captures observability signals for a specific domain and sends them through your configured pipeline.

## 🔌 Example Usage

```swift
import RelayCore
import RelayGRDB
import RelayOTelExporter

Relay.configure {
  $0.setExporter(OpenTelemetryAdapter())
  $0.setSampler(PercentSampler(rate: 0.1))
  $0.setKillSwitch(RemoteKillSwitch())
}

Relay.register(plugin: GRDBProfilerPlugin())
```

## 📦 Modules

- **RelayCore** – Shared event models, configuration, and exporter protocols
- **RelayGRDB** – Profiles GRDB query performance using `.profile` trace hooks
- **RelayCoreData** – Tracks Core Data save and fetch performance
- **RelaySwiftData** – Instruments `ModelContext` save/fetch operations
- **RelayUI** – Detects slow interactions and UI thread latency
- **RelayErrorReporter** – Captures contextual error metadata
- **RelaySampling** – Smart signal filtering and sampling policies
- **RelayExporters**
  - `Console` – Logs locally
  - `OpenTelemetry` – Forwards spans to OTel
- **RelayPlayground** – In-app observability simulator for dev/test environments

## 🛠 Installation

**Swift Package Manager**

```swift
.package(url: "https://github.com/calube/relay.git", from: "0.1.0")
```

## 🔭 Roadmap

- [x] Modular architecture with core event model
- [ ] Plugins for GRDB, Core Data, SwiftData
- [ ] Smart sampling & kill switch support
- [ ] OTel + console exporters
- [ ] SwiftUI instrumentation layer
- [ ] Error reporter and dependency tracker
- [ ] Relay Playground module
- [ ] OSS Launch 🚀

## 🤝 Contributing

We love contributions!  
Start by checking out [`Docs/DESIGN.md`](./Docs/DESIGN.md) and opening an issue or discussion.

## 🧪 License

MIT — open and extensible. Build something better with us.

## 🛰 Built for:
- Engineers who care about performance and clarity
- Teams already using other SDKs and just need better signal
- Products that can't afford observability noise

Relay isn’t the final word in observability — it’s the cleanest way to send your signal.
