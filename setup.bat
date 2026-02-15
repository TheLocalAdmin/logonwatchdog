@echo off
cd /d "%~dp0"

:: Check for Admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this .bat file as Administrator to install.
    pause
    exit
)

:: Configuration
set "ScriptFolder=C:\LogonWatchdog"
set "ScriptName=LogonWatchdog.ps1"
set "TaskFolder=\LogonWatchdog"
set "TaskName=WatchdogSentry"

:: 1. Create Folder and Copy Script
if not exist "%ScriptFolder%" mkdir "%ScriptFolder%"
copy "%ScriptName%" "%ScriptFolder%\" /Y

:: 2. Create the base task (Logon trigger)
echo [STEP] Creating folder and base task...
schtasks /create /tn "%TaskFolder%\%TaskName%" /tr "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%ScriptFolder%\%ScriptName%\"" /sc onlogon /ru "Users" /f

:: 3. Create the 'Cheat Sheet' for ALL connection types
echo LOGON WATCHDOG - FINAL STEPS: > "%temp%\Watchdog_Help.txt"
echo ----------------------------------------------------------- >> "%temp%\Watchdog_Help.txt"
echo The base 'Logon' alert is set. Follow these steps to >> "%temp%\Watchdog_Help.txt"
echo add RDP, Local, and Unlock alerts: >> "%temp%\Watchdog_Help.txt"
echo. >> "%temp%\Watchdog_Help.txt"
echo 1. In Task Scheduler (LEFT SIDE), open 'LogonWatchdog'. >> "%temp%\Watchdog_Help.txt"
echo 2. Double-click '%TaskName%' -> Go to 'Triggers' tab. >> "%temp%\Watchdog_Help.txt"
echo. >> "%temp%\Watchdog_Help.txt"
echo 3. ADD REMOTE/LOCAL CONNECTIONS: >> "%temp%\Watchdog_Help.txt"
echo    - Click 'New' -> Set 'Begin task' to 'On connection to user session'. >> "%temp%\Watchdog_Help.txt"
echo    - By default this is 'Remote' (RDP). >> "%temp%\Watchdog_Help.txt"
echo    - Repeat this step and select 'Local computer' for physical logins. >> "%temp%\Watchdog_Help.txt"
echo. >> "%temp%\Watchdog_Help.txt"
echo 4. ADD LOCK/UNLOCK ALERTS: >> "%temp%\Watchdog_Help.txt"
echo    - Click 'New' -> Set 'Begin task' to 'On workstation unlock'. >> "%temp%\Watchdog_Help.txt"
echo    - Click 'New' -> Set 'Begin task' to 'On workstation lock' (Optional). >> "%temp%\Watchdog_Help.txt"
echo ----------------------------------------------------------- >> "%temp%\Watchdog_Help.txt"
echo 5. Click OK, then OK again to save and close. >> "%temp%\Watchdog_Help.txt"

echo.
echo [DONE] Base setup complete.
echo [ACTION] Opening Task Scheduler and Instructions...

start taskschd.msc
start notepad.exe "%temp%\Watchdog_Help.txt"

echo Press any key HERE after you have saved your triggers in Task Scheduler.
pause
del "%temp%\Watchdog_Help.txt"