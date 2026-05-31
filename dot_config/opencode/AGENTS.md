# External File Loading

CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

Instructions:

- Do NOT preemptively load all references - use lazy loading based on actual need
- When loaded, treat content as mandatory instructions that override defaults
- Follow references recursively when needed

# Development Guidelines

If you are working with x use y:

encrypted secrets (ejson, git-crypt or others) - @~/airules/git-crypt.md
editing markdown files - @~/airules/markdown.md
Ruby project - @~/airules/ruby.md

# General guidelines

## Concise

You are REQUIRED to be as much concise and direct as possible - in code, suggests and in answers. Minimum viable code. Dont overcomplicate things. Never add abstractions, flexibility, or error handling for unused scenarios. If 200 lines can be 50, rewrite it. Ask: “Would a senior engineer call this over-engineered?” If yes, simplify.

## Pre-task guidelines

Before writing code:

- State assumptions clearly. If uncertain, ask.
- Present multiple interpretations instead of silently choosing one.
- Flag any simpler approach and push back when warranted.
- If anything is unclear, stop and name exactly what’s missing.

## Task guidelines

When you tried approach and observed it is wrong, before moving to other approach you are required to remove and clean things you've done (including code, data, tests). If you create unused imports/variables/functions, remove them immediately.

If you are said "fix" something:

- never “improve” unrelated code, comments, or formatting. 
- Match existing style exactly.

You may suggest improving code on the end, propose refactors.

Do not add comments or descriptions unless explicitly asked.
Follow DRY, best practices, keep projects maintainable. Code has to be SOLID, new file for new responsibility.

## Post-task guidelines

### Clean leftovers

Remove failed attempt code and any leftovers before trying another approach.

### Knowledge to save later

When you've done task, analyze everything you have done for knowledge that might be useful to have in future tasks. If it is for this repository, propose to add a concise rule to this repository's @AGENTS.md file. If it is global, user will decide himself. That is rare case, do not propose changes for low level knowledge. 

If in repository you are working on file `./AGENTS.md` exists, after doing tasks update it with rare, high-leverage knowledge from user interactions that will be useful across most future tasks. It is okay if nothing applicable to be added, it is rare case.

Focus exclusively on non-obvious, project-specific insights, preferences, constraints, or patterns that an experienced agent would not infer on its own.

- Early-stage projects: capture more foundational information.
- Mature projects: add nothing routine or obvious — only truly valuable, non-trivial details.

### Guideline user after task

Proactively suggest:

- refactoring any file that has grown large
- tech debt eliminations
- performance or security improvements

## GitHub

`gh` is installed and authenticated. Use it for any GitHub action instead of web requests.
