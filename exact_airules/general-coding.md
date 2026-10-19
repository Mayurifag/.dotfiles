# General Coding

## Scope

- Read the affected code before editing. Trace callers and identify affected tests, fixtures, configuration, and exports.
- Check for data loss, disclosure, and compatibility risks. State safe assumptions; ask before ambiguous destructive or broad changes.
- Preserve unrelated user changes. Stop only when they conflict with the task.

## Changes

- Choose the smallest complete fix. Reuse project patterns before platform features, standard libraries, or installed dependencies.
- Do not add dependencies, abstractions, wrappers, options, or speculative flexibility without a concrete need.
- Fix the shared cause, not each symptom. Trace unwanted output or generated artifacts instead of hiding errors.
- Preserve existing style and interfaces unless changing them serves the task. Refactor to remove duplication or separate unrelated responsibilities, not to meet line counts.
- Replace obsolete behavior by default. Add compatibility paths only for explicit requirements or concrete existing consumers or data.
- Preserve validation, error handling, security, accessibility, and hardware calibration when simplifying code.
- Prefer repository commands and workflows. Never hand-edit generated lockfiles; use the owning package manager.
- Record intentional limits only when useful: `shortcut: <limit>, <revisit trigger>`. Do not add a separate debt ledger unless requested.

## Verification

- Reproduce bugs before fixing them when practical. Use the existing test setup for focused regression coverage when available.
- If a project had no tests before the task, do not add permanent tests, test frameworks, mocks, fixtures, or test-only CI wiring unless explicitly requested.
- Still verify changes with temporary test files outside the repository; remove them and their generated artifacts before finishing.
- Test the real risk, not implementation trivia. An existing integration test can suffice when it covers the changed flow.
- Run the repository's standard checks. Report unavailable services, excessive cost, failures, and skipped coverage explicitly.
