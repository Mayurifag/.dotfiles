# General Coding

## Scope

- Read affected code and trace callers, tests, fixtures, config, and exports before editing.
- Before migration estimates/user actions, check integration links, accessible authorized deployed config, and built-in
  migration features. Mark unverified claims uncertain.
- Assess data loss, disclosure, and compatibility. Resolve behavior-changing assumptions from requirements/code; explain
  and ask before consequential ambiguous choices or broad changes.
- Checklist explicit constraints: names, behavior, placement, file scope, exclusions. Verify each before finishing.
- For larger work, identify dependencies; finish and verify end-to-end slices when practical. Record incidental findings
  without expanding scope.
- Concurrent tasks -> separate branches/worktrees; isolate shared resources too. If dependent or unsafe to isolate, work
  sequentially. Reverify after integration.
- Preserve existing user changes. Continue past unrelated edits; if user edits conflict with the task, pause only the
  work that depends on resolving the conflict.

## Changes

- Do not vendor third-party code/assets/binaries/dependency trees unless explicitly requested. Use package managers or
  pinned upstream fetches; store declarations and project-owned overrides, not downloaded payloads.
- Vendor-specific assets (e.g. Apple emoji) -> prefer native assets, a CDN, a package, or a pinned fetch over repository
  copies. For any rare exception, compare alternatives and tradeoffs, explain why a copy is proposed, verify
  redistribution rights, and ask the user to explicitly approve adding the specific files to the repository, even if
  requested.
- Use the smallest clear implementation: direct control flow, precise names, idiomatic code. Reduce concepts/special
  cases before lines; never sacrifice correctness or readability.
- Never create a project folder named `utils` or use another vague catch-all name such as `helpers` or `misc`. Name
  folders for the feature, domain, or responsibility they contain.
- Keep behavior consistent across supported OSes and prefer shared code. Use OS-specific code or exclusions only for an
  explicit requirement or a verified platform constraint; explain why. Do not skip an OS merely because a cleanup target
  is usually absent there if removal already handles missing targets.
- Determine target ownership from instructions, remotes, and upstream metadata. A user-owned fork does not make upstream
  user-owned; uncertain ownership -> external-contribution rules.
- User-owned -> optimize design within scope, not diff size. Make breaking changes only when the task requires them.
  Before discarding existing user data or making it unreadable, explain the impact and get approval. Do not add
  compatibility shims, migration layers, or legacy fallbacks unless requested.
- External -> smallest correct, maintainable, reviewable change following project conventions/compatibility. Include
  necessary tests/docs; avoid unrelated refactoring, formatting, dependencies, and speculation. Ask before scope
  expansion or unrequested breaking changes.
- Add abstractions/wrappers/layers/options/files only to clarify required implementation and maintenance, not just
  remove repetition. Keep small duplication rather than flags, callbacks, or unrelated coupling; follow mandatory
  conventions.
- Default to the minimal in-scope approach. For external changes touching more than about five files, notify the user
  before editing. If a broader approach is worth considering, explain the tradeoffs and get approval before taking it.
- “Perfect,” “long-term,” “generic,” or “must never break anything” do not authorize extra platforms/tiers/modes/config.
  Implement the stated need; future ideas -> one-line notes.
- Use named choices/domain types against plausible confusion. Validate invariants once at the trusted boundary; prevent
  mutation bypasses and keep passive data simple.
- Add state machines, caches, race handling, retries, timeouts, or other guards only when a requirement, observed
  failure, or verified contract or constraint shows a need. Identify where the handling belongs and use the simplest
  fix. Synthetic tests and hypothetical dependencies alone do not justify guards or tests. Always handle untrusted
  input, credential disclosure, and data-loss paths.
- When told something is over-designed, remove unnecessary complexity. If simplifying would drop required behavior,
  explain the tradeoff and ask before dropping it.
- Preserve interfaces unless changes are required; fix shared causes and never hide errors.
- Use idiomatic failure handling with useful context/preserved causes; expose no secrets in errors, logs, or debug
  output.
- Use deterministic scoped resource cleanup; expose cleanup failures when callers need them.
- Required observable order -> guaranteed API or explicit sort, never unspecified iteration.
- Supported-input overflow/precision risks -> suitable types/checks and explicit lossy conversions.
- Keep locks short; avoid unknown callbacks/suspension while locked unless necessary. Keep blocking work off event loops
  when responsiveness matters.
- Use fitting standard interfaces/protocols; honor equality, ordering, and hashing contracts.
- Ports -> preserve observable behavior, failures, and order unless asked otherwise. Use existing tests; report
  deliberate differences.
- Config keys, flags, and defaults -> trace affected loaders, examples, CI, deployment, tests, and docs. Update in-scope
  references and report any required operator migration or docs change left out of scope.
