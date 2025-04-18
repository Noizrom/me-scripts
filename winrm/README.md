# 🖥️ WinRM Remote Access Enabler

This folder contains scripts that allow you to enable or disable PowerShell Remoting (WinRM) on a remote Windows PC — perfect for terminal access when SSH is broken or unavailable.

---

## 📁 Location

These scripts live under:

```
scripts/
└── winrm/
    ├── activate.ps1      # Enables remote PowerShell access
    ├── deactivate.ps1    # Disables and re-secures access
    └── README.md
```

---

## 🚀 Usage Overview

You’ll serve this folder via HTTP and expose it with Tailscale Funnel for easy remote execution.

---

### 🔌 Step 1: Serve This Folder Locally

On your machine that has the scripts:

```bash
cd scripts
python -m http.server 8000
```

Then expose it via Tailscale:

```bash
tailscale funnel 8000
```

> Example URL:  
> `https://dellpichu.anoa-tone.ts.net/winrm/activate.ps1`

---

### 💻 Step 2: Activate WinRM on the Remote PC

From the target PC, open **PowerShell as Administrator** and run:

```powershell
iwr -useb https://dellpichu.anoa-tone.ts.net/winrm/activate.ps1 | iex
```

🟢 This script:
- Enables WinRM
- Allows basic auth and blank passwords
- Displays connection instructions (including IP and username)

---

### 🔁 Connect from Client PC

On your **client machine**, add the remote PC to your TrustedHosts (if not in domain):

```powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value <REMOTE_IP>
```

Then connect:

```powershell
Enter-PSSession -ComputerName <REMOTE_IP> -Credential <COMPUTERNAME\USERNAME>
```

Press **Enter** when prompted for a password (if the account has none).

---

### 🔒 Step 3: Deactivate When Done

To revert everything and secure the PC again, run this on the remote PC:

```powershell
iwr -useb https://dellpichu.anoa-tone.ts.net/winrm/deactivate.ps1 | iex
```

---

## ⚠️ Security Notes

- Blank password logins are allowed temporarily.
- For local/workgroup use only — not recommended over public networks.
- Use `deactivate.ps1` when you're done to lock it back down.

---

## ✨ Tip

You can share the one-liner `iwr` command via chat/email for quick copy-paste execution.
