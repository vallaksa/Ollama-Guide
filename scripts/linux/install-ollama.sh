#!/usr/bin/env bash

# Ollama Automatic Installer
# Detects OS and installs Ollama correctly.

set -e

echo "🦙 Ollama Installation Script"
echo "------------------------------"

OS="$(uname -s)"
ARCH="$(uname -m)"

echo "Detected OS: $OS ($ARCH)"

if [ "$OS" = "Darwin" ]; then
    echo "macOS detected."
    if command -v brew &> /dev/null; then
        echo "Homebrew found. Installing via Homebrew..."
        brew install ollama
    else
        echo "Homebrew not found. Using direct curl installer..."
        curl -fsSL https://ollama.com/install.sh | sh
    fi

elif [ "$OS" = "Linux" ]; then
    echo "Linux detected."
    echo "Running official Ollama install script..."
    curl -fsSL https://ollama.com/install.sh | sh

else
    echo "❌ Unsupported OS: $OS"
    echo "For Windows, please use: scripts/install-ollama.ps1"
    exit 1
fi

echo "------------------------------"
if command -v ollama &> /dev/null; then
    echo "✅ Success! Ollama is installed."
    ollama --version
    echo ""
    echo "Try running: ollama run llama3.2:1b"
else
    echo "❌ Verify failed: 'ollama' command not found."
    exit 1
fi