- Once a migration has shipped or run in a persistent or shared environment, fix forward with a new migration. For
  schema changes, verify fresh setup and upgrade from representative prior data on a disposable database when practical.
- Before adding a dependency, verify its exact registry name and confirm that its publisher and source match the
  intended project.
- Update lockfiles/checksums with project tools, target changes, avoid unrelated churn, and preserve supported runtime/
  language compatibility across code, dependencies, and tooling.
- Declare project tool versions once in the owning manifest when practical; reuse the pin in CI and Docker. Prefer tools
  bundled with base images. Install extra tools only where a build, test, or runtime workflow needs them.
- Comments -> non-obvious rationale, invariants, or required conventions; do not restate code or narrate edits.

## Workarounds

- Use the repository's workaround ADR (default: root `WORKAROUNDS-ADR.md`) only for temporary measures with a specific
  change that would make them obsolete and a check that proves it. Include the location, reason, affected versions, and
  any known upstream issue. Apply the same test to rule or check suppressions.
- Document standing policies, platform safeguards, and other measures without a concrete removal trigger next to the
  code or in the relevant maintenance docs, not in the workaround ADR.
- On every project dependency update, including tooling and transitive updates, check every active recorded workaround
  against current versions and supported environments, even if unrelated to the updated dependency. Remove those
  confirmed unnecessary, verify affected behavior and checks, and remove or mark their records resolved. Keep and report
  any whose applicability cannot be verified; update retained records when findings change.

## Verification

- Prefer standard tools and acceptable stale results over custom synchronization when safe.
- Before declaring verification unavailable, check WSL, containers, or remote hosts; prefer existing environments.
  Temporary tools -> `~/airules/installation.md`.
- Choose requirement-based checks before implementation. Verify changed user-facing scenarios through the real interface
  when safe/practical; unit checks alone do not prove end-to-end behavior.
- Before additional verification, identify the distinct, plausible failure it can expose or the decision it can change.
  Skip checks that only duplicate evidence. Stop when required checks and proportionate risk-based verification are
  complete; report material gaps.
- Bugs -> reproduce first when practical; separate observations/hypotheses and use discriminating experiments for
  uncertain causes. Recheck the original scenario when possible; prefer existing regression tests.
- Intermittent failures -> record conditions/sample counts; compare before/after rates when practical. A few passes are
  not proof of a fix.
- Refactors -> observable-contract checks, practical pre-edit baseline, then repeat afterward.
- Tests -> required observable behavior, established contracts, or concrete regressions. Derive expectations from these
  sources, not the implementation under test.
- Before adding a test, identify the realistic defect it catches. Skip duplicate protection, repeated implementation
  logic, and unseen “must never happen” cases.
- Bug fixes -> when practical, confirm the regression test fails for the intended reason before the fix and passes
  afterward. Otherwise, check that a plausible incorrect implementation fails it; report if unverified.
- Extend existing tests before adding files/fixtures/helpers/dependencies. Use the smallest meaningful setup; do not
  build test infrastructure for a small change.
- Use the lowest-cost interface that exposes the failure. Use integration/end-to-end tests for interaction defects. Mock
  external boundaries only when needed; never mock away the behavior under test.
- Do not add tests to meet count, line, or coverage targets. Stop when required behaviors and distinct, realistic
  failure modes are protected.
- Never weaken assertions, change expectations, or bypass behavior merely to pass. Explain requirement-driven
  expectation changes.
- In untested projects, add permanent tests/frameworks/mocks/fixtures only on explicit request; use direct verification
  otherwise.
- Summarize what checks protect and material gaps. Passing tests alone do not establish correctness.
- Fix lint rather than bypass it; explain narrowly scoped, justified exceptions permitted by project rules.
- Check relevant supported configurations when practical; optional features may be mutually exclusive.
- New features with plausible performance/resource costs -> when practical, capture a baseline before coding and use
  existing tools to compare a representative workload after, or with the feature off/on, under comparable conditions.
  Report relevant metrics (e.g. latency in ms, CPU, memory, bundle size, network requests), values and deltas, workload/
  environment, sample counts, and noise where applicable. If comparison is infeasible, report available measurements and
  the blocker. Flag material or avoidable costs; distinguish feature overhead from proven waste.
- Measure before nontrivial optimization when practical. Prefer simpler code when performance is sufficient, unless
  project rules or explicit requirements prioritize further performance gains.
- Review for missed requirements, unintended edits, and plausible regressions; confirm findings with evidence.
- Run standard repository checks. Before reporting a pass, inspect the runner's summary, not just its exit code. Report
  failures, relevant skips, and checks not run with the reason.
