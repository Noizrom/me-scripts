<#
.SYNOPSIS
Migrates user data with resume support, no retries, and prioritized folders
#>

param(
    [string]$SourcePath = "F:\Users\Admin",
    [string]$DestinationPath = "C:\Users\balagtas",
    [string]$LogPath = "C:\MigrationLog.txt",
    [string]$CompletedFile = "C:\CompletedFolders.log"
)

# Prioritize non-AppData folders first
$PriorityFolders = @(
    "Documents",
    "Desktop",
    "Downloads",
    "Pictures",
    "Music",
    "Videos",
    "Favorites",
    "Contacts",
    "Saved Games"
)

$AppDataFolders = @(
    "AppData\Roaming",
    "AppData\Local"
)

$AllFolders = $PriorityFolders + $AppDataFolders
$ExcludeFileTypes = @("*.exe", "*.dll", "*.sys", "*.tmp", "*.log", "*.bak")
$ExcludeFolders = @("AppData\Local\Temp", "AppData\Local\Cache")

# Load completed folders from previous runs
$Completed = @()
if (Test-Path $CompletedFile) {
    $Completed = Get-Content $CompletedFile
}

# Initialize logging
function Log-Message {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp][$Level] $Message"
    Write-Host $LogEntry
    $LogEntry | Out-File -FilePath $LogPath -Append
}

try {
    # Validate paths
    if (-not (Test-Path $SourcePath)) {
        throw "Source path not found: $SourcePath"
    }
    if (-not (Test-Path $DestinationPath)) {
        New-Item -Path $DestinationPath -ItemType Directory | Out-Null
    }

    # Configure Robocopy for no retries and skip existing
    $RobocopyArgs = @(
        "/E", # Copy subdirectories
        "/COPY:DAT", # Copy Data, Attributes, Timestamps
        "/XO", # eXclude Older files (skip existing)
        "/R:0", # No retries
        "/W:0", # No wait between retries
        "/NP", # No progress display
        "/NFL", # No file list logging
        "/NDL", # No directory list logging
        "/XF", $ExcludeFileTypes,
        "/XD", $ExcludeFolders
    )

    # Process folders
    foreach ($Folder in $AllFolders) {
        if ($Completed -contains $Folder) {
            Log-Message "Skipping already completed folder: $Folder"
            continue
        }

        $Source = Join-Path -Path $SourcePath -ChildPath $Folder
        $Destination = Join-Path -Path $DestinationPath -ChildPath $Folder
        
        if (Test-Path $Source) {
            Log-Message "Processing: $Folder"
            
            # Create destination if needed
            if (-not (Test-Path $Destination)) {
                New-Item -Path $Destination -ItemType Directory -Force | Out-Null
            }

            # Run Robocopy and capture output
            $Result = & robocopy $Source $Destination $RobocopyArgs
            
            # Handle results
            if ($LASTEXITCODE -eq 0) {
                Log-Message "Completed: $Folder (No files needed copying)"
            }
            elseif ($LASTEXITCODE -eq 1) {
                Log-Message "Completed: $Folder (Files copied successfully)"
            }
            elseif ($LASTEXITCODE -ge 2 -and $LASTEXITCODE -le 7) {
                Log-Message "Partial completion: $Folder (Some files skipped, exit code $LASTEXITCODE)" -Level "WARNING"
            }
            else {
                Log-Message "Critical error: $Folder (Robocopy exit code $LASTEXITCODE)" -Level "ERROR"
            }

            # Mark as completed regardless of success
            $Folder | Out-File -FilePath $CompletedFile -Append
            $Completed += $Folder
        }
        else {
            Log-Message "Source folder missing: $Folder" -Level "WARNING"
            $Folder | Out-File -FilePath $CompletedFile -Append
            $Completed += $Folder
        }
    }

    Log-Message "Migration session completed. Run again to catch any missed files." -Level "INFO"
}
catch {
    Log-Message "Fatal error: $_" -Level "ERROR"
    exit 1
}