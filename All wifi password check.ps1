$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
foreach ($profile in $profiles) {
    $details = netsh wlan show profile name="$profile" key=clear
    $password = ($details | Select-String "Key Content" | ForEach-Object { $_.ToString().Split(":")[1].Trim() })
    [PSCustomObject]@{
        PROFILE_NAME = $profile
        PASSWORD = if ($password) { $password } else { "N/A" }
    }
}
