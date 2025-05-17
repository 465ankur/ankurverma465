# Ensure script runs as Administrator
function Check-Admin {
    $currentUser = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

if (-not (Check-Admin)) {
    Write-Host "Please run PowerShell as Administrator!" -ForegroundColor Red
    exit 1
}

# Function to get OS Version
function Get-OSVersion {
    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    return $os
}

# Function to check if today is Second Tuesday
function Is-SecondTuesday {
    $today = Get-Date
    $firstDay = Get-Date -Year $today.Year -Month $today.Month -Day 1
    $firstTuesday = $firstDay.AddDays((7 + [System.DayOfWeek]::Tuesday - $firstDay.DayOfWeek) % 7)
    $secondTuesday = $firstTuesday.AddDays(7)
    return $today.Date -eq $secondTuesday.Date
}

# Function to get the latest patch URL from Microsoft Update Catalog
function Get-LatestPatchURL {
    param (
        [string]$osVersion
    )

    $searchTerm = ""
    
    if ($osVersion -match "Windows 11") {
        $searchTerm = "Windows 11 Cumulative Update"
    } elseif ($osVersion -match "Windows 10") {
        $searchTerm = "Windows 10 Cumulative Update"
    } elseif ($osVersion -match "Windows 7") {
        $searchTerm = "Windows 7 Security Update"
    } elseif ($osVersion -match "Windows Server 2022") {
        $searchTerm = "Windows Server 2022 Cumulative Update"
    } elseif ($osVersion -match "Windows Server 2019") {
        $searchTerm = "Windows Server 2019 Cumulative Update"
    } elseif ($osVersion -match "Windows Server 2016") {
        $searchTerm = "Windows Server 2016 Cumulative Update"
    } elseif ($osVersion -match "Windows Server 2012 R2") {
        $searchTerm = "Windows Server 2012 R2 Security Update"
    } elseif ($osVersion -match "Windows Server 2008 R2") {
        $searchTerm = "Windows Server 2008 R2 Security Update"
    } else {
        Write-Host "OS not recognized for updates."
        exit 1
    }

    # Microsoft Update Catalog URL
    $catalogURL = "https://www.catalog.update.microsoft.com/Search.aspx?q=$searchTerm"

    Write-Host "Fetching update URL from Microsoft Update Catalog..."
    $response = Invoke-WebRequest -Uri $catalogURL -UseBasicParsing

    # Extract the first .msu file link from the search results
    $regex = [regex]::Matches($response.Content, 'href="([^"]+\.msu)"')

    if ($regex.Count -gt 0) {
        return "https://www.catalog.update.microsoft.com" + $regex[0].Groups[1].Value
    } else {
        Write-Host "Update URL not found."
        exit 1
    }
}

# Function to download and save the update
function Download-Patch {
    param (
        [string]$patchUrl
    )

    $destinationPath = "C:\WindowsUpdates"
    if (!(Test-Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory | Out-Null
    }

    $fileName = $patchUrl.Split("/")[-1]
    $savePath = Join-Path -Path $destinationPath -ChildPath $fileName

    Write-Host "Downloading update from: $patchUrl"
    Invoke-WebRequest -Uri $patchUrl -OutFile $savePath

    if (Test-Path $savePath) {
        Write-Host "Update downloaded successfully: $savePath"
    } else {
        Write-Host "Download failed."
        exit 1
    }
}

# Main Execution
$osVersion = Get-OSVersion
Write-Host "Detected OS: $osVersion"

# Get the update URL from Microsoft Update Catalog
$patchUrl = Get-LatestPatchURL -osVersion $osVersion

# Download the update
Download-Patch -patchUrl $patchUrl

Write-Host "Patch download complete. You can install it manually or use:"
Write-Host "wusa.exe C:\WindowsUpdates\latest_patch.msu /quiet /norestart"
