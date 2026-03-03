# Installation

> **Get Ollama running on your system in under 2 minutes.**

---

## macOS

### Option 1: Direct Download (Recommended)
1. Download the installer from [ollama.com/download](https://ollama.com/download).
2. Open the `.dmg` file and drag Ollama to Applications.
3. Launch Ollama from Applications — it will appear in the menu bar.

### Option 2: Homebrew
```bash
brew install ollama
```

### Option 3: Command Line
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

> **📝 Note:** On macOS, Ollama uses **Apple Metal** for GPU acceleration automatically. No additional driver setup is needed.

---

## Linux

### Automatic Install (Recommended)
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

This script:
- Detects your distribution
- Downloads the appropriate binary
- Creates an `ollama` system user
- Sets up a `systemd` service
- Detects NVIDIA/AMD GPUs and configures drivers

### Manual Install
```bash
# Download the binary
curl -L https://ollama.com/download/ollama-linux-amd64.tgz -o ollama.tgz

# Extract to /usr/local
sudo tar -C /usr -xzf ollama.tgz

# Verify
ollama --version
```

> **💡 Tip:** For GPU support on Linux, see the [GPU Setup](11-gpu-setup.md) guide.

---

## Windows

### Option 1: Installer (Recommended)
1. Download the installer from [ollama.com/download](https://ollama.com/download).
2. Run the `.exe` installer and follow the prompts.
3. Ollama will appear in the system tray.

### Option 2: WSL2
If you prefer running Ollama in WSL2:
```powershell
# In a WSL2 terminal (Ubuntu)
curl -fsSL https://ollama.com/install.sh | sh
```

> **📝 Note:** WSL2 supports GPU passthrough for NVIDIA GPUs. Ensure you have the latest NVIDIA drivers installed on the Windows host.

---

## Docker

### CPU Only
```bash
docker run -d \
  --name ollama \
  -p 11434:11434 \
  -v ollama_data:/root/.ollama \
  ollama/ollama
```

### With NVIDIA GPU
```bash
docker run -d \
  --name ollama \
  --gpus all \
  -p 11434:11434 \
  -v ollama_data:/root/.ollama \
  ollama/ollama
```

> **📝 Note:** GPU passthrough requires the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). See the [Docker guide](12-docker.md) for full details.

---

## Verify Installation

After installing on any platform:

```bash
# Check version
ollama --version
```

Expected output:
```
ollama version 0.x.x
```

```bash
# Pull and run a small model to test
ollama run llama3.2
```

If you see a chat prompt (`>>>`), the installation is successful.

```
>>> Hello!
Hello! How can I help you today?
```

Type `/bye` to exit the chat.

---

## Uninstall

### macOS
```bash
# Remove the application
rm -rf /Applications/Ollama.app

# Remove models and data
rm -rf ~/.ollama

# If installed via Homebrew
brew uninstall ollama
```

### Linux
```bash
# Stop the service
sudo systemctl stop ollama
sudo systemctl disable ollama

# Remove the service file
sudo rm /etc/systemd/system/ollama.service

# Remove the binary
sudo rm /usr/local/bin/ollama

# Remove models and data
sudo rm -rf /usr/share/ollama
rm -rf ~/.ollama

# Remove the ollama user (optional)
sudo userdel ollama
sudo groupdel ollama
```

### Windows
1. Open **Settings → Apps → Installed Apps**.
2. Find **Ollama** and click **Uninstall**.
3. Optionally delete `%USERPROFILE%\.ollama` to remove downloaded models.

### Docker
```bash
docker stop ollama
docker rm ollama
docker volume rm ollama_data
```

---

## Next Steps

→ [Quickstart](03-quickstart.md) — Pull a model and start chatting.
