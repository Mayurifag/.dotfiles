# Reviews and Audits

- Keep reviews read-only unless fixes are requested.
- Read connected callers, callees, and tests, not only the diff. Trace input through state changes to output.
- Prioritize correctness, security, data loss, races, failure handling, and risky untested behavior. Assess performance against stated or explicit assumed load.
- Require a concrete failure scenario or maintenance cost. Verify assumptions before reporting; separate confirmed defects from uncertainty and optional improvements.
- Report findings first, ordered by severity: `path:line`, trigger, consequence, and smallest adequate fix. Explain reasoning when needed; skip cosmetic nits.
- If no findings remain, say so. State material coverage gaps; no findings does not prove correctness.

## Repository Audits

- Map entry points, dependencies, build/deploy configuration, and tests first.
- Inspect complete high-risk flows: authentication, untrusted input, money, writes, jobs, and shared state. Name unread areas when full coverage is impractical.
- Before declaring code unused, check callers, tests, configuration, fixtures, generated integrations, and dynamic references.
- Recommend deletion or consolidation only with evidence. Respect documented limits unless requirements exceed them; comments never excuse security defects.

## Debt Reports

- On request, find intentional deferrals using repository conventions, including `shortcut:` and legacy markers. Respect ignored paths.
- Report location, limitation, and revisit trigger. Flag missing context rather than inventing owners or thresholds.
- No marked debt does not mean no technical debt. Generate reports on demand, not as a duplicate maintained ledger.
