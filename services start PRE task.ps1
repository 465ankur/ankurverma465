#To stop a service called "windows exporter" across multiple Windows servers, you can use PowerShell for remote execution. Here's a script that stops the service on multiple servers:
 
### PowerShell Script:
#powershell
# Define the list of servers where the service needs to be stopped
#$servers = @("Server1", "Server2", "Server3") # Replace with actual server names
 
# Define the service name
$serviceName = "windows exporter"
 
# Loop through each server and stop the service
foreach ($server in $servers) {
    Write-Host "Processing server: $server"
    
    # Check if the service exists on the remote server
    $service = Get-Service -ComputerName $server -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($service -and $service.Status -eq 'Running') {
        # Stop the service
        Write-Host "Stopping $serviceName on $server..."
        Stop-Service -ComputerName $server -Name $serviceName -Force
        
        # Verify if the service was stopped
        $service = Get-Service -ComputerName $server -Name $serviceName
        if ($service.Status -eq 'Stopped') {
            Write-Host "$serviceName successfully stopped on $server."
        } else {
            Write-Host "Failed to stop $serviceName on $server."
        }
    } else {
        Write-Host "$serviceName is not running on $server or does not exist."
    }
}