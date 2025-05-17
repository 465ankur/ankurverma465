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
    return (Get-CimInstance Win32_OperatingSystem).Caption
}

# Function to determine if today is Second Tuesday
function Is-SecondTuesday {
    $today = Get-Date
    $firstDay = Get-Date -Year $today.Year -Month $today.Month -Day 1
    $firstTuesday = $firstDay.AddDays((7 + [System.DayOfWeek]::Tuesday - $firstDay.DayOfWeek) % 7)
    $secondTuesday = $firstTuesday.AddDays(7)
    
    return $today.Date -eq $secondTuesday.Date
}

# Function to search for updates
function Search-WindowsUpdates {
    Write-Host "Checking for Windows Updates..."
    
    # Initialize Windows Update Session
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()

    # Search for Important Updates
    $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software'")

    if ($searchResult.Updates.Count -eq 0) {
        Write-Host "No new updates available."
        return @()
    } else {
        Write-Host "Found $($searchResult.Updates.Count) updates."
        return $searchResult.Updates
    }
}

# Function to download updates
function Download-WindowsUpdates {
    param (
        [Parameter(Mandatory=$true)]
        [System.__ComObject]$updates
    )

    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateDownloader = $updateSession.CreateUpdateDownloader()
    $updateCollection = New-Object -ComObject Microsoft.Update.UpdateColl

    foreach ($update in $updates) {
        $updateCollection.Add($update) | Out-Null
        Write-Host "Adding update: $($update.Title)"
    }

    $updateDownloader.Updates = $updateCollection
    Write-Host "Downloading updates..."
    $updateDownloader.Download()

    Write-Host "Download completed!"
}

# Function to install updates
function Install-WindowsUpdates {
    param (
        [Parameter(Mandatory=$true)]
        [System.__ComObject]$updates
    )

    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateInstaller = $updateSession.CreateUpdateInstaller()
    $updateCollection = New-Object -ComObject Microsoft.Update.UpdateColl

    foreach ($update in $updates) {
        $updateCollection.Add($update) | Out-Null
        Write-Host "Preparing installation: $($update.Title)"
    }

    $updateInstaller.Updates = $updateCollection
    Write-Host "Installing updates..."
    $installResult = $updateInstaller.Install()

    Write-Host "Installation Status: $($installResult.ResultCode)"
}

# Main Script Execution
$osVersion = Get-OSVersion
Write-Host "Detected OS: $osVersion"

if (Is-SecondTuesday) {
    Write-Host "Today is Second Tuesday. Updates will be handled by WSUS."
    exit 0
}

$updates = Search-WindowsUpdates
if ($updates.Count -gt 0) {
    Download-WindowsUpdates -updates $updates
    Install-WindowsUpdates -updates $updates
} else {
    Write-Host "No updates to install."
}
