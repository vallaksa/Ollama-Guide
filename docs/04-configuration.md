# Configuration

> **Customize Ollama's behavior with environment variables and configuration options.**

---

## Default Settings

| Setting | Default Value | Description |
|---------|---------------|-------------|
| **Host** | `127.0.0.1` | Address the server binds to |
| **Port** | `11434` | HTTP API port |
| **Model directory** | `~/.ollama/models` | Where models are stored |
| **Keep alive** | `5m` | How long models stay loaded in memory |
| **Context window** | Model-dependent | Max tokens in the context (typically 2048–8192) |
| **Max loaded models** | Auto | Number of models kept in memory simultaneously |

---

## Environment Variables

Set these before starting Ollama (or in your systemd service file on Linux).

### Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_HOST` | `127.0.0.1:11434` | Bind address and port |
| `OLLAMA_MODELS` | `~/.ollama/models` | Model storage directory |
| `OLLAMA_KEEP_ALIVE` | `5m` | Duration to keep models loaded (`0` = unload immediately, `-1` = never unload) |
| `OLLAMA_NUM_PARALLEL` | `0` (auto) | Max parallel requests per model |
| `OLLAMA_MAX_LOADED_MODELS` | `0` (auto) | Max models loaded simultaneously |
| `OLLAMA_MAX_QUEUE` | `512` | Max queued requests |
| `OLLAMA_ORIGINS` | (none) | Allowed CORS origins (comma-separated) |
| `OLLAMA_DEBUG` | `0` | Enable debug logging (`1` = on) |
| `OLLAMA_NOPRUNE` | `0` | Disable automatic pruning of old model blobs |
| `OLLAMA_TMPDIR` | (system default) | Temporary directory for downloads |

### GPU Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_GPU_OVERHEAD` | `0` | Reserved GPU overhead in bytes |
| `OLLAMA_FLASH_ATTENTION` | `1` | Enable flash attention (`0` = disable) |
| `CUDA_VISIBLE_DEVICES` | (all) | Limit which NVIDIA GPUs to use |
| `HIP_VISIBLE_DEVICES` | (all) | Limit which AMD GPUs to use |
| `OLLAMA_LLM_LIBRARY` | (auto) | Force a specific compute library |

---

## Setting Environment Variables

### macOS

For the **Ollama app** (menu bar), use `launchctl`:
```bash
launchctl setenv OLLAMA_HOST "0.0.0.0:11434"
launchctl setenv OLLAMA_MODELS "/path/to/models"
```
Then restart the Ollama app.

For **terminal use**, add to your shell profile (`~/.zshrc` or `~/.bash_profile`):
```bash
export OLLAMA_HOST="0.0.0.0:11434"
export OLLAMA_MODELS="/Volumes/ExternalDrive/ollama/models"
```

### Linux

For the **systemd service**, create an override:
```bash
sudo systemctl edit ollama
```

Add:
```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_MODELS=/data/ollama/models"
Environment="OLLAMA_KEEP_ALIVE=10m"
```

Then reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

For **manual start**, export in your shell:
```bash
export OLLAMA_HOST="0.0.0.0:11434"
ollama serve
```

### Windows

1. **System Environment Variables:**
   - Open **Start → "Edit the system environment variables"**.
   - Click **Environment Variables**.
   - Under User or System variables, click **New**.
   - Add `OLLAMA_HOST` with value `0.0.0.0:11434`.
   - Restart Ollama.

2. **PowerShell (session only):**
   ```powershell
   $env:OLLAMA_HOST = "0.0.0.0:11434"
   $env:OLLAMA_MODELS = "D:\ollama\models"
   ollama serve
   ```

---

## Model Storage

### Default Paths

| Platform | Default Path |
|----------|-------------|
| macOS | `~/.ollama/models` |
| Linux | `~/.ollama/models` (user) or `/usr/share/ollama/.ollama/models` (systemd) |
| Windows | `%USERPROFILE%\.ollama\models` |
| Docker | `/root/.ollama/models` (inside container) |

### Changing the Storage Location

Use the `OLLAMA_MODELS` environment variable:

```bash
# Move models to a larger drive
export OLLAMA_MODELS="/mnt/bigdrive/ollama/models"

# Or create a symlink
ln -s /mnt/bigdrive/ollama/models ~/.ollama/models
```

> **⚠️ Warning:** If you change `OLLAMA_MODELS`, previously downloaded models won't appear until you either move them to the new location or re-pull them.

---

## Log Locations

| Platform | Log Location |
|----------|-------------|
| macOS | `~/.ollama/logs/server.log` |
| Linux (systemd) | `journalctl -u ollama` |
| Linux (manual) | stderr of the `ollama serve` process |
| Windows | `%LOCALAPPDATA%\Ollama\server.log` |
| Docker | `docker logs ollama` |

### Enabling Debug Logs

```bash
# Linux systemd
sudo systemctl edit ollama
# Add: Environment="OLLAMA_DEBUG=1"
sudo systemctl daemon-reload
sudo systemctl restart ollama

# View debug logs
journalctl -u ollama -f
```

---

## Common Configuration Recipes

### Allow Remote Access
```bash
OLLAMA_HOST=0.0.0.0:11434
```

### Enable CORS for Web Apps
```bash
OLLAMA_ORIGINS="http://localhost:3000,https://your-app.com"
```

### Keep Models Loaded Permanently
```bash
OLLAMA_KEEP_ALIVE=-1
```

### Use a Custom Port
```bash
OLLAMA_HOST=127.0.0.1:8080
```

### Limit GPU Usage
```bash
CUDA_VISIBLE_DEVICES=0    # Use only GPU 0
```

---

## Next Steps

→ [CLI Commands](05-cli-commands.md) — Master every Ollama command.
