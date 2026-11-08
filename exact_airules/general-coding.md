# General Coding

## Scope

- Read affected code before editing; trace callers, tests, fixtures, configuration, and exports.
- Before estimating migration effort or required user actions, check existing integration links, deployed configuration
  when accessible and authorized, and built-in migration features. Mark unverified claims as uncertain.
- Assess data loss, disclosure, and compatibility; ask before ambiguous broad changes.
- Stop only if existing user changes conflict with the task.

## Changes

- Optimize end-to-end design within scope, not diff size. Trace affected flows; prefer clear responsibilities, less
  duplication, and minimal correct, maintainable code. Reconsider boundaries that add needless complexity.
- Add abstractions, wrappers, layers, options, or files only to reduce complexity or duplication, or match project
  patterns—not for speculative needs or hypothetical cases.
- No backward-compatibility shims, migration layers, legacy fallbacks, or old-data handling unless explicitly requested.
  Breaking changes are acceptable by default.
- “Perfect,” “long-term,” “generic,” or “must never break anything” do not authorize extra platforms, tiers, modes, or
  config surfaces. Implement the stated need; keep future ideas to one-line notes.
- Validate once at the trusted boundary, not across layers.
- Before race-condition, security, or hypothetical edge-case code/tests, state the failure, likelihood, and complexity
  cost in one line. No real sighting (log, bug report, commit, incident) → no guard or test. Always handle untrusted
  external input and data-loss paths.
- Before adding an abstraction layer, config surface, more than ~5 files, or any speculative option, present the minimal
  version first and default to it.
- When told something is over-designed: cut it. Do not defend it.
- Preserve interfaces unless the task requires changes. Fix shared causes; do not hide errors.

## Verification

- Before declaring verification unavailable, check WSL, containers, or remote hosts. Prefer existing suitable
  environments; temporary tools follow `installation.md`.
- Reproduce bugs before fixing when practical. Prefer existing tests for focused regression coverage.
- Test concrete, plausible, observable failures—not implementation spelling, duplicated logic, behavior-bypassing mocks,
  or “must never happen” cases with no real instance.
- Use the smallest meaningful verification: prefer existing checks or direct execution. In projects without tests, add
  permanent tests, frameworks, mocks, or fixtures only on explicit request.
- Run standard repository checks; report unavailable services, excessive cost, failures, and skipped coverage honestly.
