@echo off
setlocal
cd /d %~dp0
set "APP_URL=http://127.0.0.1:8016"
set "PORT=8016"
set "PORT_IN_USE="
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /r /c:":%PORT% .*LISTENING"') do (
  set "PORT_IN_USE=1"
  goto :open_only
)

echo Starting auto-check server...
start "" /B main.exe
timeout /t 2 /nobreak >nul

:open_only
echo Opening browser: %APP_URL%
start "" "%APP_URL%"
