# LogonWatchdog 🛡️

A lightweight PowerShell monitoring tool that sends real-time Discord alerts for server logins, RDP reconnections, and workstation unlocks.

## Why use this?
* **RDP & Session Aware**: Detects physical logons, RDP reconnections, and lock/unlock events.
* **Audit Trail**: Keeps a local text log in `C:\LogonWatchdog\AccessLog.txt` even if the internet is down.
* **Non-Intrusive**: Designed to run under the `Users` group with standard privileges to avoid UAC admin pop-ups for users.
* **Clean Organization**: Installs into a dedicated `\LogonWatchdog` folder in Task Scheduler to keep your system tasks organized.

---

## 🚀 Installation

### Step 1: Create your Discord Webhook
1.  Open Discord and go to **Server Settings** > **Integrations**.
2.  Click **Webhooks** > **New Webhook**.
3.  Name it "Watchdog" and copy the **Webhook URL**.
4.  To get a Role ID to ping, type `\@RoleName` in your Discord chat; copy the numeric ID.

### Step 2: Customize your Script
1.  Open `LogonWatchdog.ps1` in a text editor.
2.  Paste your **Webhook URL** into `$DiscordUrl`.
3.  Paste your **Role ID** into `$RoleID`.
4.  (Optional) Customize the "Ignore" list or the "SilentUser" logic.

### Step 3: Run the Automated Setup
1.  Place `LogonWatchdog.ps1` and `setup.bat` in the same folder.
2.  **Right-click `setup.bat` and select "Run as Administrator"**.
3.  The setup will automatically:
    * Create a permanent folder at `C:\LogonWatchdog`.
    * Copy the script to that folder.
    * Register the base task in **Windows Task Scheduler**.
    * Open **Task Scheduler** and a **Notepad Instruction Slip** to help you finish the multi-trigger setup.

---

## ⚙️ Finalizing Triggers (Guided Setup)
To ensure full coverage (RDP, Local, and Unlocks), follow the instructions in the Notepad window that pops up during setup:

1.  In Task Scheduler, open the **LogonWatchdog** folder on the left sidebar.
2.  Double-click **WatchdogSentry** and go to the **Triggers** tab.
3.  **Add Remote/Local Connections**:
    * Click **New...**
    * Set **'Begin the task'** to **'On connection to user session'**.
    * Select **'Remote computer'** for RDP alerts.
    * Repeat these steps to add a second trigger for **'Local computer'** for physical logins.
4.  **Add Lock/Unlock Alerts**:
    * Click **New...**
    * Set **'Begin the task'** to **'On workstation unlock'**.
    * (Optional) Click **New...** and set 'Begin the task' to **'On workstation lock'**.
5.  Click **OK** to save and close the task.



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