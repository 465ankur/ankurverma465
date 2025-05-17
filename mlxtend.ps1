# PowerShell script to install mlxtend library
# This ensures pip is available and installs Jupyter Notebook requirements

# Check Python installation
Write-Host "Checking Python installation..."
python --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "Python is not installed. Please install Python before running this script."
    exit
}

# Upgrade pip to the latest version
Write-Host "Upgrading pip..."
python -m pip install --upgrade pip

# Install Jupyter Notebook if not already installed
Write-Host "Installing Jupyter Notebook..."
python -m pip install notebook

# Install mlxtend library
Write-Host "Installing mlxtend library..."
python -m pip install mlxtend

Write-Host "Installation complete. You can now use mlxtend in Jupyter Notebook."
