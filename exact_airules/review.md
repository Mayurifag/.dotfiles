# Reviews and Audits

When the user says “review” (or equivalent), use these defaults for scope, edits, and reporting. An explicit read-only
request overrides the edit default.

- Determine scope first:
  - Unstaged/staged changes or commits ahead of base (not in main/master) -> review the diff and related callers,
    callees, tests, and config.
  - Clean tree, no commits ahead of base -> review the relevant codebase: entry points, high-risk flows,
    packages/modules.
- Read every line in scope. For each affected flow, sketch the simplest implementation that meets current requirements.
  Delete before polishing: look for dead paths, pass-through wrappers, duplicate state or validation, speculative
  options, obsolete fallbacks, and tests that duplicate protection or only pin removed internals. Prefer removing a
  whole layer to shortening its implementation. Include directly coupled pre-existing code when the same simplification
  needs it. Check language features, the standard library, and existing tools before adding code or dependencies.
  Preserve supported behavior, security, accessibility, and compatibility. Ask before changing public contracts or
  widening scope.
- Within the affected flow, change private interfaces and update all affected callers together when that removes more
  complexity. Do not keep an adapter or alias solely to minimize the diff. Verify that the interface has no supported
  external consumers before removing it.
- Recheck coding, design, and verification rules. Prioritize correctness, security, data loss, races, failure handling,
  and risky untested behavior. Challenge each finding against callers, guards, tests, and config. Require a realistic
  failure or concrete maintenance cost. Trace workarounds, duplicated state, and special cases to their root cause;
  distinguish necessary boundary handling from avoidable compensation. Before removing unused code, check callers,
  tests, config, fixtures, generated integrations, and dynamic references.
- A review request authorizes safe, in-scope fixes. Fix confirmed defects and rule violations, remove unnecessary
  complexity, and apply verified improvements. Fix the root cause instead of adding another workaround. Preserve
  unrelated work; ask before consequential changes that need approval or work outside the requested scope.
- Every review includes correctness, deletion-first cleanup, and performance passes. Trace affected paths for avoidable
  work such as repeated I/O, extra passes, needless allocations, and contention. Measure plausible, material bottlenecks
  on representative workloads per `performance.md`; fix those supported by evidence. After each round of edits, rerun
  relevant checks and repeat all three passes on the resulting diff and affected paths. Stop only when a full pass finds
  no further justified in-scope changes and checks pass, or when a blocker prevents further progress. A passing test run
  alone does not end the review. Report what you measured and any material gaps.
- After a nontrivial rewrite, identify the most plausible regression that existing checks would miss. Exercise it
  through the real entry point when practical. Keep a new test only if it protects distinct behavior.
- On the final pass, challenge the largest remaining layer or source of avoidable work in the affected flow. State what
  you tried to remove and the supported behavior, measurement, or scope boundary that made you keep it. If the best
  cleanup needs approval, say what would disappear and what would change for callers.
- Novelty claims -> check accessible prior findings and relevant public advisories; report search gaps.
- Security findings -> trace entry point, trust boundary, prerequisites, and impact. Use authorized, harmless
  reproductions and negative controls when practical; label unverified impact.
- Report after the last pass. Lead with what changed and what passed. Do not report a fixable in-scope finding instead
  of fixing it. For read-only reviews or blocked work, rank unresolved findings by severity and keep numbers stable in
  follow-ups. Give `path:line`, trigger, impact, evidence, and the smallest adequate fix. Name material coverage gaps or
  required decisions, recommend a default when practical, and skip cosmetic nits.

## Repository Audits

- Map entry points, dependencies, build/deploy config, and tests. Inspect complete high-risk flows (auth, untrusted
  input, money, writes, jobs, shared state). Name unread areas when full coverage is impractical.

## Debt Reports

- On request, find deferrals using repo conventions (`shortcut:`, legacy markers). Report location, limitation, revisit
  trigger. Never invent owners or thresholds.
