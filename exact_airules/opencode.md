# OpenCode

- Use V2 `provider/model#variant` for agent reasoning profiles, not direct provider request fields.
- Use the existing `build` agent and a skill for specialized workflows; add visible primary agents only when explicitly
  requested.
- OpenCode V2 reloads watched config automatically; verify effective behavior and use `/reload` if needed. Suggest a
  restart only for a diagnosed lifecycle issue or changes to unwatched dependencies; avoid interrupting active work. If
  manual checks remain, include a concise continuation prompt.
- Verify config discovery, plugin factory execution, and hook execution separately.
- Treat `permissions` as the tool-access boundary. Add narrow `ask`/`deny` rules for consequential actions and preserve
  required workflows with specific exceptions; test effective permissions after changes. Prompts are guidance, not
  enforcement, and `--auto` approves requests that are not explicitly denied.
- Inspect inventories/rendered config, auth, and service files only through explicit non-secret key allowlists; never
  dump secret-bearing files or search them broadly.
- Pin the live mise version before staging major upgrades; installs can move `latest` aliases before config applies.
