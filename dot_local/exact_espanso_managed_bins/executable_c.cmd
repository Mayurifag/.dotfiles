@echo off
setlocal
set "config_home=%XDG_CONFIG_HOME%"
if not defined config_home set "config_home=%USERPROFILE%\.config"

if not exist "%config_home%\opencode\plugins\caveman\plugin.js" (
  mise exec -- npx --yes github:JuliusBrussee/caveman -- --only opencode --minimal --non-interactive --no-color --force || exit /b
)

"%LOCALAPPDATA%\mise\shims\opencode.exe" %*
