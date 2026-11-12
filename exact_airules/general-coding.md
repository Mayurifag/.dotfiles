# General Coding

## Scope

- Read affected code before editing; trace callers, tests, fixtures, configuration, and exports.
- Before estimating migration effort or required user actions, check existing integration links, deployed configuration
  when accessible and authorized, and built-in migration features. Mark unverified claims as uncertain.
- Assess data loss, disclosure, and compatibility; ask before ambiguous broad changes.
- Resolve behavior-changing assumptions from requirements and existing code. If a consequential choice remains
  ambiguous, explain its impact and ask before implementing it.
- Turn explicit user constraints into a short checklist. Preserve required names, behavior, placement, file scope, and
  exclusions; verify each before finishing.
- For larger work, identify dependencies and, when practical, finish and verify end-to-end slices before starting the
  next. Record incidental findings without expanding scope.
- For concurrent work, give each task its own branch and worktree; isolate shared resources too. If task changes depend
  on each other or isolation is unsafe, work sequentially. Reverify the combined result after integration.
- Stop only if existing user changes conflict with the task.

## Changes

- Aim for lapidary code: the smallest clear implementation of the required behavior. Prefer direct control flow, precise
  names, and idiomatic constructs. Reduce concepts and special cases before reducing lines. Never trade correctness or
  readability for brevity.
- Identify the target project using the user’s instructions, Git remotes, and available upstream metadata. A user-owned
  fork does not make its upstream project user-owned. If ownership is uncertain, use the external-contribution default.
- **User-owned projects:** Optimize the design within the requested scope, not for diff size. Large changes are
  acceptable when they serve the request.
- **External projects:** Make the smallest correct, maintainable change that fulfills the request and project
  requirements. Follow project conventions and keep the diff easy to review. Avoid unrelated refactoring, formatting
  churn, dependencies, and speculative work. Include necessary tests and documentation. Ask before expanding scope or
  making an unrequested breaking change.
- Add abstractions, wrappers, layers, options, or files only when they make the required implementation easier to
  understand and change. Removing repetition alone is not sufficient; keep small duplication when sharing would require
  flags, callbacks, or unrelated coupling. Follow mandatory project conventions.
- For user-owned projects, do not add backward-compatibility shims, migration layers, legacy fallbacks, or old-data
  handling unless requested. Breaking changes are acceptable when required by the task. For external projects, follow
  the project’s compatibility requirements.
- “Perfect,” “long-term,” “generic,” or “must never break anything” do not authorize extra platforms, tiers, modes, or
  config surfaces. Implement the stated need; keep future ideas to one-line notes.
- Use named choices or domain types when they prevent plausible confusion. Enforce invariants at the trusted boundary
  and prevent later mutation from bypassing them; keep passive data simple. Validate once, not across layers.
- Before adding race, retry, timeout, or defensive edge-case machinery beyond a stated requirement, identify the
  observed failure, evidence, owning boundary, and simplest fix. Synthetic tests and hypothetical dependency behavior
  alone are not evidence. Without a real sighting, do not add guards or tests; always handle untrusted input, credential
  disclosure, and data-loss paths.
- Before adding an abstraction layer, config surface, or speculative option, present the minimal version first and
  default to it. Apply the same rule to changes affecting more than ~5 files in external projects. When applying this
  file threshold, tell the user before proceeding. If a broader approach is viable, compare the options and their
  tradeoffs, then ask the user to choose before proceeding.
- When told something is over-designed: cut it. Do not defend it.
- Preserve interfaces unless the task requires changes. Fix shared causes; do not hide errors.
- Handle recoverable failures using language idioms. Add useful context and preserve causes where appropriate; do not
  expose secrets in errors, logs, or debug output.
- Release resources deterministically using the language’s scoped-cleanup mechanisms. Make cleanup failures observable
  when callers need to handle them.
- When observable order is part of the contract, use an API with the required guarantees or sort explicitly; do not rely
  on unspecified iteration order.
- When supported inputs can overflow or lose required precision, use suitable types or checks and make lossy conversions
  explicit.
- Keep lock scopes as short as correctness permits; avoid unknown callbacks or suspension while locked unless necessary.
  Keep blocking work off event loops when responsiveness matters.
- Use standard interfaces or protocols when they fit, and honor the language’s equality, ordering, and hashing
  contracts.
- When porting, preserve observable behavior, failure semantics, and ordering unless a change is requested. Use existing
  tests as a reference and report deliberate differences.
- Use project tools to update dependency lockfiles and generated checksum files. Prefer targeted updates, avoid
  unrelated churn, and keep code, dependencies, and tooling compatible with supported language and runtime versions.
- Avoid comments that restate code or narrate edits. Add comments only for non-obvious rationale, invariants, or
  required project conventions.

## Verification

- Before finishing, map each new state machine, cache, retry, timeout, and cross-layer guard to a required behavior or
  observed failure; remove unsupported ones. Prefer standard tools and an acceptable stale result over custom
  synchronization when safety permits.
- Before declaring verification unavailable, check WSL, containers, or remote hosts. Prefer existing suitable
  environments; temporary tools follow `installation.md`.
- Choose checks from the requirements before implementation. When safe and practical, verify changed user-facing
  scenarios through the real interface; unit checks alone do not establish end-to-end behavior.
- Reproduce bugs before fixing when practical. For uncertain causes, separate observations from hypotheses and use
  discriminating experiments when practical. Recheck the original scenario when possible; prefer existing regression
  tests.
- For intermittent failures, record reproduction conditions and sample counts. Compare failure rates before and after
  when practical; a few successful runs do not establish a fix.
- For refactors, identify checks for the observable contract and, when practical, establish a baseline before editing;
  repeat the checks afterward.
- Test concrete, plausible, observable failures—not implementation spelling, duplicated logic, behavior-bypassing mocks,
  or “must never happen” cases with no real instance.
- Derive expected results from requirements or established behavior, independently of the implementation. Do not weaken
  checks just to make a change pass; explain intentional changes to their criteria.
- Use the smallest meaningful verification: prefer existing checks or direct execution. In projects without tests, add
  permanent tests, frameworks, mocks, or fixtures only on explicit request.
- Fix lint findings rather than bypassing them. Where project rules permit a justified exception, keep it narrowly
  scoped and explain it.
- Test relevant supported configurations when practical; do not assume optional features can all be enabled together.
- Measure before nontrivial performance optimization when practical; prefer simpler code when performance is sufficient.
- Review task changes for missed requirements, unintended edits, and plausible regressions; confirm findings with
  evidence.
- Run standard repository checks; report unavailable services, excessive cost, failures, and skipped coverage honestly.
