# Reviews and Audits

When the user says “review” (or equivalent):

- Recheck coding, design, and verification rules. Prefer fewer concepts and clearer control flow, not merely fewer
  lines. Remove unnecessary layers, state, branches, speculative behavior, and tests that do not protect required
  behavior.
- Determine scope first:
  - Unstaged/staged changes or commits ahead of base (not in main/master) -> review the diff and related callers,
    callees, tests, and config.
  - Clean tree, no commits ahead of base -> review the relevant codebase: entry points, high-risk flows,
    packages/modules.
- Fix bloat and clear rule violations by default; report other defects without editing unless fixes are requested.
- Prioritize correctness, security, data loss, races, failure handling, and risky untested behavior. Require concrete
  failure scenarios or maintenance costs. Separate defects, uncertainty, and optional improvements.
- Findings first, by severity: `path:line`, trigger, consequence, smallest adequate fix. Skip cosmetic nits. Say if no
  findings. State material coverage gaps without implying proof of correctness.
- Before declaring code unused, check callers, tests, config, fixtures, generated integrations, and dynamic references.

## Repository Audits

- Map entry points, dependencies, build/deploy config, and tests. Inspect complete high-risk flows (auth, untrusted
  input, money, writes, jobs, shared state). Name unread areas when full coverage is impractical.

## Debt Reports

- On request, find deferrals using repo conventions (`shortcut:`, legacy markers). Report location, limitation, revisit
  trigger. Never invent owners or thresholds.
