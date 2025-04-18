<#
.SYNOPSIS
Lists applications installed on the old Windows drive (F:).
#>

$OldProgramFiles = "F:\Program Files*", "F:\ProgramData"
$OutputFile = "C:\OldInstalledApps.txt"

# Find .exe files in common install locations
$Apps = Get-ChildItem -Path $OldProgramFiles -Recurse -ErrorAction SilentlyContinue |
Where-Object { $_.Name -match "unins.*\.exe|install\.exe|setup\.exe" } |
Select-Object FullName |
Sort-Object FullName -Unique

# Extract application names
$AppList = $Apps | ForEach-Object {
    $_.FullName -replace "^.*\\Program Files.*?\\", "" -replace "\\unins.*\.exe$", ""
} | Sort-Object -Unique

# Save to file
$AppList | Out-File -FilePath $OutputFile
Write-Host "Saved app list to $OutputFile"