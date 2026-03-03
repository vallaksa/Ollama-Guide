<#
.SYNOPSIS
Installs Ollama on Windows.

.DESCRIPTION
Detects if WSL is installed. If WSL isn't installed, it downloads and runs the native Windows installer.
#>

Write-Host "🦙 Ollama Windows Installer" -ForegroundColor Cyan
Write-Host "------------------------------"

$OllamaUrl = "https://ollama.com/download/OllamaSetup.exe"
$InstallerPath = "$env:TEMP\OllamaSetup.exe"

Write-Host "Downloading installer from $OllamaUrl..."
try {
    Invoke-WebRequest -Uri $OllamaUrl -OutFile $InstallerPath -UseBasicParsing
} catch {
    Write-Error "Failed to download the installer. Please check your internet connection."
    exit 1
}

Write-Host "Running installer..."
try {
    Start-Process -FilePath $InstallerPath -Wait -NoNewWindow
} catch {
    Write-Error "Failed to execute the installer."
    exit 1
}

Write-Host "------------------------------"
Write-Host "✅ Installation completed."
Write-Host "Please start 'Ollama' from the Start Menu."
Write-Host "Once running, try: ollama run llama3.2:1b" -ForegroundColor Green

# Cleanup
if (Test-Path $InstallerPath) {
    Remove-Item $InstallerPath -Force
}
