.PHONY: mise-packages clean-node-packages clean-rust-packages clean-ruby-packages clean-go-packages clean-uv-packages
mise-packages: mise-install node-packages rust-packages ruby-packages go-packages uv-packages

clean-node-packages:
	@tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT; \
	awk 'NF && $$1 !~ /^#/ { pkg=$$1; if (pkg ~ /^@/) { n=split(pkg,a,"@"); if (n > 2) sub(/@[^@]*$$/, "", pkg) } else sub(/@[^@]*$$/, "", pkg); print pkg }' install/npmfile | sort -u > "$$tmp/want"; \
	npm list -g --depth=0 --json 2>/dev/null | node -e 'let s=""; process.stdin.on("data", d => s += d); process.stdin.on("end", () => { const j = s ? JSON.parse(s) : {}; Object.keys(j.dependencies || {}).sort().forEach(p => console.log(p)); });' > "$$tmp/have"; \
	comm -23 "$$tmp/have" "$$tmp/want" | while IFS= read -r pkg; do [ -n "$$pkg" ] && npm uninstall -g "$$pkg"; done

clean-rust-packages:
	@tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT; \
	awk 'NF && $$1 !~ /^#/ { print $$1 }' install/Rustfile | sort -u > "$$tmp/want"; \
	cargo install --list | awk '/^[^[:space:]].*:$$/ { sub(/:.*/, "", $$1); print $$1 }' | sort -u > "$$tmp/have"; \
	comm -23 "$$tmp/have" "$$tmp/want" | while IFS= read -r pkg; do [ -n "$$pkg" ] && cargo uninstall "$$pkg"; done

clean-ruby-packages:
	@tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT; \
	awk 'NF && $$1 !~ /^#/ { print $$1 }' install/Rubyfile | sort -u > "$$tmp/want"; \
	gem list | awk '/\(/ { meta=$$0; sub(/^[^ ]+ \(/, "", meta); sub(/\)$$/, "", meta); if (meta !~ /^default:/) print $$1 }' | sort -u > "$$tmp/have"; \
	comm -23 "$$tmp/have" "$$tmp/want" | while IFS= read -r pkg; do [ -n "$$pkg" ] && gem uninstall -a -x "$$pkg" || true; done

clean-go-packages:
	@tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT; \
	awk 'NF && $$1 !~ /^#/ { n=split($$1,a,"/"); print a[n] }' install/Gofile | sort -u > "$$tmp/want"; \
	bin=$$(go env GOBIN); [ -n "$$bin" ] || bin="$$(go env GOPATH)/bin"; \
	if [ -d "$$bin" ]; then find "$$bin" -maxdepth 1 -type f -perm -111 -exec basename {} \; | sort -u > "$$tmp/have"; else : > "$$tmp/have"; fi; \
	comm -23 "$$tmp/have" "$$tmp/want" | while IFS= read -r pkg; do [ -n "$$pkg" ] && rm -f "$$bin/$$pkg"; done

clean-uv-packages:
	@tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT; \
	awk 'NF && $$1 !~ /^#/ { print $$1 }' install/uv-file | sort -u > "$$tmp/want"; \
	uv tool list 2>/dev/null | awk '/^[[:alnum:]_.-]+ / { print $$1 }' | sort -u > "$$tmp/have"; \
	comm -23 "$$tmp/have" "$$tmp/want" | while IFS= read -r pkg; do [ -n "$$pkg" ] && uv tool uninstall "$$pkg"; done

.PHONY: node-packages
node-packages: clean-node-packages
	npm install -g $(shell cat install/npmfile)
	mise reshim

.PHONY: rust-packages
rust-packages: clean-rust-packages
	cargo install --force $(shell cat install/Rustfile)
	mise reshim

.PHONY: ruby-packages
ruby-packages: clean-ruby-packages
	gem update --system
	gem install $(shell cat install/Rubyfile)
	mise reshim

.PHONY: go-packages
go-packages: clean-go-packages
	cat install/Gofile | xargs -I {} go install {}@latest
	mise reshim

.PHONY: uv-packages
uv-packages: clean-uv-packages
	cat install/uv-file | xargs -I {} uv tool install {}
	mise reshim

.PHONY: mise-install
mise-install:
	mise install
	mise upgrade
	mise reshim

################################################
# Thats better to fully upgrade first before using those package managers

.PHONY: brew-packages
brew-packages:
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

.PHONY: arch-packages
arch-packages:
	if command -v yay >/dev/null 2>&1; then \
			yay -S --needed --noconfirm $(shell cat install/Archfile); \
	fi
################################################
