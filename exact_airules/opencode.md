# OpenCode

- Select agent reasoning profiles with V2 model references `provider/model#variant`, not direct provider request fields.
- After changing OpenCode config, agents, skills, plugins, or MCP setup, tell user to restart OpenCode. Config is loaded at startup.
- When telling the user to restart OpenCode, include a concise prompt he can paste into the new session to continue if fixed bug or feature still needs check manually.
- Check yourself if it is possible, such as inline launching a new OpenCode session.
- Distinguish config discovery, plugin factory execution, and hook execution. Evidence of one does not verify the others.
- Inspect inventories and rendered OpenCode config, auth, and service files through explicit non-secret key allowlists; never dump whole secret-bearing files or search their contents broadly.
- Pin the live mise tool version before staging a major upgrade; installing another version can move `latest` aliases before configuration is applied.
