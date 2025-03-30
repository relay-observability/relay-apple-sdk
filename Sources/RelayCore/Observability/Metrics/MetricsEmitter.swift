/// A protocol for emitting SDK metrics. Implementers can forward metrics to a monitoring backend.
public protocol MetricsEmitter: Sendable {
    /// Emits a metric with a name, value, and optional tags.
    func emitMetric(name: String, value: Double, tags: [String: TelemetryAttribute]?)
}
