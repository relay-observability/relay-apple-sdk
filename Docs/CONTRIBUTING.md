# Contributing to Relay

Thank you for your interest in improving Relay!  
We're building a composable, vendor-neutral observability SDK for iOS — and we’d love your help.

## 🧠 Philosophy

Relay is designed to:
- Automatically capture performance and behavioral signals
- Enhance existing SDKs (not replace them)
- Be clean, composable, and developer-friendly

## 🛠 How to Contribute

### 1. Fork the Repository

```bash
git clone https://github.com/YOUR_USERNAME/relay.git
cd relay
```

### 2. Create a Feature Branch

```bash
git checkout -b your-feature-name
```

### 3. Bootstrap Your Environment

To install required tools and configure Git hooks:

```bash
./bootstrap.sh
```

This will:
- Set up shared pre-commit hooks
- Install SwiftLint and SwiftFormat if missing
- Ensure you're ready to lint, format, and test code

### 4. Use Makefile Commands

Relay includes a Makefile with useful development commands:

| Command            | Description                                |
|--------------------|--------------------------------------------|
| `make build`       | Builds the project (defaults to iOS)       |
| `make build-ios`   | Builds for iOS (alias)                     |
| `make build-macos` | Builds for macOS (alias)                   |
| `make test`        | Runs all unit tests with `swift test`      |
| `make lint`        | Runs SwiftLint with strict rules           |
| `make format`      | Lints formatting using SwiftFormat         |
| `make bootstrap`   | Same as `./bootstrap.sh` for convenience   |

#### ✅ Pre-Commit Linting (Optional Manual Setup)

If needed, you can configure pre-commit hooks manually:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

### 5. Commit and Push

```bash
git commit -m "Add: Short summary of your change"
git push origin your-feature-name
```

### 6. Open a Pull Request

Please link to any related issues and include:
- What this change does
- Why it’s needed
- Any relevant screenshots or tests

## 🔍 Where to Contribute

- `RelayCore`: Core models and config
- `RelayGRDB`: GRDB performance tracing
- `RelayCoreData`: Core Data save/fetch profiling
- `RelaySwiftData`: SwiftData ModelContext instrumentation
- `RelayUI`: UI latency detection
- `RelayExporters`: Console, OTel, and custom exporters
- `RelayPlayground`: Tools to simulate signal emission for testing

## 🧪 Testing

Each module should have its own test target under `/Tests`.  
Use `XCTest`, and if mocking is required, prefer protocol-based injection.

## 💬 Questions or Ideas?

Open an [issue](https://github.com/calube/relay/issues) or start a [discussion](https://github.com/calube/relay/discussions) — we're always open to good ideas.

## 🧾 License

Relay is [MIT licensed](../LICENSE.md).  
By contributing, you agree to license your contributions under the same.

Thanks for being part of this project — let’s build something amazing.
