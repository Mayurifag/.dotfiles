# Files that are JSONC (JSON with comments) — validated with --mode cjson.
# All other *.json files are validated as strict JSON.
JSONC_FILES := .vscode/settings.json
JSONC_EXCLUDES := $(foreach f,$(JSONC_FILES),-not -path "./$(f)")

.PHONY: ci
ci: markdownlint shellcheck jsonlint

.PHONY: markdownlint
markdownlint:
	markdownlint-cli2

.PHONY: jsonlint
jsonlint:
	@if ! command -v jsonlint >/dev/null 2>&1; then echo "jsonlint not found, skipping"; exit 0; fi; \
	json_files=$$(/usr/bin/find . -name "*.json" -not -path "./.git/*" $(JSONC_EXCLUDES)); \
	if [ -n "$$json_files" ]; then \
		echo "$$json_files" | xargs jsonlint --mode json --quiet; \
	fi; \
	jsonlint --mode cjson --quiet $(JSONC_FILES)

.PHONY: shellcheck
shellcheck:
	@if ! command -v shellcheck >/dev/null 2>&1; then echo "shellcheck not found, skipping"; exit 0; fi; \
	sh_files=$$(find . -name "*.sh" -not -path "./.git/*"); \
	if [ -n "$$sh_files" ]; then \
		shellcheck $$sh_files; \
	fi
