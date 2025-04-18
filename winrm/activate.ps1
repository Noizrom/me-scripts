<#
.SYNOPSIS
    Enables PowerShell Remoting via WinRM for local/workgroup networks.

.DESCRIPTION
    This script configures the target PC to allow remote PowerShell access from other computers
    in the same network — even if the account has no password. It:
      - Enables WinRM (PowerShell Remoting)
      - Allows unencrypted HTTP traffic
      - Enables Basic authentication
      - Adds firewall rule to allow traffic
      - Disables the blank password restriction
      - Shows connection instructions and current IP

.NOTES
    - Must be run as Administrator.
    - Best used in trusted (local) networks only.
    - For clients not in a domain, "TrustedHosts" must be set on the connecting PC.

.AUTHOR
    Custom ChatGPT script — 2025
#>

# Elevate check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit
}

Write-Host "`n🔧 Enabling WinRM and setting up remote access for local network..." -ForegroundColor Cyan

# Enable PowerShell Remoting
Enable-PSRemoting -Force

# Allow unencrypted traffic for non-domain authentication
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Enable Basic authentication (used with local accounts)
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true

# Enable inbound WinRM HTTP traffic
Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -Enabled True

# Allow blank password logins for remote sessions
Write-Host "`n🔐 Allowing blank passwords for remote logon..." -ForegroundColor Yellow
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 0 -PropertyType DWord -Force | Out-Null

# Get useful connection info
$CurrentUser = "$env:COMPUTERNAME\$env:USERNAME"
$IP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notmatch '^169\.' -and $_.IPAddress -ne '127.0.0.1' -and $_.InterfaceAlias -notlike '*vEthernet*'
} | Select-Object -First 1).IPAddress

# Final instructions
Write-Host "`n✅ WinRM is enabled and ready!" -ForegroundColor Green
Write-Host "`n📌 To connect from another computer (client):" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"
Write-Host "1. Add this IP to TrustedHosts on the client PC:"
Write-Host "   Set-Item WSMan:\localhost\Client\TrustedHosts -Value '$IP'" -ForegroundColor Yellow
Write-Host "`n2. Connect using PowerShell:" -ForegroundColor Cyan
Write-Host "   Enter-PSSession -ComputerName $IP -Credential $CurrentUser" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"

Write-Host "`nℹ️  If prompted for password and you don't have one, just press Enter." -ForegroundColor Gray
