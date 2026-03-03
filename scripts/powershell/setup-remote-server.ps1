<#
.SYNOPSIS
A helper script for Windows that sets the environment variable to point to a remote Linux server.
#>

param (
    [Parameter(Mandatory=$true, HelpMessage="Enter the remote Linux server IP address (e.g. 192.168.1.100)")]
    [string]$ServerIP
)

$targetHost = "http://$($ServerIP):11434"

Write-Host "🦙 Ollama Remote Access Helper" -ForegroundColor Cyan
Write-Host "------------------------------"
Write-Host "Setting OLLAMA_HOST to $targetHost"

# Set for current session
$env:OLLAMA_HOST = $targetHost

Write-Host "Testing connection to remote server..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $targetHost -Method Get -TimeoutSec 5
    if ($response -eq "Ollama is running") {
        Write-Host "✅ Connection successful! The server is running." -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Connection failed. Ensure the server is running, the port is open in the firewall, and systemd is configured with 0.0.0.0." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "To make this persistent across all PowerShell sessions, run this as Administrator:"
Write-Host "[System.Environment]::SetEnvironmentVariable('OLLAMA_HOST', '$targetHost', 'User')" -ForegroundColor Cyan
Write-Host ""
Write-Host "Try it now:"
Write-Host "ollama list" -ForegroundColor Yellow
