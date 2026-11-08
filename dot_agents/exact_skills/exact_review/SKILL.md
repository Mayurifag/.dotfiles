---
name: review
description: Review code changes for security, performance, bugs, and quality; apply safe, shorter equivalent implementations. Use for staged, unstaged, commit, or PR reviews.
---

# Review

Review changes for concrete defects and apply equivalent simplifications within the reviewed scope.

## Process

1. Select the requested scope. By default review staged changes, otherwise unstaged changes, otherwise the latest
   commit. For a file, check its unstaged changes then staged changes. For a PR, review changes since branching from the
   base.
2. Read changed files and relevant callers, callees, tests, and configuration; trace behavior beyond the diff.
3. Always replace reviewed code with a version using fewer meaningful symbols when behavior, edge cases, error handling,
   readability, performance, security, accessibility, and compatibility are preserved. Do not minify for character
   count.
4. Edit only the current working tree, and only when its relevant content matches the reviewed snapshot. Preserve
   unrelated changes; never stage changes or rewrite history. If a shorter alternative cannot safely be applied, report
   it.
5. Check correctness, security, data loss, races, failure handling, performance, maintainability, and missing tests.
   Report other defects without fixing them unless requested. Use existing checks to verify applied simplifications.
6. Challenge each finding: verify a realistic, in-scope trigger and impact against callers, guards, tests,
   configuration, and baseline when applicable. Reproduce with a minimal safe test when practical; otherwise trace it
   and explain why it was not reproduced. Drop disproved, duplicate, speculative, or immaterial findings; separate
   credible but unverified risks and state uncertainty. Missing tests alone are a coverage gap, not a defect, unless
   requested or required.

## Report

Lead with findings by severity (impact and likelihood): `path:line`, trigger, consequence, evidence or reproduction, and
smallest adequate fix. Separate optional improvements; skip cosmetic nits. List applied simplifications and verification
results, including gaps. If no findings, say so without implying proof of correctness.
