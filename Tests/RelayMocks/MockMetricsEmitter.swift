import RelayCommon
import RelayCore

final class MockMetricsEmitter: MetricsEmitter {
    private(set) var metrics: [String: Double] = [:]

    func emitMetric(name: String, value: Double, tags: [String: TelemetryAttribute]?) {
        metrics[name, default: 0] += value
    }
}
