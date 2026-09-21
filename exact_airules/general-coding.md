# General Coding

## Refactors

- For refactors, improve maintainability deliberately; remove duplication.

## Compatibility

- Default to replacing old behavior, not preserving it.
- Do not add fallbacks, legacy paths, temporary adapters, old API support, broad defensive guards, or duplicate implementations unless explicitly required.

## Before Writing Code

- State assumptions clearly. If ambiguity is safe and reversible, proceed with the safest interpretation.
- Ask only when proceeding risks destructive, broad, or user-visible behavior.
- Present multiple interpretations instead of silently choosing one.
- For external libraries, frameworks, CLIs, SDKs, APIs, config schemas, or MCP servers, load `~/airules/research.md` first.
- If blocked, stop and name exactly what is missing.

## Task Guidelines

- Do not disable, remove, bypass, deduplicate, or clean up output just to hide an error unless explicitly asked. Trace unwanted output, duplication, or generated artifacts back to their source.
- Keep projects maintainable. For fixes, preserve existing style, scope, names, commands, file layout, and patterns unless a change clearly improves clarity.
- For refactors, reduce duplication and improve boundaries.
- Prefer repository-provided commands over raw underlying tools. If a repo has `make`, package scripts, task files, or documented wrappers, use those first.
- Do not revert or rewrite unrelated user changes. Ignore unrelated changes unless they directly conflict with the task.

## Testing

- For large features, one end-to-end or integration test may be enough when the repository supports it and it validates the real user flow.
- For bug fixes, first reproduce the bug with a failing unit test when practical. Then fix the code and rerun that unit test until green.
- Run the repo's standard check command when available (`make ci`, `npm test`, `cargo test`, etc.). If it is too slow, destructive, or needs unavailable services, say why it was skipped.
- Do not claim work is done until the relevant check has passed. If verification was skipped or failed, say that plainly.

## Post-Task

- Consider whether the task revealed rare, high-leverage knowledge useful for future tasks.
- If it is repository-specific, propose a concise rule for that repository's `AGENTS.md`; if it is global, let the user decide.
- Do not propose changes for low-level knowledge.
- If the repository has `./AGENTS.md`, update it only with non-obvious, project-specific knowledge that helps most future tasks.
- Early-stage projects: capture more foundational information.
- Mature projects: add nothing routine or obvious; only truly valuable, non-trivial details.
