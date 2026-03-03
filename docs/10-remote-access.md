# Remote Access

> **Connect your Mac (or any client) to a remote Ollama server and use cloud-hosted models locally.**

---

## Overview

With Ollama running on a remote server (see [Server Deployment](09-server-deployment.md)), you can use models from your local machine as if they were running locally. There are two primary methods:

| Method | Security | Setup Complexity | Best For |
|--------|----------|-----------------|----------|
| **SSH Tunnel** | ★★★★★ | Low | Most users — secure, no firewall changes |
| **Direct Access** | ★★★☆☆ | Medium | LAN / VPN networks |

---

## Method 1: SSH Tunnel (Recommended)

An SSH tunnel creates an encrypted connection between your Mac and the server. No firewall changes needed — if you can SSH in, you can tunnel.

### Step 1: Create the Tunnel

```bash
ssh -N -L 11434:localhost:11434 user@your-server-ip
```

| Flag | Meaning |
|------|---------|
| `-N` | Don't execute a remote command (tunnel only) |
| `-L 11434:localhost:11434` | Forward local port 11434 → server's localhost:11434 |

This runs in the foreground. Open a new terminal to use Ollama.

### Step 2: Use Ollama Locally

With the tunnel running, your local machine can access the remote server at `localhost:11434`:

```bash
# Test connection
curl http://localhost:11434
# Output: Ollama is running

# Run a model (talks to the remote server)
OLLAMA_HOST=http://localhost:11434 ollama run llama3.2

# Or generate via API
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Hello from my Mac!",
  "stream": false
}'
```

### Step 3: Run the Tunnel in the Background

```bash
# Background tunnel (persists until you kill it)
ssh -f -N -L 11434:localhost:11434 user@your-server-ip

# Find and kill it later
ps aux | grep "ssh.*11434" | grep -v grep
kill <pid>
```

### Step 4: Persistent Tunnel with SSH Config

Add to `~/.ssh/config` on your Mac:

```
Host ollama-server
    HostName your-server-ip
    User your-username
    LocalForward 11434 localhost:11434
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Now connect with:
```bash
ssh -fN ollama-server
```

### Auto-Reconnecting Tunnel with autossh

For a tunnel that automatically reconnects on disconnection:

```bash
# Install autossh
brew install autossh   # macOS
sudo apt install autossh  # Debian/Ubuntu

# Run persistent tunnel
autossh -f -N -L 11434:localhost:11434 user@your-server-ip
```

---

## Method 2: Direct Access

If your server is on a local network or VPN, you can connect directly without a tunnel.

### Prerequisites

1. **Server** is configured with `OLLAMA_HOST=0.0.0.0:11434` (see [Server Deployment](09-server-deployment.md))
2. **Firewall** allows port 11434 from your IP
3. **Network** — both machines on the same LAN or VPN

### Usage

Set `OLLAMA_HOST` to point at the remote server:

```bash
# One-off command
OLLAMA_HOST=http://192.168.1.100:11434 ollama run llama3.2

# Or export for the session
export OLLAMA_HOST=http://192.168.1.100:11434
ollama list      # Lists models on the REMOTE server
ollama run llama3.2
```

### Persist the Setting (macOS)

Add to `~/.zshrc`:
```bash
export OLLAMA_HOST="http://192.168.1.100:11434"
```

Then reload:
```bash
source ~/.zshrc
```

> **⚠️ Warning:** Direct access transmits data unencrypted. Only use on trusted networks (LAN, VPN). For anything over the internet, use SSH tunneling.

---

## Using Remote Models from Applications

### Python

```python
import ollama

# Point the client at the remote server
client = ollama.Client(host='http://your-server-ip:11434')

# Or if using SSH tunnel
client = ollama.Client(host='http://localhost:11434')

response = client.chat(model='llama3.2', messages=[
    {'role': 'user', 'content': 'Hello from Python!'}
])
print(response['message']['content'])
```

### JavaScript/TypeScript

```javascript
import { Ollama } from 'ollama';

const ollama = new Ollama({ host: 'http://your-server-ip:11434' });

const response = await ollama.chat({
  model: 'llama3.2',
  messages: [{ role: 'user', content: 'Hello from JS!' }],
});
console.log(response.message.content);
```

### curl

```bash
curl http://your-server-ip:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [{"role": "user", "content": "Hello!"}],
  "stream": false
}'
```

### Open WebUI

If using [Open WebUI](https://github.com/open-webui/open-webui) as a frontend:

```bash
docker run -d \
  --name open-webui \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://your-server-ip:11434 \
  ghcr.io/open-webui/open-webui:main
```

---

## Managing Remote Models

When `OLLAMA_HOST` points to a remote server, all `ollama` CLI commands operate on that server:

```bash
export OLLAMA_HOST=http://your-server-ip:11434

# Pull a model ON THE SERVER
ollama pull mistral

# List models ON THE SERVER
ollama list

# Run a model (inference happens ON THE SERVER)
ollama run mistral
```

> **📝 Note:** Model files are stored on the **server**, not your local machine. Only the prompts and responses travel over the network.

---

## Performance Considerations

| Factor | Impact | Recommendation |
|--------|--------|---------------|
| **Network latency** | Adds delay to first token | Use same region / LAN for lowest latency |
| **Bandwidth** | Streaming tokens is low-bandwidth (~1 KB/s) | Even WiFi is fine for chat |
| **Model loading** | First request may take seconds to load model | Set `OLLAMA_KEEP_ALIVE=-1` on server to keep models loaded |
| **Concurrent users** | Each request uses GPU memory | Set `OLLAMA_NUM_PARALLEL` based on VRAM |
| **Large prompts** | Upload speed matters for long inputs | Not an issue on broadband |

### Latency Benchmarks (Approximate)

| Connection Type | First Token Latency | Tokens/Second Impact |
|----------------|--------------------|--------------------|
| Same machine | Baseline | None |
| LAN (1 Gbps) | +1–5 ms | Negligible |
| VPN (100 Mbps) | +10–50 ms | Negligible |
| Internet (nearby) | +20–100 ms | Negligible |
| Internet (cross-continent) | +100–300 ms | Minor |

> **💡 Tip:** Streaming mode (`stream: true`) gives the best perceived performance over remote connections because tokens appear as they're generated.

---

## Troubleshooting Remote Access

| Issue | Cause | Fix |
|-------|-------|-----|
| Connection refused | Tunnel not running / server down | Check tunnel, `systemctl status ollama` |
| Connection timeout | Firewall blocking port | Open 11434 or use SSH tunnel |
| "Model not found" | Model not on server | `ollama pull <model>` on the server |
| Slow first response | Model loading into GPU | Set `OLLAMA_KEEP_ALIVE=-1` |
| SSH tunnel drops | Network instability | Use `autossh` for auto-reconnect |
| `OLLAMA_HOST` ignored | Local Ollama running | Stop local Ollama first: `killall ollama` |

---

## Next Steps

→ [GPU Setup](11-gpu-setup.md) — Configure GPU acceleration on your server.
