# --- CONFIGURATION ---
$LogFile       = "C:\Scripts\AccessLog.txt"
$DiscordUrl    = "YOUR_DISCORD_WEBHOOK_URL_HERE"
$RoleID        = "YOUR_ROLE_ID_TO_PING_HERE"

# --- GET LOGIN DATA ---
$User = $env:USERNAME
$Domain = $env:USERDOMAIN
$Computer = $env:COMPUTERNAME
$Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# --- IGNORE SYSTEM ACCOUNTS ---
if ($User -match "SYSTEM" -or $User -match "NETWORK SERVICE" -or $User -match "LOCAL SERVICE") { exit }

# --- LOG AND NOTIFY ---

# This always records to the local file regardless of the user
$LogEntry = "[$Time] LOGIN DETECTED: $Domain\$User"
Add-Content -Path $LogFile -Value $LogEntry

if ($DiscordUrl -ne "") {
    # CUSTOMIZATION DEMO:
    # If the user is 'SilentUser', we send a silent log without a ping.
    # For everyone else, we trigger the Discord Role ping.
    
    if ($User -eq "SilentUser") {
        # Send to Discord WITHOUT the ping
        $Payload = @{
            content = "[SILENT LOG] User: $Domain\$User logged into $Computer (No Ping)"
        }
    } else {
        # Everyone else gets the Role Ping
        $Ping = "<@&$RoleID>"
        $Payload = @{
            content = "$Ping [LOGIN ALERT] User: $Domain\$User logged into $Computer at $Time"
        }
    }

    Invoke-RestMethod -Uri $DiscordUrl -Method Post -Body ($Payload | ConvertTo-Json) -ContentType 'application/json'
}