
$entry = "192.168.100.151 vhdialysis.intranet"
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"

# Check if the entry already exists in the hosts file
$entryExists = Select-String -Path $hostsFilePath -Pattern "^192\.168\.100\.151\s+vhdialysis\.intranet$" -Quiet

# Debug message indicating whether the entry exists or not
if ($entryExists) {
    Write-Host "The entry already exists in the hosts file."
}
else {
    Write-Host "The entry does not exist in the hosts file. Adding..."

    # Add the entry to the hosts file
    Add-Content -Path $hostsFilePath -Value $entry

    # Check if the entry was successfully added
    $entryAdded = Select-String -Path $hostsFilePath -Pattern "^192\.168\.100\.151\s+vhdialysis\.intranet$" -Quiet

    # Debug message indicating whether the entry was added successfully or not
    if ($entryAdded) {
        Write-Host "The entry has been successfully added to the hosts file."
    }
    else {
        Write-Host "Failed to add the entry to the hosts file."
    }
}
