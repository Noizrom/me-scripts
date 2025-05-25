# Enable-RDP.ps1
# Run as Administrator

Write-Host "`n=== Remote Desktop Configuration Script ===`n"

function Log {
    param ($Message)
    Write-Host "[INFO] $Message"
}

function Warn {
    param ($Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function ErrorLog {
    param ($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# 1. Check if RDP is already enabled
$rdpKey = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
$rdpEnabled = (Get-ItemProperty -Path $rdpKey -Name "fDenyTSConnections").fDenyTSConnections

if ($rdpEnabled -eq 0) {
    Log "Remote Desktop is already enabled."
} else {
    Log "Enabling Remote Desktop..."
    Set-ItemProperty -Path $rdpKey -Name "fDenyTSConnections" -Value 0
    Log "Remote Desktop has been enabled."
}

# 2. Check if Firewall Rule exists and is enabled
$rdpRule = Get-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

if ($rdpRule) {
    $enabledRules = $rdpRule | Where-Object { $_.Enabled -eq "True" }
    if ($enabledRules.Count -gt 0) {
        Log "Remote Desktop firewall rule is already enabled."
    } else {
        Log "Enabling Remote Desktop firewall rules..."
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Log "Firewall rules for Remote Desktop have been enabled."
    }
} else {
    Warn "Remote Desktop firewall rules not found. Trying to add and enable manually..."
    New-NetFirewallRule -DisplayName "Remote Desktop (TCP-In)" `
                        -Direction Inbound -Protocol TCP -LocalPort 3389 `
                        -Action Allow -Profile Any
    Log "Manual firewall rule for RDP added."
}

# 3. Check if Network Level Authentication is enabled
$nlaKey = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$nlaEnabled = (Get-ItemProperty -Path $nlaKey -Name "UserAuthentication").UserAuthentication

if ($nlaEnabled -eq 1) {
    Log "Network Level Authentication is already enabled."
} else {
    Log "Enabling Network Level Authentication..."
    Set-ItemProperty -Path $nlaKey -Name "UserAuthentication" -Value 1
    Log "NLA has been enabled."
}

# 4. Check if RDP service is running
$service = Get-Service -Name TermService -ErrorAction SilentlyContinue
if ($null -eq $service) {
    ErrorLog "Remote Desktop Services (TermService) not found!"
} elseif ($service.Status -ne 'Running') {
    Log "Starting Remote Desktop Services..."
    Start-Service -Name TermService
    Log "Remote Desktop Services started."
} else {
    Log "Remote Desktop Services are already running."
}

Write-Host "`n=== Remote Desktop Setup Complete ===`n"
