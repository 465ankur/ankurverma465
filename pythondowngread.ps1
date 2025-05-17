# Check if pyenv is installed
if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
    Write-Host "pyenv could not be found. Please install pyenv-win first."
    exit
}

# Install Python 3.5.0
pyenv install 3.5.0

# Set Python 3.5.0 as the global version
pyenv global 3.5.0

# Verify the Python version
python --version
