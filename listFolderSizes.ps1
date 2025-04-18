$BaseFolder = Get-ChildItem '.'
$Results = @()
$TotalSize = 0
$TotalFolders = $BaseFolder.Count
$CurrentFolder = 0

foreach ($f in $BaseFolder) {
    $CurrentFolder++
    Write-Progress -Activity "Calculating folder sizes" -Status "$CurrentFolder of $TotalFolders processed" -PercentComplete (($CurrentFolder / $TotalFolders) * 100)

    if ($f.PSIsContainer -eq $true) {
        $Size = Get-ChildItem $f -Recurse -Force | Measure-Object -Property Length -Sum
    }
    else {
        $Size = Get-ChildItem $f | Measure-Object -Property Length -Sum
    }

    $TotalSize += $Size.Sum

    if ($Size.Sum -gt 1GB) {
        $SizeHumanReadable = "{0:N2}" -f ($Size.Sum / 1GB) + " GB"
    }
    elseif ($Size.Sum -gt 1MB) {
        $SizeHumanReadable = "{0:N2}" -f ($Size.Sum / 1MB) + " MB"
    }
    else {
        $SizeHumanReadable = "{0:N2}" -f ($Size.Sum / 1KB) + " KB"
    }

    $Results += New-Object PSObject -Property @{Name = $f.Name; Length = $Size.Sum; SizeHumanReadable = $SizeHumanReadable }
}

$Results = $Results | Sort-Object Length -Descending

$TotalSizeHumanReadable = if ($TotalSize -gt 1GB) {
    "{0:N2}" -f ($TotalSize / 1GB) + " GB"
}
elseif ($TotalSize -gt 1MB) {
    "{0:N2}" -f ($TotalSize / 1MB) + " MB"
}
else {
    "{0:N2}" -f ($TotalSize / 1KB) + " KB"
}

$Results += New-Object PSObject -Property @{Name = "Total"; Length = $TotalSize; SizeHumanReadable = $TotalSizeHumanReadable }

$Results | Format-Table Name, SizeHumanReadable -AutoSize