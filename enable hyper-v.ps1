# Open PowerShell as Administrator and run the following script

# Enable the Hyper-V feature
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Restart the computer to apply changes
Restart-Computer
