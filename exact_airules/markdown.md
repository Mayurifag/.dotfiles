# Markdown

- For agent-facing files, minimize tokens without losing clarity; prefer `trigger -> file` bullets. Avoid tables, long
  prose, examples, and formatting without clear benefit; omit use-case prose already covered by an index.

## Code Blocks

Use `~~~` in responses; preserve existing backtick fences when editing files.

## CI

After Markdown edits, run project CI (including markdownlint if present); fix failures.
