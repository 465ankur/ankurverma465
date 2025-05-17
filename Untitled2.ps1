# Example URLs (replace these with actual URLs from the Microsoft Update Catalog)
$ssuUrl = "https://download.windowsupdate.com/c/msdownload/update/software/updt/2023/01/windows10.0-kb1234567-x64.msu"
$cuUrl = "https://download.windowsupdate.com/c/msdownload/update/software/updt/2023/01/windows10.0-kb987654321-x64.msu"

# Paths
$destinationPath = "C:\Users\AnkurS.Verma\Downloads"
if (!(Test-Path $destinationPath)) {
    New-Item -Path $destinationPath -ItemType Directory
}

# Download SSU
try {
    $ssuPath = Join-Path $destinationPath "latest_ssu.msu"
    Write-Output "Downloading SSU from $ssuUrl"
    Invoke-WebRequest -Uri $ssuUrl -OutFile $ssuPath
} catch {
    Write-Output "Failed to download SSU: $_"
}

# Download CU
try {
    $cuPath = Join-Path $destinationPath "latest_cu.msu"
    Write-Output "Downloading CU from $cuUrl"
    Invoke-WebRequest -Uri $cuUrl -OutFile $cuPath
} catch {
    Write-Output "Failed to download CU: $_"
}

# Prompt for installation
$install = Read-Host "Updates downloaded. Do you want to install them now? (yes/no)"
if ($install -eq "yes") {
    # Install SSU
    Start-Process -FilePath "wusa.exe" -ArgumentList "$ssuPath /quiet /norestart" -Wait
    # Install CU
    Start-Process -FilePath "wusa.exe" -ArgumentList "$cuPath /quiet /norestart" -Wait
    Write-Output "Installation completed. A system restart is recommended."
} else {
    Write-Output "Installation aborted by user."
}
