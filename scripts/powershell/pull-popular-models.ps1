<#
.SYNOPSIS
Batch pulls popular Ollama models.
#>

Write-Host "🦙 Batch Pulling Popular Ollama Models" -ForegroundColor Cyan
Write-Host "-------------------------------------"

if (-Not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Error "ollama is not installed. Please run scripts/install-ollama.ps1 first."
    exit 1
}

$models = @(
    "llama3.2:1b",
    "llama3.2",
    "mistral",
    "gemma2:2b",
    "nomic-embed-text"
)

foreach ($model in $models) {
    Write-Host "📥 Pulling $model..." -ForegroundColor Yellow
    try {
        Start-Process -FilePath "ollama" -ArgumentList "pull", $model -Wait -NoNewWindow
        Write-Host "✅ $model complete." -ForegroundColor Green
    } catch {
        Write-Error "Failed to pull $model"
    }
    Write-Host ""
}

Write-Host "🎉 All models downloaded successfully!" -ForegroundColor Cyan
ollama list
