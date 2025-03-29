# Relay Design Document

**Relay** is a modular, composable, vendor-neutral observability SDK for iOS.  
It’s built to enhance — not replace — existing performance, analytics, and tracing tools.

## 🎯 Goals

- **Automatic Performance Profiling**: For Core Data, SwiftData, GRDB, and UI interactions.
- **Composable Architecture**: Each module handles a specific concern (DB, UI, errors, sampling).
- **Exporter-First Design**: Route signals to OpenTelemetry, Datadog, analytics SDKs, or custom systems.
- **Low Noise**: Tunable sampling and filtering built-in.
- **Runtime Configurable**: Kill switches and signal routing can be toggled remotely.

## 🔧 Architecture Overview

```
[Plugin]
  → [SamplingPolicy]
  → [NoiseReducer]
  → [Exporter]
```

### Components

- **Plugin**: Captures signals (e.g., DB profiling, error context, tap latency)
- **SamplingPolicy**: Determines if a signal should be recorded
- **NoiseReducer**: Filters or deduplicates noisy signals
- **Exporter**: Forwards data to other SDKs or logging systems

## 🧱 Modules

### Core

- `RelayCore`: Shared event models, plugin registration, and global config

### Profilers

- `RelayGRDB`: Instruments GRDB queries using `Configuration.trace`
- `RelayCoreData`: Swizzles `NSManagedObjectContext` to profile saves/fetches
- `RelaySwiftData`: Profiles `ModelContext` operations
- `RelayUI`: Tracks slow UI interactions and user gesture latency
- `RelayErrorReporter`: Captures enriched error metadata
- `RelaySampling`: Built-in sampling policies (percent, conditional, dynamic)

### Exporters

- `RelayConsoleExporter`: Logs events locally for debug builds
- `RelayOTelExporter`: Converts events into OpenTelemetry spans
- Future: `RelayDatadogExporter`, `RelayAnalyticsAdapter`, etc.

### Dev Tooling

- `RelayPlayground`: Developer-only module to simulate observability signals for testing dashboards, CI, and integrations

## 🔌 Exporter System

Relay emits its own internal events (e.g., `DBProfileEvent`, `InteractionEvent`, `ContextualError`).  
Apps configure one or more exporters:

```swift
Relay.configure {
  $0.setExporter(
    MultiExporter([
      OpenTelemetryAdapter(),
      ConsoleExporter(),
      ClosureExporter { event in
        Analytics.logEvent("db_profile", parameters: event.toAnalyticsParams())
      }
    ])
  )
}
```

## 🧠 Smart Sampling + Kill Switch

Relay includes:

- **SamplingPolicy** (e.g., 10%, slow-only, feature-flagged)
- **KillSwitchProvider** for runtime plugin disabling (e.g., Firebase Remote Config)

```swift
Relay.configure {
  $0.setKillSwitch(FirebaseKillSwitch())
  $0.setSampler(PercentSampler(rate: 0.05))
}
```

## 🛣 Roadmap (Phases)

| Phase | Deliverables |
|-------|--------------|
| 1     | CoreData + SwiftData + GRDB profiling |
| 2     | Exporters + sampling + kill switches |
| 3     | Slow interaction + error context |
| 4     | SwiftUI instrumentation + Relay Playground |
| 5     | Mobile SDK dependency tracking |
| 6     | OSS launch & docs |

## 🔭 Future Direction

- Bridge signals to analytics/crash SDKs
- Plugin system for 3rd-party contributors
- Web dashboard reference app (self-hosted)

Relay gives developers a clean signal — then gets out of the way.
