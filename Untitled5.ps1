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

# Function to search Microsoft Update Catalog for updates
function Search-UpdateCatalog {
    param (
        [string]$searchQuery
    )
    
    $searchUrl = "https://www.catalog.update.microsoft.com/Search.aspx?q=$searchQuery"
    $response = Invoke-WebRequest -Uri $searchUrl -UseBasicParsing
    $links = [regex]::Matches($response.Content, 'href="([^"]+\.msu)"')

    if ($links.Count -gt 0) {
        # Extract and return the first link (you can improve this to select specific ones if needed)
        return "https://www.catalog.update.microsoft.com" + $links[0].Groups[1].Value
    } else {
        Write-Output "No updates found for $searchQuery"
        return $null
    }
}

# Function to download updates
function Download-Update {
    param (
        [string]$updateType,
        [string]$osVersion,
        [string]$destinationPath
    )
    
    # Construct search query for Microsoft Update Catalog
    $searchQuery = "$updateType Windows Server $osVersion"
    
    Write-Output "Searching Microsoft Update Catalog for $updateType for Windows Server $osVersion..."
    $updateUrl = Search-UpdateCatalog -searchQuery $searchQuery
    
    if ($updateUrl) {
        $filePath = Join-Path $destinationPath "$($updateType)_$($osVersion).msu"
        try {
            Write-Output "Downloading $updateType for Windows Server $osVersion from $updateUrl..."
            Invoke-WebRequest -Uri $updateUrl -OutFile $filePath
            Write-Output "$updateType for Windows Server $osVersion downloaded to $filePath"
        } catch {
            Write-Output "Failed to download $updateType for Windows Server $osVersion. Error: $_"
        }
    } else {
        Write-Output "No download link found for $updateType and OS version $osVersion."
    }
}

# Main script execution
try {
    # Get the current date and second Tuesday
    $currentDate = Get-Date
    $secondTuesday = Get-SecondTuesday
    Write-Output "Current date: $($currentDate)"
    Write-Output "Second Tuesday of the month: $($secondTuesday)"

    # Create a folder to store updates if it doesn't exist
    $destinationPath = "C:\WindowsUpdates"
    if (!(Test-Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory
    }

    # If today is the second Tuesday, download only SSU and CU
    if ($currentDate.Date -eq $secondTuesday.Date) {
        Write-Output "Today is the second Tuesday of the month. Downloading SSU and CU for both Windows Server 2016 and 2019."

        # Download SSU and CU for Windows Server 2016 and 2019
        Download-Update -updateType "Servicing Stack Update" -osVersion "2016" -destinationPath $destinationPath
        Download-Update -updateType "Cumulative Update" -osVersion "2016" -destinationPath $destinationPath
        Download-Update -updateType "Servicing Stack Update" -osVersion "2019" -destinationPath $destinationPath
        Download-Update -updateType "Cumulative Update" -osVersion "2019" -destinationPath $destinationPath

    } else {
        # If today is not the second Tuesday, download all updates available
        Write-Output "Today is not the second Tuesday of the month. Downloading all available updates for Windows Server 2016 and 2019."

        # Download all updates (SSU and CU)
        Download-Update -updateType "Servicing Stack Update" -osVersion "2016" -destinationPath $destinationPath
        Download-Update -updateType "Cumulative Update" -osVersion "2016" -destinationPath $destinationPath
        Download-Update -updateType "Servicing Stack Update" -osVersion "2019" -destinationPath $destinationPath
        Download-Update -updateType "Cumulative Update" -osVersion "2019" -destinationPath $destinationPath
    }

    Write-Output "Updates downloaded successfully to $destinationPath."

} catch {
    Write-Output "An unexpected error occurred: $_"
}
