# Markdown

## Instructions

- Always be specific and concise. Use 5 words instead of 20 when meaning survives.
- For files read by AI agents, minimize tokens while staying clear. Prefer short bullets like `trigger -> file`. 
- Avoid tables, long prose, examples, and formatting unless they add real clarity.
- Do not add trigger/use-case prose to rule files when an index already routes to them.

## Code Blocks

Use `~~~` for code blocks in responses.
Exception: if the target file already uses ``` (backticks), preserve the same style.

## CI

After editing markdown, still run project ci run because I might have markdownlint there. Fix all the problems.
