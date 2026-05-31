# Makefiles

Use this when a repository has `Makefile`, `makefile`, `GNUmakefile`, or `makefiles/*.mk`.

- If a project has a Makefile, read it before choosing build, test, lint, install, or generation commands.
- If it includes `./makefiles/*.mk` or similar, read those included files too; important targets may live there.
- Prefer existing make targets over raw underlying commands when they express the same operation.
- When repeated project commands are missing and the repo uses Make, consider adding a short target instead of scattering long commands.
- Keep Makefiles concise. If a root Makefile grows large, prefer splitting related targets into `./makefiles/*.mk` and including them.
