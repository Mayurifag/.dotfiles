# Files that are JSONC (JSON with comments) — validated with --mode cjson.
# All other *.json files are validated as strict JSON.
JSONC_FILES := .vscode/settings.json
# MarkText's modify-template is chezmoi source, not a JSON document.
JSON_EXCLUDES := -not -path "./browser-mcp-template/profile/*" -not -path "./.opencode/browser-mcp-profile/*" -not -path "./AppData/Roaming/marktext/modify_preferences.json"
JSONC_EXCLUDES := $(foreach f,$(JSONC_FILES),-not -path "./$(f)")
SHELLCHECK := shellcheck -e SC2329

.PHONY: ci
ci: markdownlint shellcheck jsonlint browser-syntax-check ruff

.PHONY: browser-syntax-check
browser-syntax-check:
	set -e
	node --check dot_local/exact_espanso_managed_bins/executable_browser-test
	node --check browser-mcp-template/cdp-tampermonkey.js

.PHONY: markdownlint
markdownlint:
	markdownlint-cli2

.PHONY: jsonlint
jsonlint:
	@/usr/bin/find . -name "*.json" -not -path "./.git/*" $(JSON_EXCLUDES) $(JSONC_EXCLUDES) -exec jsonlint --mode json --quiet {} +
	jsonlint --mode cjson --quiet $(JSONC_FILES)

# Replace template actions with placeholders to lint the surrounding Python.
.PHONY: ruff
ruff:
	@set -e; \
	tmp_dir=$$(mktemp -d); \
	trap 'rm -rf "$$tmp_dir"' EXIT INT TERM; \
	git ls-files -z --cached --others --exclude-standard '*.py' '*.py.tmpl' > "$$tmp_dir/files"; \
	git grep -z --untracked -I -E -l -e '^#!.*python' -- . >> "$$tmp_dir/files" || [ "$$?" -eq 1 ]; \
	xargs -0 sh -c ' \
		status=0; \
		for file do \
			file="./$$file"; \
			[ -f "$$file" ] || continue; \
			case "$$file" in \
			*.tmpl) sed "s/{{[^}]*}}/\"template\"/g" "$$file" | ruff check --no-fix --quiet --stdin-filename "$$file" - || status=$$? ;; \
			*) ruff check --no-fix --quiet "$$file" || status=$$? ;; \
			esac; \
		done; \
		exit "$$status" \
	' sh < "$$tmp_dir/files"

.PHONY: shellcheck
shellcheck:
	@tmp_dir=$$(mktemp -d); \
	trap 'rm -rf "$$tmp_dir"' EXIT INT TERM; \
	scripts="$$tmp_dir/scripts"; \
	templates="$$tmp_dir/templates"; \
	{ git ls-files --cached --others --exclude-standard '*.sh' '*.bash'; git grep --untracked -I -E -l -e '^#!.*(sh|bash)' -- . ':!*.tmpl' || true; } | sort | uniq | tr -d '\r' > "$$scripts"; \
	git ls-files --cached --others --exclude-standard '*.sh.tmpl' '*.bash.tmpl' > "$$templates"; \
	status=0; \
	while IFS= read -r file; do \
		[ -f "$$file" ] || continue; \
		$(SHELLCHECK) "$$file" || status=$$?; \
	done < "$$scripts"; \
	while IFS= read -r file; do \
		[ -f "$$file" ] || continue; \
		tmp_file="$$tmp_dir/rendered/$$file"; \
		mkdir -p "$$(dirname "$$tmp_file")"; \
		sed '/^{{.*}}$$/d' "$$file" > "$$tmp_file"; \
		$(SHELLCHECK) "$$tmp_file" || status=$$?; \
	done < "$$templates"; \
	exit "$$status"
