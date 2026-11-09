# General Coding

## Scope

- Read affected code before editing; trace callers, tests, fixtures, configuration, and exports.
- Before estimating migration effort or required user actions, check existing integration links, deployed configuration
  when accessible and authorized, and built-in migration features. Mark unverified claims as uncertain.
- Assess data loss, disclosure, and compatibility; ask before ambiguous broad changes.
- Turn explicit user constraints into a short checklist. Preserve required names, behavior, placement, file scope, and
  exclusions; verify each before finishing.
- Stop only if existing user changes conflict with the task.

## Changes

- Identify the target project using the user’s instructions, Git remotes, and available upstream metadata. A user-owned
  fork does not make its upstream project user-owned. If ownership is uncertain, use the external-contribution default.
- **User-owned projects:** Optimize the design within the requested scope, not for diff size. Large changes are
  acceptable when they serve the request.
- **External projects:** Make the smallest correct, maintainable change that fulfills the request and project
  requirements. Follow project conventions and keep the diff easy to review. Avoid unrelated refactoring, formatting
  churn, dependencies, and speculative work. Include necessary tests and documentation. Ask before expanding scope or
  making an unrequested breaking change.
- Add abstractions, wrappers, layers, options, or files only to reduce complexity or duplication, or match project
  patterns—not for speculative needs or hypothetical cases.
- For user-owned projects, do not add backward-compatibility shims, migration layers, legacy fallbacks, or old-data
  handling unless requested. Breaking changes are acceptable when required by the task. For external projects, follow
  the project’s compatibility requirements.
- “Perfect,” “long-term,” “generic,” or “must never break anything” do not authorize extra platforms, tiers, modes, or
  config surfaces. Implement the stated need; keep future ideas to one-line notes.
- Validate once at the trusted boundary, not across layers.
- Before race-condition, security, or hypothetical edge-case code/tests, state the failure, likelihood, and complexity
  cost in one line. No real sighting (log, bug report, commit, incident) → no guard or test. Always handle untrusted
  external input and data-loss paths.
- Before adding an abstraction layer, config surface, or speculative option, present the minimal version first and
  default to it. Apply the same rule to changes affecting more than ~5 files in external projects. When applying this
  file threshold, tell the user before proceeding. If a broader approach is viable, compare the options and their
  tradeoffs, then ask the user to choose before proceeding.
- When told something is over-designed: cut it. Do not defend it.
- Preserve interfaces unless the task requires changes. Fix shared causes; do not hide errors.
- Avoid comments that restate code or narrate edits. Add comments only for non-obvious rationale, invariants, or
  required project conventions.

## Verification

- Before declaring verification unavailable, check WSL, containers, or remote hosts. Prefer existing suitable
  environments; temporary tools follow `installation.md`.
- Reproduce bugs before fixing when practical. Prefer existing tests for focused regression coverage.
- Test concrete, plausible, observable failures—not implementation spelling, duplicated logic, behavior-bypassing mocks,
  or “must never happen” cases with no real instance.
- Use the smallest meaningful verification: prefer existing checks or direct execution. In projects without tests, add
  permanent tests, frameworks, mocks, or fixtures only on explicit request.
- Run standard repository checks; report unavailable services, excessive cost, failures, and skipped coverage honestly.
