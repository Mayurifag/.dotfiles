# General Coding

## Concise Code

- For fixes, prefer the smallest correct change. Do not refactor unrelated code.
- For refactors, improve maintainability deliberately; remove duplication.
- If 200 lines can be 50, rewrite it. Ask: "Would a senior engineer call this over-engineered?" If yes, simplify.

## Compatibility

- Default to replacing old behavior, not preserving it.
- Do not add fallbacks, legacy paths, temporary adapters, old API support, broad defensive guards, or duplicate implementations unless explicitly required.
- When changing behavior, remove obsolete code in the same task. Mention possible compatibility breaks in the final response instead of adding compatibility code.

## Before Writing Code

- State assumptions clearly. If ambiguity is safe and reversible, proceed with the safest interpretation.
- Ask only when proceeding risks destructive, broad, or user-visible behavior.
- Present multiple interpretations instead of silently choosing one.
- Flag simpler approaches and push back when warranted.
- For external libraries, frameworks, CLIs, SDKs, APIs, config schemas, or MCP servers, load `~/airules/research.md` first.
- If blocked, stop and name exactly what is missing.

## Task Guidelines

- Fix the root cause, not the symptom. Do not disable, remove, or bypass a feature to hide an error unless explicitly asked.
- If an approach is wrong, remove its code/data/tests before trying another. Remove unused imports, variables, and functions immediately.
- After finding the root cause, remove diagnostic/workaround changes that are no longer needed.
- Do not add comments or descriptions unless explicitly asked.
- Keep projects maintainable. For fixes, preserve existing style, scope, names, commands, file layout, and patterns unless a change clearly improves clarity.
- For refactors, reduce duplication and improve boundaries without speculative architecture.
- Prefer repository-provided commands over raw underlying tools. If a repo has `make`, package scripts, task files, or documented wrappers, use those first.
- Do not revert or rewrite unrelated user changes. Ignore unrelated changes unless they directly conflict with the task.
- You may suggest follow-up refactors at the end.

## Testing

- Test meaningful behavior, not low-value implementation details or coverage padding.
- For large features, one end-to-end or integration test may be enough when the repository supports it and it validates the real user flow.
- For bug fixes, first reproduce the bug with a failing unit test when practical. Then fix the code and rerun that unit test until green.
- If the ideal test is impractical, say why and run the narrowest useful check instead.
- Run the repo's standard check command when available (`make ci`, `npm test`, `cargo test`, etc.). If it is too slow, destructive, or needs unavailable services, say why it was skipped.

If asked to "fix" something:

- Never improve unrelated code, comments, or formatting.
- Match existing style exactly.

## Post-Task

- Remove failed attempt code and leftovers before trying another approach.
- Consider whether the task revealed rare, high-leverage knowledge useful for future tasks.
- If it is repository-specific, propose a concise rule for that repository's `AGENTS.md`; if it is global, let the user decide.
- Do not propose changes for low-level knowledge.
- If the repository has `./AGENTS.md`, update it only with non-obvious, project-specific knowledge that helps most future tasks.
- Early-stage projects: capture more foundational information.
- Mature projects: add nothing routine or obvious; only truly valuable, non-trivial details.
- Proactively suggest refactors for large files, tech debt eliminations, and performance or security improvements.
