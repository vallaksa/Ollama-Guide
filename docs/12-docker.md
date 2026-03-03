# Docker

> **Run Ollama in Docker containers — CPU-only, GPU-accelerated, and with Docker Compose.**

---

## Quick Start

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

### With AMD GPU (ROCm)

```bash
docker run -d \
  --name ollama \
  --device /dev/kfd \
  --device /dev/dri \
  -p 11434:11434 \
  -v ollama_data:/root/.ollama \
  ollama/ollama:rocm
```

---

## Prerequisites

### For CPU-Only
- Docker Engine 20.10+
- At least 8 GB RAM

### For NVIDIA GPU
- NVIDIA GPU with CUDA support
- NVIDIA drivers installed on host
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

Install the container toolkit:
```bash
# Add repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit

# Configure and restart Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

### For AMD GPU
- AMD GPU with ROCm support
- ROCm drivers installed on host
- Use the `ollama/ollama:rocm` image

---

## Docker Run Options

### Full Example with All Options

```bash
docker run -d \
  --name ollama \
  --gpus all \
  --restart unless-stopped \
  -p 11434:11434 \
  -v ollama_data:/root/.ollama \
  -e OLLAMA_HOST=0.0.0.0:11434 \
  -e OLLAMA_KEEP_ALIVE=10m \
  -e OLLAMA_NUM_PARALLEL=4 \
  -e OLLAMA_ORIGINS="*" \
  ollama/ollama
```

### Flag Reference

| Flag | Description |
|------|-------------|
| `-d` | Run detached (in background) |
| `--name ollama` | Container name |
| `--gpus all` | Pass all GPUs (NVIDIA only) |
| `--gpus '"device=0"'` | Pass specific GPU |
| `--restart unless-stopped` | Auto-restart on crash/reboot |
| `-p 11434:11434` | Map host port to container port |
| `-v ollama_data:/root/.ollama` | Persist model data |
| `-e KEY=VALUE` | Set environment variables |

---

## Docker Compose

### CPU Only

Create `docker-compose.yml`:

```yaml
services:
  ollama:
    image: ollama/ollama
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
      - OLLAMA_KEEP_ALIVE=10m
    restart: unless-stopped

volumes:
  ollama_data:
```

### With NVIDIA GPU

```yaml
services:
  ollama:
    image: ollama/ollama
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
      - OLLAMA_KEEP_ALIVE=10m
      - NVIDIA_VISIBLE_DEVICES=all
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

volumes:
  ollama_data:
```

### With AMD GPU (ROCm)

```yaml
services:
  ollama:
    image: ollama/ollama:rocm
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    devices:
      - /dev/kfd
      - /dev/dri
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
    restart: unless-stopped

volumes:
  ollama_data:
```

### Ollama + Open WebUI

Full stack with a web frontend:

```yaml
services:
  ollama:
    image: ollama/ollama
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    volumes:
      - open_webui_data:/app/backend/data
    depends_on:
      - ollama
    restart: unless-stopped

volumes:
  ollama_data:
  open_webui_data:
```

### Commands

```bash
# Start
docker compose up -d

# View logs
docker compose logs -f ollama

# Stop
docker compose down

# Stop and remove volumes (deletes models!)
docker compose down -v
```

---

## Working with Models in Docker

```bash
# Pull a model inside the container
docker exec -it ollama ollama pull llama3.2

# Run a model interactively
docker exec -it ollama ollama run llama3.2

# List models
docker exec -it ollama ollama list

# Or use the API from the host
curl http://localhost:11434/api/tags
```

---

## Volume Management

### Using Named Volumes (Recommended)

```bash
# Models persist in the named volume
docker volume inspect ollama_data
```

### Using Bind Mounts

```bash
# Map to a specific host directory
docker run -d \
  --name ollama \
  -p 11434:11434 \
  -v /path/on/host/ollama:/root/.ollama \
  ollama/ollama
```

### Backing Up Models

```bash
# Export the volume
docker run --rm -v ollama_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/ollama-models-backup.tar.gz -C /data .

# Import to a new volume
docker volume create ollama_data_new
docker run --rm -v ollama_data_new:/data -v $(pwd):/backup \
  alpine tar xzf /backup/ollama-models-backup.tar.gz -C /data
```

---

## Networking

### Expose to LAN

```bash
# Expose on all interfaces
docker run -d \
  --name ollama \
  -p 0.0.0.0:11434:11434 \
  -e OLLAMA_HOST=0.0.0.0:11434 \
  ollama/ollama
```

### Container-to-Container Communication

In Docker Compose, services communicate by name:
```bash
# From another container in the same compose file:
curl http://ollama:11434/api/generate -d '{"model":"llama3.2","prompt":"hi","stream":false}'
```

### Custom Network

```bash
docker network create ollama-net

docker run -d --name ollama --network ollama-net -p 11434:11434 ollama/ollama

docker run -d --name my-app --network ollama-net my-app-image
# my-app can reach Ollama at http://ollama:11434
```

---

## Resource Limits

```yaml
# In Docker Compose
services:
  ollama:
    image: ollama/ollama
    deploy:
      resources:
        limits:
          memory: 16G
          cpus: "8"
        reservations:
          memory: 8G
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

---

## Troubleshooting Docker

| Issue | Cause | Fix |
|-------|-------|-----|
| `--gpus` flag not recognized | Container toolkit missing | Install NVIDIA Container Toolkit |
| GPU not visible in container | Driver mismatch | Update host drivers, rebuild container |
| Models disappear after restart | No volume mount | Add `-v ollama_data:/root/.ollama` |
| Port already in use | Host port occupied | Use `-p 11435:11434` or stop the conflicting service |
| Permission denied | Volume ownership | Run as root or fix volume permissions |
| Slow performance | CPU-only mode | Verify GPU with `docker exec ollama ollama ps` |
| Can't connect from host | OLLAMA_HOST not set | Set `-e OLLAMA_HOST=0.0.0.0:11434` |

---

## Next Steps

→ [Troubleshooting](13-troubleshooting.md) — Solutions for common Ollama issues.
