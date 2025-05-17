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

    return $filePath
}

# Function to copy updates to SCCM path and update SCCM distribution point
function Copy-ToSCCM {
    param (
        [string]$filePath,
        [string]$sccmPath
    )

    # Ensure SCCM path exists
    if (!(Test-Path $sccmPath)) {
        New-Item -Path $sccmPath -ItemType Directory
    }

    # Copy the downloaded update to the SCCM path
    $destinationFilePath = Join-Path $sccmPath (Split-Path $filePath -Leaf)

    try {
        Copy-Item -Path $filePath -Destination $sccmPath -Force
        Write-Output "Copied $filePath to $sccmPath"
    } catch {
        Write-Output "Failed to copy $filePath to SCCM path. Error: $_"
    }

    return $destinationFilePath
}

# Main script execution
try {
    # Define the destination path for updates
    $destinationPath = "C:\WindowsUpdates"

    # SCCM paths for 2016 and 2019 (modify as per your SCCM configuration)
    $sccmPath2016 = "\\SCCM_Server\Sources\SoftwareUpdates\WindowsServer2016"
    $sccmPath2019 = "\\SCCM_Server\Sources\SoftwareUpdates\WindowsServer2019"

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
    $ssuFilePath2016 = Download-Update -updateUrl $ssuUrl2016 -fileName $ssuFile2016 -destinationPath $destinationPath
    $cuFilePath2016 = Download-Update -updateUrl $cuUrl2016 -fileName $cuFile2016 -destinationPath $destinationPath

    # Download updates for Windows Server 2019
    $ssuFilePath2019 = Download-Update -updateUrl $ssuUrl2019 -fileName $ssuFile2019 -destinationPath $destinationPath
    $cuFilePath2019 = Download-Update -updateUrl $cuUrl2019 -fileName $cuFile2019 -destinationPath $destinationPath

    # Copy the downloaded updates to SCCM for Windows Server 2016
    Copy-ToSCCM -filePath $ssuFilePath2016 -sccmPath $sccmPath2016
    Copy-ToSCCM -filePath $cuFilePath2016 -sccmPath $sccmPath2016

    # Copy the downloaded updates to SCCM for Windows Server 2019
    Copy-ToSCCM -filePath $ssuFilePath2019 -sccmPath $sccmPath2019
    Copy-ToSCCM -filePath $cuFilePath2019 -sccmPath $sccmPath2019

    Write-Output "All updates downloaded and copied to SCCM paths successfully."

} catch {
    Write-Output "An unexpected error occurred: $_"
}
