$sourceFolder = "$env:USERPROFILE\AppData\Roaming\HelloGames"

$destinationFolder = "$env:USERPROFILE\Desktop\NMS Backups"

# Without .exe
$gameProcessName = "NMS"

# Check if the game is running
function Is-GameRunning {
    param([string]$processName)
    return (Get-Process $processName -ErrorAction SilentlyContinue) -ne $null
}

# Create the destination folder if it does not exist
if (-not (Test-Path -Path $destinationFolder )) {
    New-Item -ItemType Directory -Path $destinationFolder
}

function Copy-Folder {
    param(
        [String]$from,
        [String]$to
    )
    Copy-Item -Path $from -Destination $to -Recurse -Force
}

# Check how many times the game is not running
$notRunningCount = 0

# Save every 5 minutes
while ($true) {
    if (Is-GameRunning -processName $gameProcessName) {
        Write-Host "Game is running. Performing backup..."
        # Start Saving
        Copy-Folder -from $sourceFolder\* -to $destinationFolder
        $backupFolderItem = Get-Item -Path $destinationFolder
        $backupFolderItem.Refresh()
        $backupFolderItem.LastWriteTime = Get-Date
        Write-Host "Backup completed."
        $notRunningCount = 0 # Reinit because the game is running
    } else {
        Write-Host "NMS is not running."
        $notRunningCount++
        if ($notRunningCount -ge 2) {
            Write-Host "NMS has not been running for 2 consecutive checks. Stopping the script."
            break # Stop the script
        }
    }
    Start-Sleep -Seconds 300 # Wait 5 minutes before checking again
}

