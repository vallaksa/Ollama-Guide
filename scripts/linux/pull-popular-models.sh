#!/usr/bin/env bash

# Batch Model Puller
# Pulls a curated list of popular models.

set -e

MODELS=(
    "llama3.2:1b"
    "llama3.2"
    "mistral"
    "gemma2:2b"
    "nomic-embed-text"
)

echo "🦙 Batch Pulling Popular Ollama Models"
echo "-------------------------------------"

if ! command -v ollama &> /dev/null; then
    echo "❌ Error: ollama is not installed. Please run scripts/install-ollama.sh first."
    exit 1
fi

# Ensure server is running
if ! curl -s http://localhost:11434/ > /dev/null; then
    echo "Starting Ollama server in the background..."
    ollama serve &
    sleep 3
fi

for model in "${MODELS[@]}"; do
    echo "📥 Pulling $model..."
    ollama pull "$model"
    echo "✅ $model complete."
    echo ""
done

echo "🎉 All models downloaded successfully!"
ollama list
