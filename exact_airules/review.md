# Reviews and Audits

- Reviews are read-only unless fixes are requested. Read callers/callees/tests beyond the diff; trace inputs through
  state changes to output.
- Prioritize correctness, security, data loss, races, failure handling, and risky untested behavior; judge performance
  at stated or explicit assumed load.
- Require concrete failure scenarios or maintenance costs; verify assumptions and separate defects, uncertainty, and
  optional improvements.
- Findings first, by severity: `path:line`, trigger, consequence, smallest adequate fix; explain as needed, skip
  cosmetic nits.
- Say if no findings; state material coverage gaps without implying proof of correctness.

## Repository Audits

- Map entry points, dependencies, build/deploy config, and tests; inspect complete high-risk flows: authentication,
  untrusted input, money, writes, jobs, shared state. Name unread areas when full coverage is impractical.
- Before declaring code unused, check callers, tests, config, fixtures, generated integrations, and dynamic references.
- Require evidence for deletion/consolidation. Respect documented limits unless requirements exceed them; comments do
  not excuse security defects.

## Debt Reports

- On request, find deferrals using repo conventions (`shortcut:`, legacy markers); respect ignored paths. Report
  location, limitation, revisit trigger; flag missing context, never invent owners/thresholds. No markers does not mean
  no debt.
- Generate reports on demand, not a duplicate maintained ledger.
