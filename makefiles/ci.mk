# Files that are JSONC (JSON with comments) — validated with --mode cjson.
# All other *.json files are validated as strict JSON.
JSONC_FILES := .vscode/settings.json
JSONC_EXCLUDES := $(foreach f,$(JSONC_FILES),-not -path "./$(f)")
SHELLCHECK := shellcheck -e SC2329

.PHONY: ci
ci: markdownlint shellcheck jsonlint

.PHONY: markdownlint
markdownlint:
	markdownlint-cli2

.PHONY: jsonlint
jsonlint:
	@/usr/bin/find . -name "*.json" -not -path "./.git/*" $(JSONC_EXCLUDES) -exec jsonlint --mode json --quiet {} +
	jsonlint --mode cjson --quiet $(JSONC_FILES)

.PHONY: shellcheck
shellcheck:
	@tmp_dir=$$(mktemp -d); \
	trap 'rm -rf "$$tmp_dir"' EXIT INT TERM; \
	scripts="$$tmp_dir/scripts"; \
	templates="$$tmp_dir/templates"; \
	{ git ls-files '*.sh' '*.bash'; git grep -I -E -l -e '^#!.*(sh|bash)' -- . ':!*.tmpl' || true; } | sort -u > "$$scripts"; \
	git ls-files '*.sh.tmpl' '*.bash.tmpl' > "$$templates"; \
	status=0; \
	while IFS= read -r file; do \
		[ -n "$$file" ] || continue; \
		$(SHELLCHECK) "$$file" || status=$$?; \
	done < "$$scripts"; \
	while IFS= read -r file; do \
		[ -n "$$file" ] || continue; \
		tmp_file="$$tmp_dir/rendered/$$file"; \
		mkdir -p "$$(dirname "$$tmp_file")"; \
		sed '/^{{.*}}$$/d' "$$file" > "$$tmp_file"; \
		$(SHELLCHECK) "$$tmp_file" || status=$$?; \
	done < "$$templates"; \
	exit "$$status"
