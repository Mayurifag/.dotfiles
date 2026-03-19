.PHONY: ci
ci: markdownlint shellcheck

.PHONY: markdownlint
markdownlint:
	markdownlint-cli2

.PHONY: shellcheck
shellcheck:
	@if ! command -v shellcheck >/dev/null 2>&1; then echo "shellcheck not found, skipping"; exit 0; fi; \
	sh_files=$$(find . -name "*.sh" -not -path "./.git/*"); \
	if [ -n "$$sh_files" ]; then \
		shellcheck $$sh_files; \
	fi
