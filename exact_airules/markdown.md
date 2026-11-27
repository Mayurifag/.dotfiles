# Markdown

- For all Markdown edits, preserve the existing voice and use concise, natural wording without filler.
- READMEs are primarily user-written. Do not create or edit one unless the user explicitly asks. If you notice an
  important inaccuracy, mention it instead. When asked to edit a README, keep it focused on what the project does, who
  it is for, and how to use it. Avoid implementation details, change logs, and task summaries unless requested.
- For agent-facing instructions, prefer testable actions; check for overlap or conflicts with applicable rules and
  evaluate representative tasks and boundary cases when practical. Report behavioral verification gaps.
- Before finishing agent-facing edits, minimize tokens without losing meaning or clarity. Prefer `trigger -> file`
  bullets. Avoid tables, long prose, examples, and formatting without clear benefit; omit use-case prose already covered
  by an index.

## Code Blocks

- Use `~~~` in responses. In Markdown files, keep the existing fence character (`~~~` or backticks) on every edited
  block. Do not convert fences in either direction, including with a formatter. For new blocks, match the surrounding
  style; use `~~~` if there is no local style.

## CI

After Markdown edits, run project CI (including markdownlint if present); fix failures.
