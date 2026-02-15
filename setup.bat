@echo off
:: Check for Admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Admin rights confirmed.
) else (
    echo [ERROR] Please run this .bat file as Administrator.
    pause
    exit
)

:: Configuration
set "ScriptFolder=C:\LogonWatchdog"
set "ScriptName=LogonWatchdog.ps1"

:: 1. Create the folder if it doesn't exist
if not exist "%ScriptFolder%" mkdir "%ScriptFolder%"

:: 2. Copy the script to the folder (assumes .ps1 is in the same folder as this .bat)
if exist "%ScriptName%" (
    copy "%ScriptName%" "%ScriptFolder%\" /Y
) else (
    echo [ERROR] %ScriptName% not found in this folder!
    pause
    exit
)

:: 3. Create the Scheduled Task
echo [STEP] Creating Scheduled Task...
schtasks /create /tn "LogonWatchdog" /tr "powershell.exe -ExecutionPolicy Bypass -File %ScriptFolder%\%ScriptName%" /sc onlogon /rl highest /ru "Users" /f

echo.
echo [DONE] Watchdog is installed to %ScriptFolder%
echo [DONE] Task Scheduler entry 'LogonWatchdog' created successfully.
pause