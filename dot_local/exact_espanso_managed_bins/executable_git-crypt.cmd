@echo off
setlocal
if not defined GIT_CONFIG_GLOBAL set "GIT_CONFIG_GLOBAL=%USERPROFILE%\.gitconfig"
"C:\msys64\usr\bin\git-crypt.exe" %*
