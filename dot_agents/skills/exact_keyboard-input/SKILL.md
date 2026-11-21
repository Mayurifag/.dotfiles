---
name: keyboard-input
description: Configure or troubleshoot keyboard input languages, layouts, IMEs, or per-app language switching.
---

# Keyboard Input

- On Windows, IME Mode Persistence (`mangokingTW.ImeModePersistence`) supports per-app input-language bindings. Check
  its existing rules before adding custom automation.
- Rules are stored in `HKCU:\Software\ImeModePersistence\Rules`; preserve other bindings. Vicinae's binding is managed
  by `~/.local/share/chezmoi/windows/ime-mode-persistence.reg`.
