# Ring Buffer Benchmarks

## 💾 Benchmark Summary

### 📋 **Overall Stats**

| Metric                  | Value       | Notes |
|-------------------------|-------------|-------|
| **Total Runs**          | 1000        | Great coverage — excellent for spotting outliers or rare regressions. |
| **Events Added**        | 2,083,156   | ~2,083 events per run (avg), aligns with 1s @ ~2k/sec throughput. |
| **Events Dropped**      | 0           | 👏 Perfect. The buffer handled all events without overflow or backpressure. |
| **Total Flushes**       | 996         | Slightly under 1 per run — expected since flush interval is 5s but test runs are 1s. |

### ⏱️ **Enqueue Latency**

| Statistic | Latency (ms) | Interpretation |
|-----------|--------------|----------------|
| **Avg**   | 0.004        | ⚡️ Lightning-fast (~4µs), negligible performance impact. |
| **Min**   | 0.000        | As expected for some uncontested operations. |
| **Max**   | 0.340        | Rare spike, possibly during flush or GC. Still under 1 frame (~16ms). |
| **p95**   | 0.011        | 95% of events enqueue in under 11µs. |
| **p99**   | 0.018        | 99% enqueue in under 18µs. Great tail latency. |

> 🧠 **Takeaway**: Enqueue path is extremely performant and suitable for high-frequency data (e.g., UI taps, Core Data saves).

### 🚿 **Flush Latency**

| Statistic | Latency (ms) | Interpretation |
|-----------|--------------|----------------|
| **Avg**   | 0.051        | Sub-millisecond serialization/export time. |
| **Min**   | 0.014        | Best-case flush performance. |
| **Max**   | 0.120        | Still low — shows stable serialization even under load. |
| **p95**   | 0.062        | 95% of flushes complete in <1 frame (16ms). |
| **p99**   | 0.077        | Barely any tail — smooth and consistent. |

> 🧠 **Takeaway**: Flushes are efficient and don't bottleneck telemetry pipelines.

---

## 💡 Architectural Validation

- ✅ **Ring buffer performs extremely well under concurrent pressure.**
- ✅ **No dropped events** indicates the flush interval and buffer size are appropriately tuned.
- ✅ **Actor-based metrics tracking** introduces negligible overhead.
- ✅ **System has headroom** for future features: noise reduction, compression, priority tagging.

---

## 🚀 Next Steps & Ideas

1. **Lower buffer size + rerun** — observe drop behavior and evaluate backpressure responses.
2. **Simulate slow writers** — add artificial delay to test serialization/exporter impact.
3. **Long-duration runs** (e.g. 10+ minutes) — validate GC pressure, memory growth, retention.
4. **CI Regression Baseline** — track and fail on p99 latency regressions.

---

# Relay Stress Test Profile Matrix

A stress test profile matrix defines a range of load scenarios to validate buffer performance in:

- 🧵 **Concurrency scaling**
- 📈 **Event throughput**
- ⏱️ **Test duration**
- 🧠 **Memory constraints (buffer size)**
- ❄️ **Exporter behavior under delay**
- ⛈ **Real-world and extreme traffic patterns**

These profiles can be used internally or provided to integrators to evaluate buffer behavior in their own environment.

| Profile         | Concurrency | Event Rate (events/sec) | Duration (s) | Buffer Size | Flush Interval | Exporter Delay | Notes |
|-----------------|-------------|--------------------------|--------------|-------------|----------------|----------------|-------|
| 🔮 **Baseline**       | 4           | 1000                     | 1            | 500         | 5s             | 0ms            | Fast smoke test |
| 📱 **Typical App**    | 4           | 2000                     | 10           | 1000        | 5s             | 0ms            | Simulates average mobile usage |
| 🚀 **High Load**      | 8           | 4000                     | 10           | 750         | 3s             | 0ms            | Tests concurrency and flush stress |
| ⚠️ **Flush Delay**     | 4           | 2000                     | 10           | 500         | 5s             | 25ms           | Simulates slow exporter/serialization |
| 💣 **Stress Test**     | 16          | 10000                    | 30           | 1000        | 5s             | 10ms           | Max concurrency + throughput scenario |
| 🌀 **Burst Traffic**   | 4           | Spikes to 10,000         | 5            | 500         | 5s             | 0ms            | UI tap storms, search spam, etc. |
| 🔥 **Tiny Buffer**     | 4           | 1000                     | 5            | 50          | 5s             | 0ms            | Forces drop behavior intentionally |
| 🧼 **Compression**     | 4           | 1000                     | 5            | 500         | 5s             | 0ms            | Run with compression enabled |
| 🔮 **CI Mode**        | 2           | 500                      | 0.25         | 250         | 5s             | 0ms            | Fast guard for performance regressions |

---

> 🎓 **Pro Tip**: You can integrate this matrix into CI, collect metrics, and define guardrails like:
> “Fail if `p99 enqueue latency > 0.5ms` or drop rate > 1%”.

Need a script, config loader, or CLI interface to run this matrix? Open an issue or check the `StressProfile.swift` helper.