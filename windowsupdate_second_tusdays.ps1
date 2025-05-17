# Function to get the second Tuesday of the current month
function Get-SecondTuesday {
    $today = Get-Date
    $firstDayOfMonth = Get-Date -Year $today.Year -Month $today.Month -Day 1
    $firstTuesday = $firstDayOfMonth.AddDays((7 + [System.DayOfWeek]::Tuesday - $firstDayOfMonth.DayOfWeek) % 7)
    $secondTuesday = $firstTuesday.AddDays(7)
    return $secondTuesday
}

# Function to get latest update URL from Microsoft Update Catalog
function Get-LatestUpdateUrl {
    param (
        [string]$updateType
    )
    
    $searchUrl = "https://www.catalog.update.microsoft.com/Search.aspx?q=$updateType"
    
    try {
        $response = Invoke-WebRequest -Uri $searchUrl -UseBasicParsing
        $regex = [regex]::Matches($response.Content, 'href="([^"]+\.msu)"')
        
        if ($regex.Count -gt 0) {
            return "https://www.catalog.update.microsoft.com" + $regex[0].Groups[1].Value
        } else {
            throw "Update URL not found"
        }
    } catch {
        Write-Output "Error fetching update URL: $_"
        return $null
    }
}

# Main script execution
$secondTuesday = Get-SecondTuesday
$currentDate = Get-Date
$destinationPath = "C:\WindowsUpdates"

# Ensure download directory exists
if (!(Test-Path $destinationPath)) {
    New-Item -Path $destinationPath -ItemType Directory
}

# Check if today is the second Tuesday
if ($currentDate.Date -eq $secondTuesday.Date) {
    Write-Output "Today is the second Tuesday of the month. No patches will be downloaded today."
    exit 0
}

Write-Output "Today is NOT the second Tuesday. Downloading updates..."

# Define update types to download
$updateTypes = @("Servicing Stack Update", "Cumulative Update", "Security Update")

foreach ($update in $updateTypes) {
    try {
        $updateUrl = Get-LatestUpdateUrl $update
        if ($updateUrl) {
            $updateFileName = "$($update -replace ' ', '_').msu"
            $updatePath = Join-Path $destinationPath $updateFileName
            Invoke-WebRequest -Uri $updateUrl -OutFile $updatePath
            Write-Output "Downloaded: $updateFileName"
        } else {
            Write-Output "No valid update found for $update"
        }
    } catch {
        Write-Output "Failed to download $update"
    }
}

Write-Output "All available updates have been downloaded successfully."
