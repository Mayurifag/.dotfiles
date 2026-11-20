# Windows

- Use `pwsh.exe` (PowerShell 7), never `powershell.exe` (PowerShell 5).

## App Execution

- For every app launch, including CLI tools, background agents, services, and startup tasks, check the intended user and
  execution session; do not blindly inherit the agent shell's context.
- Apps that need the user's desktop, input, clipboard, tray, or interactive prompts must run in that user's interactive
  session, not session 0. Identify the session; do not assume its ID is 1. Services and headless commands can run in
  session 0 when their task does not require interactive access.
- Verify the actual user/session and task result before reporting success: command output, service/agent health, or
  expected UI state as applicable. A running process alone does not prove the requested function works.
