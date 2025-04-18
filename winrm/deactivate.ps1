<#
.SYNOPSIS
    Disables WinRM and reverts all settings made by the enable script.

.DESCRIPTION
    This script undoes all the changes made by the enable script:
      - Disables PowerShell Remoting
      - Disables unencrypted traffic and Basic auth
      - Disables WinRM firewall rule
      - Re-enables the blank password restriction

.NOTES
    - Must be run as Administrator.
    - Use this script to return the system to a secure default state.

.AUTHOR
    Custom ChatGPT script — 2025
#>

# Elevate check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit
}

Write-Host "`n🛑 Disabling WinRM and reverting configuration..." -ForegroundColor Cyan

# Disable PowerShell Remoting
Disable-PSRemoting -Force

# Revert unencrypted and basic auth settings
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $false

# Disable WinRM firewall rule
Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -Enabled False

# Re-enable blank password restriction
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 1

Write-Host "`n✅ Remote access has been disabled and system is secured." -ForegroundColor Green
Write-Host "`n🔒 All settings reverted to default." -ForegroundColor Yellow