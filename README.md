# LogonWatchdog 🛡️

A lightweight PowerShell monitoring tool that sends real-time Discord alerts when someone logs into your server or reconnects via RDP.

## Why use this?
* **RDP Aware:** Detects both physical logons and RDP reconnections.
* **Audit Trail:** Keeps a local text log even if the internet is down.
* **Reliable:** Designed to run under the `Users` group so it triggers for all user levels.
* **Customizable:** Easily ignore system accounts or silence specific users for demos or known accounts.

---

## 🚀 Installation

### Step 1: Create your Discord Webhook
1. Open Discord and go to **Server Settings** > **Integrations**.
2. Click **Webhooks** > **New Webhook**.
3. Name it "Watchdog" and copy the **Webhook URL**.
4. To get a Role ID to ping, type `\@RoleName` in your Discord chat; copy the numbers inside the brackets.

### Step 2: Customize your Script
1. Open `LogonWatchdog.ps1` in a text editor.
2. Paste your Webhook URL into `$DiscordUrl`.
3. Paste your Role ID into `$RoleID`.
4. (Optional) Add specific usernames to the "Ignore" list or the "Silent" list.

### Step 3: Run the Setup
1. Place `LogonWatchdog.ps1` and `setup.bat` in the same folder.
2. **Right-click `setup.bat` and select "Run as Administrator".**
3. The tool will:
   - Create a permanent folder at `C:\LogonWatchdog`.
   - Copy the script there to prevent accidental deletion.
   - Register the task in **Windows Task Scheduler** to run on every login.

---

## ⚙️ Manual Configuration (If not using .bat)
If you prefer to set it up manually via Task Scheduler:
* **General:** Name: `LogonWatchdog` | User: `Users` | **Run with highest privileges**.
* **Triggers:** Add `At log on` **AND** `On connection to user session`.
* **Actions:** * **Program/script:** `powershell.exe`
    * **Add arguments:** `-ExecutionPolicy Bypass -File "C:\LogonWatchdog\LogonWatchdog.ps1"`

---

## 🛠️ Customization Logic
The script includes a logic gate to handle different types of users. This allows you to log specific accounts without "pinging" your phone or desktop every time they log in.

```powershell
if ($User -eq "SilentUser") {
    # Logs to Discord but skips the @Role ping
    $Payload = @{ content = "[SILENT LOG] User: $Domain\$User logged into $Computer (No Ping)" }
} else {
    # Default: Everyone else triggers a Role Ping
    $Ping = "<@&$RoleID>"
    $Payload = @{ content = "$Ping [LOGIN ALERT] User: $Domain\$User logged into $Computer at $Time" }
}
