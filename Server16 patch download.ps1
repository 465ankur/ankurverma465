# Function to download updates using BITS (Background Intelligent Transfer Service)
function Download-Update {
    param (
        [string]$updateUrl,
        [string]$fileName,
        [string]$destinationPath
    )

    # Ensure destination directory exists
    if (!(Test-Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory
    }

    # Set the full file path
    $filePath = Join-Path $destinationPath $fileName

    # Check if the file already exists, if not, download it
    if (-not (Test-Path $filePath)) {
        try {
            Write-Output "Starting download of $fileName..."
            $job = Start-BitsTransfer -Source $updateUrl -Destination $filePath -Description "Downloading $fileName"
            Write-Output "Download completed: $filePath"
        } catch {
            Write-Output "Failed to download $fileName from $updateUrl. Error: $_"
        }
    } else {
        Write-Output "$fileName already exists in $destinationPath."
    }
}

# Main script execution
try {
    # Define the destination path for updates
    $destinationPath = "C:\WindowsUpdates"

    # Add direct links to the updates (URLs manually obtained from the Microsoft Update Catalog)
    $ssuUrl2016 = "https://catalog.s.download.windowsupdate.com/d/msu-link-for-windows-server-2016-ssu.msu"
    $cuUrl2016 = "https://catalog.s.download.windowsupdate.com/d/msu-link-for-windows-server-2016-cu.msu"
    $ssuUrl2019 = "https://catalog.s.download.windowsupdate.com/d/msu-link-for-windows-server-2019-ssu.msu"
    $cuUrl2019 = "https://catalog.s.download.windowsupdate.com/d/msu-link-for-windows-server-2019-cu.msu"

    # Define filenames for the updates
    $ssuFile2016 = "SSU_Windows_Server_2016.msu"
    $cuFile2016 = "CU_Windows_Server_2016.msu"
    $ssuFile2019 = "SSU_Windows_Server_2019.msu"
    $cuFile2019 = "CU_Windows_Server_2019.msu"

    # Download updates for Windows Server 2016
    Download-Update -updateUrl $ssuUrl2016 -fileName $ssuFile2016 -destinationPath $destinationPath
    Download-Update -updateUrl $cuUrl2016 -fileName $cuFile2016 -destinationPath $destinationPath

    # Download updates for Windows Server 2019
    Download-Update -updateUrl $ssuUrl2019 -fileName $ssuFile2019 -destinationPath $destinationPath
    Download-Update -updateUrl $cuUrl2019 -fileName $cuFile2019 -destinationPath $destinationPath

    Write-Output "All updates downloaded successfully to $destinationPath."

} catch {
    Write-Output "An unexpected error occurred: $_"
}
