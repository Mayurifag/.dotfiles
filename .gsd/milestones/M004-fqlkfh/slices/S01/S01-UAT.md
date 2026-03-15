# S01: OS-gate conditional-launcher in mise config — UAT

**Milestone:** M004-fqlkfh
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: The deliverable is a chezmoi template file; correctness is fully verifiable by inspecting rendered output and running a dry-run — no runtime deployment needed.

## Preconditions

- Running on Linux (chezmoi OS = `linux`)
- `dot_config/mise/config.toml.tmpl` exists in the chezmoi source directory
- `dot_config/mise/config.toml` (plain) does not exist
- `chezmoi` is installed and configured

## Smoke Test

```
chezmoi cat ~/.config/mise/config.toml | grep conditional-launcher
```

Expected: one line — `"github:Mayurifag/conditional-launcher" = "latest"`

---

## Test Cases

### 1. Template file exists, old plain file removed

1. Run: `ls ~/.local/share/chezmoi/dot_config/mise/config.toml.tmpl`
2. Run: `ls ~/.local/share/chezmoi/dot_config/mise/config.toml 2>/dev/null`
3. **Expected:** First command exits 0 (file exists). Second command exits non-zero / produces no output (file absent).

### 2. Rendered TOML on Linux includes conditional-launcher

1. Run: `chezmoi cat ~/.config/mise/config.toml | grep -c conditional-launcher`
2. **Expected:** `1`

### 3. All other 11 tools present in rendered TOML

1. Run: `chezmoi cat ~/.config/mise/config.toml`
2. **Expected:** Output contains exactly these entries (order may vary):
   ```
   node = "lts"
   go = "latest"
   python = "latest"
   rust = "latest"
   ruby = "latest"
   usage = "latest"
   uv = "latest"
   bun = "latest"
   chezmoi = "latest"
   claude-code = "latest"
   "github:Mayurifag/yawn" = "latest"
   "github:Mayurifag/conditional-launcher" = "latest"
   ```
3. **Expected:** 13 lines total (1 section header + 12 tool lines); no blank lines inside `[tools]`.

### 4. yawn tool still present

1. Run: `chezmoi cat ~/.config/mise/config.toml | grep -c yawn`
2. **Expected:** `1`

### 5. Rendered TOML is syntactically valid TOML

1. Run: `chezmoi cat ~/.config/mise/config.toml | python3 -c "import sys, tomllib; tomllib.loads(sys.stdin.read()); print('valid')"`
2. **Expected:** Prints `valid` with exit code 0.
   - Alternative (no python3): `chezmoi cat ~/.config/mise/config.toml | grep -E '^[[:space:]]*$'` should return no matches (no blank lines).

### 6. chezmoi apply --dry-run produces no errors

1. Run: `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l`
2. **Expected:** `0`

---

## Edge Cases

### Simulating non-Linux: conditional block omitted

Since we are on Linux, directly inspect the template source to confirm the conditional wraps only `conditional-launcher`:

1. Run: `grep -n 'conditional-launcher\|if eq\|end' ~/.local/share/chezmoi/dot_config/mise/config.toml.tmpl`
2. **Expected:** Output shows exactly three lines — the `{{- if eq .chezmoi.os "linux" }}` guard, the `conditional-launcher` entry, and the `{{- end }}` closer — with no other tool lines inside the conditional block.

### No blank lines injected by template rendering

1. Run: `chezmoi cat ~/.config/mise/config.toml | grep -c '^$'`
2. **Expected:** `0` — trim markers (`{{- ... }}`) suppress blank lines that would otherwise appear from the conditional block.

---

## Failure Signals

- `chezmoi cat ~/.config/mise/config.toml | grep -c conditional-launcher` returns `0` → conditional block missing or wrong OS guard
- `chezmoi cat ~/.config/mise/config.toml | grep -c '^$'` returns `>0` → blank lines in rendered TOML; trim markers not applied
- `chezmoi apply --dry-run --force` emits template parse errors → template syntax error in `.toml.tmpl`
- `ls dot_config/mise/config.toml` succeeds → old plain file not removed; chezmoi will use the wrong source file
- Rendered TOML fails `tomllib.loads()` → invalid TOML (merged lines, stray braces, etc.)

## Requirements Proved By This UAT

- none (this is a maintenance/correctness fix; no active requirements are tracked)

## Not Proven By This UAT

- Actual behaviour on a Windows machine — the non-Linux branch (`conditional-launcher` absent) is verified by inspecting the template source, not by rendering on Windows.
- `mise install` succeeding after `chezmoi apply` — operational verification is out of scope for this UAT.

## Notes for Tester

- The key test is Test Case 2 (conditional-launcher present) + Test Case 6 (dry-run clean). The others are belt-and-suspenders.
- `chezmoi cat <source-path>` does NOT work for `.tmpl` files — always use the target path `~/.config/mise/config.toml`.
- If running on a non-Linux OS, Test Case 2 will return `0` (correct behaviour — the conditional omits the line). Test Case 3 will show 12 lines instead of 13. Both are expected.
