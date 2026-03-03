# Server Deployment

> **Deploy Ollama on a headless Linux server for remote inference with GPU acceleration.**

---

## Overview

Running Ollama on a dedicated server lets you:
- Use powerful GPU hardware for fast inference
- Share a single model server across multiple clients
- Keep your local machine free from heavy compute
- Run models 24/7 without tying up your workstation

```
┌──────────────┐         ┌───────────────────────┐
│  Your Mac    │  HTTP   │  Linux Server          │
│  (client)    │ ──────▶ │  ┌─────────────────┐  │
│              │         │  │  Ollama Server   │  │
│  curl, apps, │ ◀────── │  │  (port 11434)   │  │
│  ollama CLI  │         │  │       │          │  │
└──────────────┘         │  │  ┌────▼────┐     │  │
                         │  │  │  GPU(s) │     │  │
                         │  │  └─────────┘     │  │
                         │  └─────────────────┘  │
                         └───────────────────────┘
```

---

## Step 1: Install Ollama on the Server

SSH into your server and run:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

This installs Ollama, creates the `ollama` system user, and sets up a systemd service.

Verify:
```bash
ollama --version
```

---

## Step 2: Configure the Service

### Bind to All Interfaces

By default, Ollama only listens on `localhost`. To accept remote connections:

```bash
sudo systemctl edit ollama
```

Add the following:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

### Full Configuration (Optional)

```bash
sudo systemctl edit ollama
```

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_MODELS=/data/ollama/models"
Environment="OLLAMA_KEEP_ALIVE=10m"
Environment="OLLAMA_NUM_PARALLEL=4"
Environment="OLLAMA_MAX_LOADED_MODELS=2"
Environment="OLLAMA_ORIGINS=*"
```

### Reload and Restart

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

### Verify It's Running

```bash
# Check service status
sudo systemctl status ollama

# Check the port is bound
ss -tlnp | grep 11434

# Test locally
curl http://localhost:11434
# Output: Ollama is running
```

---

## Step 3: Enable Auto-Start on Boot

The install script typically enables this automatically, but verify:

```bash
sudo systemctl enable ollama
```

---

## Step 4: Configure the Firewall

### Using UFW (Ubuntu/Debian)

```bash
# Allow Ollama port from your IP only
sudo ufw allow from <your-ip> to any port 11434

# Or allow from a subnet
sudo ufw allow from 192.168.1.0/24 to any port 11434

# Verify
sudo ufw status
```

### Using firewalld (RHEL/CentOS/Fedora)

```bash
# Open port
sudo firewall-cmd --permanent --add-port=11434/tcp

# Or restrict to a source
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port port="11434" protocol="tcp" accept'

# Reload
sudo firewall-cmd --reload
```

### Using iptables

```bash
# Allow from specific IP
sudo iptables -A INPUT -p tcp --dport 11434 -s <your-ip> -j ACCEPT

# Drop all other connections to 11434
sudo iptables -A INPUT -p tcp --dport 11434 -j DROP

# Save rules
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

> **⚠️ Warning:** Never expose Ollama to the public internet without authentication. Ollama has no built-in auth — use SSH tunneling, a VPN, or a reverse proxy with auth.

---

## Step 5: Pull Models

```bash
# Pull your desired models
ollama pull llama3.2
ollama pull mistral
ollama pull codellama

# Verify
ollama list
```

---

## Step 6: Test Remote Access

From your local machine:

```bash
curl http://<server-ip>:11434
# Output: Ollama is running

curl http://<server-ip>:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Hello from remote!",
  "stream": false
}'
```

---

## Systemd Service Reference

The default service file is at `/etc/systemd/system/ollama.service`:

```ini
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=default.target
```

### Useful systemd Commands

```bash
# Start / stop / restart
sudo systemctl start ollama
sudo systemctl stop ollama
sudo systemctl restart ollama

# View status
sudo systemctl status ollama

# View logs (live)
journalctl -u ollama -f

# View recent logs
journalctl -u ollama --since "1 hour ago"

# View logs with errors only
journalctl -u ollama -p err
```

---

## Resource Monitoring

### GPU Usage

```bash
# NVIDIA
watch -n 1 nvidia-smi

# AMD
watch -n 1 rocm-smi
```

### Ollama-Specific

```bash
# Check which models are loaded
curl http://localhost:11434/api/ps

# Or use the CLI
ollama ps
```

### System Resources

```bash
# Overall resource usage
htop

# Memory usage
free -h

# Disk usage (model storage)
du -sh /usr/share/ollama/.ollama/models/
```

---

## Security Best Practices

1. **Never expose directly to the internet** — Use SSH tunneling or a VPN.
2. **Restrict firewall rules** — Allow only specific IPs or subnets.
3. **Use a reverse proxy** — Nginx or Caddy with basic auth or mTLS.
4. **Run as unprivileged user** — The installer creates an `ollama` user by default.
5. **Keep Ollama updated** — `curl -fsSL https://ollama.com/install.sh | sh` also updates.
6. **Monitor logs** — Watch for unusual request patterns.

### Example: Nginx Reverse Proxy with Basic Auth

```nginx
server {
    listen 443 ssl;
    server_name ollama.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/ollama.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ollama.yourdomain.com/privkey.pem;

    auth_basic "Ollama Server";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://127.0.0.1:11434;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;

        # Required for streaming
        proxy_buffering off;
        chunked_transfer_encoding on;
    }
}
```

---

## Troubleshooting Server Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Connection refused from remote | Bound to localhost | Set `OLLAMA_HOST=0.0.0.0:11434` |
| Port not open | Firewall blocking | Open port 11434 in UFW/iptables |
| Service won't start | Port conflict | Check `ss -tlnp \| grep 11434` |
| GPU not detected | Missing drivers | See [GPU Setup](11-gpu-setup.md) |
| Models missing after reboot | Wrong model path | Check `OLLAMA_MODELS` and permissions |
| Slow inference | CPU-only mode | Verify GPU with `ollama ps` |

---

## Next Steps

→ [Remote Access](10-remote-access.md) — Connect your Mac (or any client) to this server.
