# --- CONFIGURATION ---
# Replace the URL and ID below with your own data
$WatchdogFolder = "C:\LogonWatchdog"
$LogFile        = "$WatchdogFolder\AccessLog.txt"
$DiscordUrl     = "YOUR_DISCORD_WEBHOOK_URL_HERE"
$RoleID         = "YOUR_ROLE_ID_HERE"

# --- ENSURE FOLDER EXISTS ---
# This prevents the script from crashing if the log folder is missing
if (!(Test-Path $WatchdogFolder)) { 
    New-Item -ItemType Directory -Path $WatchdogFolder 
}

# --- GET LOGIN DATA ---
$User = $env:USERNAME
$Domain = $env:USERDOMAIN
$Computer = $env:COMPUTERNAME
$Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# --- IGNORE SYSTEM ACCOUNTS ---
# Prevents spam from background Windows services
if ($User -match "SYSTEM" -or $User -match "NETWORK SERVICE" -or $User -match "LOCAL SERVICE") { 
    exit 
}

# --- LOG AND NOTIFY ---

# Records the event to the local file for audit purposes
$LogEntry = "[$Time] LOGIN DETECTED: $Domain\$User"
Add-Content -Path $LogFile -Value $LogEntry

if ($DiscordUrl -ne "YOUR_DISCORD_WEBHOOK_URL_HERE") {
    # LOGIC GATE:
    # If the user is 'SilentUser', we send a log without a ping.
    # For everyone else, we trigger the Discord Role ping.
    
    if ($User -eq "SilentUser") {
        $Payload = @{
            content = "[SILENT LOG] User: $Domain\$User logged into $Computer (No Ping)"
        }
    } else {
        $Ping = "<@&$RoleID>"
        $Payload = @{
            content = "$Ping [LOGIN ALERT] User: $Domain\$User logged into $Computer at $Time"
        }
    }

    # Send data to Discord
    Invoke-RestMethod -Uri $DiscordUrl -Method Post -Body ($Payload | ConvertTo-Json) -ContentType 'application/json'
}