# Function to get the second Tuesday of the current month
function Get-SecondTuesday {
    $currentDate = Get-Date
    $year = $currentDate.Year
    $month = $currentDate.Month
    $days = [System.DayOfWeek]::Tuesday
    $secondTuesday = (Get-Date -Year $year -Month $month -Day 1).AddDays(((14 - $days) + [int]::MaxValue) % 7)

    if ($secondTuesday.Day -lt 8) {
        $secondTuesday = $secondTuesday.AddDays(7)
    }

    return $secondTuesday
}

# Function to get the latest update URL
function Get-LatestUpdateUrl {
    param (
        [string]$updateType
    )

    $searchUrl = "https://www.catalog.update.microsoft.com"
    $response = Invoke-WebRequest -Uri $searchUrl -ErrorAction Stop

    if ($response.StatusCode -ne 200) {
        throw "Failed to retrieve update list from Microsoft Update Catalog"
    }

    $regex = [regex]::Matches($response.Content, 'href="([^"]+\.msu)"')

    if ($regex.Count -gt 0) {
        return $regex[0].Groups[1].Value
    } else {
        throw "Update URL not found"
    }
}

# Main script execution
try {
    $secondTuesday = Get-SecondTuesday
    $currentDate = Get-Date
    Write-Output "Current date: $($currentDate)"
    Write-Output "Second Tuesday of the month: $($secondTuesday)"

    # Paths
    $destinationPath = "C:\WindowsUpdates"
    if (!(Test-Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory
    }

    if ($currentDate.Date -eq $secondTuesday.Date) {
        # If today is the second Tuesday of the month
        Write-Output "Today is the second Tuesday of the month."

        # Download SSU
        try {
            $ssuUrl = Get-LatestUpdateUrl "Servicing Stack Update"
            $ssuPath = Join-Path $destinationPath "latest_ssu.msu"
            Write-Output "Downloading SSU from $ssuUrl"
            Invoke-WebRequest -Uri $ssuUrl -OutFile $ssuPath
        } catch {
            Write-Output "Failed to retrieve SSU URL: $_"
        }

        # Download CU
        try {
            $cuUrl = Get-LatestUpdateUrl "Cumulative Update"
            $cuPath = Join-Path $destinationPath "latest_cu.msu"
            Write-Output "Downloading CU from $cuUrl"
            Invoke-WebRequest -Uri $cuUrl -OutFile $cuPath
        } catch {
            Write-Output "Failed to retrieve CU URL: $_"
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
    } else {
        # If today is not the second Tuesday, download all available packages
        Write-Output "Today is not the second Tuesday of the month. Downloading all available packages."

        # Download SSU
        try {
            $ssuUrl = Get-LatestUpdateUrl "Servicing Stack Update"
            $ssuPath = Join-Path $destinationPath "latest_ssu.msu"
            Write-Output "Downloading SSU from $ssuUrl"
            Invoke-WebRequest -Uri $ssuUrl -OutFile $ssuPath
        } catch {
            Write-Output "Failed to retrieve SSU URL: $_"
        }

        # Download CU
        try {
            $cuUrl = Get-LatestUpdateUrl "Cumulative Update"
            $cuPath = Join-Path $destinationPath "latest_cu.msu"
            Write-Output "Downloading CU from $cuUrl"
            Invoke-WebRequest -Uri $cuUrl -OutFile $cuPath
        } catch {
            Write-Output "Failed to retrieve CU URL: $_"
        }

        # Download any other packages you want
        try {
            $otherUpdateUrl = Get-LatestUpdateUrl "Other Updates"
            $otherUpdatePath = Join-Path $destinationPath "other_updates.msu"
            Write-Output "Downloading other updates from $otherUpdateUrl"
            Invoke-WebRequest -Uri $otherUpdateUrl -OutFile $otherUpdatePath
        } catch {
            Write-Output "Failed to retrieve additional update URL: $_"
        }

        Write-Output "All packages downloaded. You can install them manually later."
    }

} catch {
    Write-Output "An unexpected error occurred: $_"
}
