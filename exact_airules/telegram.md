# Telegram

- Read `~/airules/passwords.md` before accessing credentials. Keep credentials and private account, bot, and channel
  metadata in KeePassXC; rules contain only lookup URLs and field schemas. Load values into memory, not plaintext files,
  command arguments, or environment variables. Do not print identifiers or links unless the user requests them.
- Check the account access below before asking the user to perform Telegram setup manually. Use it for requested
  Telegram tasks, including creating channels and managing bots through the verified `@BotFather` account.
- KeePassXC matches Telegram URLs broadly. Use the unique lookup URLs below, not `t.me` or `telegram.org`. These
  `.invalid` URLs identify vault entries, not network endpoints. Require exactly one match for each lookup.

## Secondary Account and Telethon

- KeePassXC URL: `https://telegram-twink.invalid/`. The password field contains JSON with `api_id`, `api_hash`,
  `session_string`, `user_id`, and `username`. The session grants account access; treat it as a password.
- Use the existing `~/Code/telegram_media_downloader/.venv/bin/python` runtime (`.venv/Scripts/python.exe` on Windows).
  It provides Telethon. Run one-off scripts with `-B` to avoid bytecode artifacts; no always-on client is needed.
- Capture `kpxc-cli show <URL> -j -p` inside the script, never directly into tool output. Decode its successive JSON
  objects, require one entry, and parse its `password` as JSON. Keep all credential values in process memory.
- Construct `TelegramClient(StringSession(session_string), api_id, api_hash)`, importing `StringSession` from
  `telethon.sessions`. Use `connect()`, then `get_me()` and require its ID to match the vault's `user_id` before reading
  or changing data. Do not use `start()` to trigger interactive login. Always `disconnect()` in `finally`; never
  `log_out()` the shared session.
- Set `receive_updates=False` unless the task needs updates, such as a BotFather conversation. String sessions do not
  retain entity caches between runs: resolve usernames or load the requested entity through `iter_dialogs()` for numeric
  IDs.
- Never create plaintext `.session` files or export the session to arguments, environment variables, or logs. Do not
  access or change the downloader's legacy `config.yaml` or `.session` for general account tasks.
- If authorization expires, stop and arrange direct user authentication; never ask for login codes or 2FA passwords in
  chat. Respect Telegram rate limits. Restrict reads and changes to the user's request.

## Notification Channel

- KeePassXC URL `https://telegram-notification-bot.invalid/` stores the raw Bot API token in the password field; the
  username field identifies the bot.
- Destination entry: `https://telegram-notifications.invalid/`. Its password field is JSON with `chat_id`,
  `channel_title`, `channel_link`, `owner_user_id`, `bot_username`, and `bot_entry_url`. Load and check it before
  sending.
- Configure only requested sources and events; do not enable notifications for every agent task by default.
- Prefer built-in Telegram integrations when they meet the credential-storage requirement. Ask before copying tokens
  into another service's secret store. Otherwise use the Telegram Bot API; outbound alerts need no webhook or daemon.
- Send alerts with Bot API `sendMessage` over HTTPS. Build token-bearing URLs only inside the process; sanitize network
  errors because they can contain the token. Use the account API for account management, not routine bot alerts.
- Give the bot only posting permission; Telegram also grants the implicit `other` management flag. Do not grant
  member-management or other optional admin rights.
- Keep alerts short and identify the source and event. Exclude secrets and sensitive payloads: Telegram bot messages are
  not end-to-end encrypted. Verify new integrations with one clearly labeled, silent test alert to the confirmed
  channel.
