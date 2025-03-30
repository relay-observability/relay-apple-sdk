/// A no-op implementation, used if the integrator does not supply an emitter.
public struct NoOpMetricsEmitter: MetricsEmitter {
    public init() {}
    
    public func emitMetric(name: String, value: Double, tags: [String: TelemetryAttribute]?) { }
}
