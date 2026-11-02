# General Coding

## Scope

- Read affected code before editing; trace callers, tests, fixtures, configuration, and exports.
- Assess data loss, disclosure, and compatibility; ask before ambiguous broad changes.
- Stop only if existing user changes conflict with the task.

## Changes

- Within the authorized scope, optimize the end-to-end design, not the diff size. Trace affected flows across layers;
  prefer clear responsibilities, fewer unnecessary round trips, less duplicated work, and the least code needed for
  correct, maintainable behavior. Reconsider boundaries that cause needless complexity; do not trade clarity or safety
  for fewer lines.
- Reuse project patterns before platform features, standard libraries, or installed dependencies, unless those patterns
  perpetuate the problem.
- Add dependencies, abstractions, wrappers, options, or flexibility only for concrete needs.
- Fix shared causes; trace unwanted output/artifacts instead of hiding errors.
- Preserve interfaces unless the task requires changes. Refactor to remove duplication or separate unrelated
  responsibilities, not meet line counts.
- Replace obsolete behavior; add compatibility only for explicit requirements or existing consumers/data.
- Preserve validation, error handling, security, accessibility, and hardware calibration when simplifying.
- Use repository workflows and package managers; never hand-edit generated lockfiles.
- Record useful intentional limits as `shortcut: <limit>, <revisit trigger>`; no separate debt ledger unless requested.

## Verification

- Reproduce bugs before fixing when practical; prefer existing tests for focused regression coverage.
- In untested projects, add permanent tests, frameworks, mocks, fixtures, or test-only CI only on explicit request.
- Use the smallest meaningful verification; existing checks or direct execution may suffice. Add test files only for
  concrete plausible observable failures, not implementation spelling, duplicated logic, or mocks that bypass the
  behavior.
- Run standard repository checks; report unavailable services, excessive cost, failures, and skipped coverage.
