# 🦙 Ollama Guide

> **The single-stop reference for everything Ollama** — install, configure, run models locally, deploy on a server, and connect remotely.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 📖 Table of Contents

### Getting Started
| # | Topic | Description |
|---|-------|-------------|
| 01 | [Introduction](docs/01-introduction.md) | What is Ollama, architecture overview, why use it |
| 02 | [Installation](docs/02-installation.md) | macOS, Linux, Windows, and Docker install guides |
| 03 | [Quickstart](docs/03-quickstart.md) | Pull a model and start chatting in under 5 minutes |

### Core Usage
| # | Topic | Description |
|---|-------|-------------|
| 04 | [Configuration](docs/04-configuration.md) | Default port, environment variables, storage paths |
| 05 | [CLI Commands](docs/05-cli-commands.md) | Complete command-line reference |
| 06 | [Available Models](docs/06-available-models.md) | Model catalog, sizes, quantizations, recommendations |
| 07 | [Modelfile](docs/07-modelfile.md) | Create custom models with Modelfile syntax |
| 08 | [API Reference](docs/08-api-reference.md) | REST API endpoints with curl examples |

### Server & Advanced
| # | Topic | Description |
|---|-------|-------------|
| 09 | [Server Deployment](docs/09-server-deployment.md) | Deploy on a headless Linux server with systemd |
| 10 | [Remote Access](docs/10-remote-access.md) | Connect your Mac to a remote Ollama server |
| 11 | [GPU Setup](docs/11-gpu-setup.md) | NVIDIA, AMD, and Apple Silicon GPU acceleration |
| 12 | [Docker](docs/12-docker.md) | Docker and Docker Compose setups (CPU + GPU) |
| 13 | [Troubleshooting](docs/13-troubleshooting.md) | Common errors, debugging, FAQ |

---

## ⚡ Quick Start

```bash
# 1. Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 2. Pull a model
ollama pull llama3.2

# 3. Start chatting
ollama run llama3.2
```

> **That's it.** For detailed guides, start with the [Introduction](docs/01-introduction.md).

---

## 🛠️ Helper Scripts

Ready-to-use automation scripts (Bash + PowerShell):

| Script | Description |
|--------|-------------|
| [install-ollama.sh](scripts/linux/install-ollama.sh) / [.ps1](scripts/powershell/install-ollama.ps1) | Detect OS and install Ollama |
| [setup-remote-server.sh](scripts/linux/setup-remote-server.sh) / [.ps1](scripts/powershell/setup-remote-server.ps1) | Automate headless server setup |
| [pull-popular-models.sh](scripts/linux/pull-popular-models.sh) / [.ps1](scripts/powershell/pull-popular-models.ps1) | Batch-pull popular models |

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
