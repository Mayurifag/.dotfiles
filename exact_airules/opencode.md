# OpenCode

- Use V2 `provider/model#variant` for agent reasoning profiles, not direct provider request fields.
- After config/agent/skill/plugin/MCP changes, tell the user to restart OpenCode (config loads at startup). Verify
  yourself where possible; if manual checks remain, include a concise continuation prompt for the new session.
- Verify config discovery, plugin factory execution, and hook execution separately.
- Inspect inventories/rendered config, auth, and service files only through explicit non-secret key allowlists; never
  dump secret-bearing files or search them broadly.
- Pin the live mise version before staging major upgrades; installs can move `latest` aliases before config applies.
