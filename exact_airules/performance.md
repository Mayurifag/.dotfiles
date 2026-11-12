# Performance

- When investigating, advising on, or improving performance, reproduce a representative workload and establish a
  baseline when practical. Record the workload, environment, metric, and sample count.
- Use a suitable profiler or trace on the actual workload whenever practical, even for recommendations. Start with
  available project/system tools and low-overhead sampling; use timings, metrics, and logs to complement profiles or
  narrow the bottleneck. Distinguish CPU, allocation/GC, I/O, locks/waits, network, rendering, and external services as
  relevant; for prompt flows, separate client, tool, network, and provider time where possible.
- Base recommendations on observed evidence, not code shape or guesses. Treat hot spots as leads until their impact on
  the target metric is verified. After changes, repeat the same workload when practical and report before/after results,
  noise, and remaining bottlenecks.
- Keep the measurement method and correctness criteria consistent; if they change, remeasure the baseline. Bound a
  multi-attempt optimization search by time or cost.
- If profiling is unavailable, check other suitable environments and, when appropriate, try an isolated temporary tool
  per `installation.md`. If still blocked, use the best available direct measurements and state what was attempted, the
  blocker, and any unverified hypotheses.
- Avoid capturing secrets, prompts, or personal data unless necessary and approved. Keep traces local, sanitize reports,
  and remove task-owned artifacts. Ask before potentially disruptive or high-impact profiling.
