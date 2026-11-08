# General Coding

## Scope

- Read affected code before editing; trace callers, tests, fixtures, configuration, and exports.
- Assess data loss, disclosure, and compatibility; ask before ambiguous broad changes.
- Stop only if existing user changes conflict with the task.

## Changes

- Before finishing, check code within the authorized scope for equivalents with fewer meaningful symbols; use them when
  behavior, readability, performance, safety, compatibility, and other requirements are preserved; do not minify to save
  characters. Optimize the end-to-end design, not the diff size. Trace affected flows across layers; prefer clear
  responsibilities, fewer unnecessary round trips, and less duplicated work. Reconsider boundaries that cause needless
  complexity.
- Reuse project patterns before platform features, standard libraries, or installed dependencies, unless those patterns
  perpetuate the problem.
- No error handling for cases that cannot happen. Three similar lines beat a helper used once.
- Before adding or installing an unfamiliar package, verify its exact name and publisher against the official project
  docs/source; a registry entry alone is not proof of provenance.
- Fix shared causes; trace unwanted output/artifacts instead of hiding errors.
- Before adding a workaround or override for an upstream bug, check whether an available, compatible upgrade fixes it;
  recommend that upgrade first, and use a scoped workaround only when upgrading is blocked or explicitly declined.
- Preserve interfaces unless the task requires changes. Refactor to remove duplication or separate unrelated
  responsibilities, not meet line counts.
- Replace obsolete behavior; add compatibility only for explicit requirements or existing consumers/data.
- Preserve validation, error handling, security, accessibility, and hardware calibration when simplifying.
- Use repository workflows and package managers; never hand-edit generated lockfiles.
- Record useful intentional limits as `shortcut: <limit>, <revisit trigger>`; no separate debt ledger unless requested.
- Comments and docstrings explain why, not what. Do not restate the next line ("increment counter"), add section
  banners, leave commented-out code, or replace a fix with a workaround comment; agents copy those. Do not delete an
  existing why-comment or `shortcut:` to save symbols.

## Verification

- Before drawing version-dependent conclusions, verify the executable and version used by the affected process; a
  different shell PATH or configured pin may point elsewhere.
- Reproduce bugs before fixing when practical; prefer existing tests for focused regression coverage.
- In untested projects, add permanent tests, frameworks, mocks, fixtures, or test-only CI only on explicit request.
- Use the smallest meaningful verification; existing checks or direct execution may suffice. Add test files only for
  concrete plausible observable failures, not implementation spelling, duplicated logic, or mocks that bypass the
  behavior.
- Run standard repository checks; fix all errors and warnings in touched files, including pre-existing diagnostics.
  Report unavailable services, excessive cost, failures, and skipped coverage.
