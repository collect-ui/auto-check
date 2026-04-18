@echo off
setlocal
cd /d %~dp0
echo Starting auto-check server...
main.exe
pause
