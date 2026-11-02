# OpenCode

- Use V2 `provider/model#variant` for agent reasoning profiles, not direct provider request fields.
- OpenCode V2 reloads watched config automatically; verify effective behavior and use `/reload` if needed. Suggest a
  restart only for a diagnosed lifecycle issue or changes to unwatched dependencies; avoid interrupting active work. If
  manual checks remain, include a concise continuation prompt.
- Verify config discovery, plugin factory execution, and hook execution separately.
- Inspect inventories/rendered config, auth, and service files only through explicit non-secret key allowlists; never
  dump secret-bearing files or search them broadly.
- Pin the live mise version before staging major upgrades; installs can move `latest` aliases before config applies.
