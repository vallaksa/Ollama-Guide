# GPU Setup

> **Configure GPU acceleration for maximum inference performance on NVIDIA, AMD, and Apple Silicon.**

---

## Overview

GPU acceleration dramatically improves inference speed — often **10–50x faster** than CPU-only. Ollama auto-detects GPUs when drivers are properly installed.

| Platform | GPU | Framework | Setup Required |
|----------|-----|-----------|---------------|
| macOS | Apple Silicon (M1–M4) | Metal | ✅ None (automatic) |
| Linux | NVIDIA | CUDA | ⚠️ Driver + toolkit needed |
| Linux | AMD | ROCm | ⚠️ Driver + toolkit needed |
| Windows | NVIDIA | CUDA | ✅ Minimal (driver only) |
| Windows | AMD | DirectML | ✅ Minimal (driver only) |

---

## Apple Silicon (macOS)

### No Setup Required

Apple Silicon Macs (M1, M2, M3, M4 and their Pro/Max/Ultra variants) use **Metal** for GPU acceleration automatically. Ollama leverages the unified memory architecture.

### Verify GPU Is Active

```bash
ollama run llama3.2 --verbose
```

Look for the timing statistics — you should see fast token generation.

```bash
# Check loaded models and processor type
ollama ps
```

Output should show `100% GPU`:
```
NAME            ID            SIZE      PROCESSOR    UNTIL
llama3.2:latest a6990ed6be41  5.3 GB    100% GPU     4 minutes from now
```

### Memory Considerations

Apple Silicon uses **unified memory** (shared between CPU and GPU). Available VRAM ≈ total system RAM minus OS overhead.

| Mac | RAM | Usable for Models |
|-----|-----|-------------------|
| M1/M2 (8 GB) | 8 GB | ~5–6 GB |
| M1/M2 Pro (16 GB) | 16 GB | ~12–13 GB |
| M1/M2 Max (32 GB) | 32 GB | ~28–29 GB |
| M2/M3 Max (64 GB) | 64 GB | ~58–60 GB |
| M2/M3 Ultra (128 GB) | 128 GB | ~120+ GB |
| M4 Max (128 GB) | 128 GB | ~120+ GB |

---

## NVIDIA GPU (Linux)

### Step 1: Install NVIDIA Drivers

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y nvidia-driver-550

# Or use the NVIDIA repository for latest drivers
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt update
sudo apt install -y nvidia-driver-550

# RHEL/CentOS/Fedora
sudo dnf install -y nvidia-driver
```

Reboot after installation:
```bash
sudo reboot
```

### Step 2: Verify Driver Installation

```bash
nvidia-smi
```

Expected output:
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 550.xx       Driver Version: 550.xx       CUDA Version: 12.x    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  NVIDIA RTX 4090    Off   | 00000000:01:00.0 Off |                  Off |
|  0%   30C    P8    15W / 450W |     0MiB / 24564MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
```

### Step 3: Install CUDA Toolkit (If Needed)

Ollama bundles its own CUDA libraries, so you typically **don't need** to install the full CUDA toolkit. However, if needed:

```bash
# Ubuntu/Debian
sudo apt install -y nvidia-cuda-toolkit

# Verify
nvcc --version
```

### Step 4: Verify Ollama GPU Detection

```bash
# Restart Ollama to detect GPU
sudo systemctl restart ollama

# Pull and run a model
ollama run llama3.2

# Check GPU usage
ollama ps
```

GPU memory usage should show in `nvidia-smi`:
```bash
watch -n 1 nvidia-smi
```

---

## NVIDIA GPU (Docker)

To use GPUs inside Docker containers, install the **NVIDIA Container Toolkit**:

```bash
# Add NVIDIA repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Install
sudo apt update
sudo apt install -y nvidia-container-toolkit

# Configure Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Run Ollama with GPU in Docker

```bash
docker run -d \
  --name ollama \
  --gpus all \
  -p 11434:11434 \
  -v ollama_data:/root/.ollama \
  ollama/ollama
```

See [Docker](12-docker.md) for full Docker setup details.

---

## AMD GPU (Linux)

### Step 1: Install ROCm

```bash
# Ubuntu 22.04/24.04
sudo apt update
sudo apt install -y "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"

# Add ROCm repository
wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/latest jammy main" | \
  sudo tee /etc/apt/sources.list.d/rocm.list

sudo apt update
sudo apt install -y rocm
```

Reboot:
```bash
sudo reboot
```

### Step 2: Add User to Video/Render Groups

```bash
sudo usermod -aG video $USER
sudo usermod -aG render $USER
```

Log out and back in for group changes to take effect.

### Step 3: Verify ROCm

```bash
rocm-smi
```

### Step 4: Verify Ollama GPU Detection

```bash
sudo systemctl restart ollama
ollama run llama3.2

# Check GPU usage
ollama ps
rocm-smi
```

### Supported AMD GPUs

Ollama supports AMD GPUs with ROCm compatibility:
- **RX 7000 series** (RDNA 3)
- **RX 6000 series** (RDNA 2)
- **Instinct MI series** (MI250, MI300, etc.)
- **Radeon Pro** series

> **📝 Note:** Consumer (RX) GPUs may need `HSA_OVERRIDE_GFX_VERSION` to work with ROCm. Check the [ROCm compatibility matrix](https://rocm.docs.amd.com/en/latest/release/gpu_os_support.html).

---

## Multi-GPU Setup

Ollama can distribute model layers across multiple GPUs automatically.

### NVIDIA Multi-GPU

```bash
# Use all available GPUs (default)
CUDA_VISIBLE_DEVICES=0,1 ollama serve

# Or use specific GPUs
CUDA_VISIBLE_DEVICES=0 ollama serve    # GPU 0 only
CUDA_VISIBLE_DEVICES=1 ollama serve    # GPU 1 only
```

### AMD Multi-GPU

```bash
HIP_VISIBLE_DEVICES=0,1 ollama serve
```

### Verify Multi-GPU

```bash
ollama ps
```

The SIZE column shows total memory across GPUs.

---

## VRAM Requirements

A rough guide for model sizes at Q4 quantization:

| Model Size | VRAM Needed | Example GPUs |
|-----------|-------------|-------------|
| 1–3B | 2–3 GB | GTX 1650, RX 6500 |
| 7B | 4–6 GB | RTX 3060, RX 6700 |
| 13B | 8–10 GB | RTX 4070, RX 7800 |
| 34B | 20–24 GB | RTX 4090, A5000 |
| 70B | 40–48 GB | 2x RTX 4090, A100 |

### When VRAM Isn't Enough

If a model is too large for your GPU, Ollama automatically splits between GPU and CPU:

```
PROCESSOR column in `ollama ps`:
- "100% GPU"       → Fully on GPU
- "50% GPU/50% CPU" → Split between GPU and CPU
- "100% CPU"        → No GPU used
```

> **💡 Tip:** Partial GPU offloading still provides significant speedup over pure CPU inference.

---

## Troubleshooting GPU Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `100% CPU` in `ollama ps` | GPU not detected | Check driver: `nvidia-smi` or `rocm-smi` |
| `nvidia-smi` not found | Driver not installed | Install NVIDIA drivers (Step 1) |
| `CUDA error` | Driver/CUDA mismatch | Update driver to latest |
| GPU detected but slow | Model too large for VRAM | Use smaller quantization or smaller model |
| `out of memory` | VRAM exhausted | Close other GPU apps, use smaller model |
| Docker: GPU not visible | Container toolkit missing | Install NVIDIA Container Toolkit |
| AMD: `HSA error` | GPU not in ROCm compatibility list | Set `HSA_OVERRIDE_GFX_VERSION` |

### Force CPU-Only Mode

If GPU causes issues, force CPU mode:

```bash
CUDA_VISIBLE_DEVICES="" ollama serve     # NVIDIA
HIP_VISIBLE_DEVICES="" ollama serve      # AMD
```

---

## Next Steps

→ [Docker](12-docker.md) — Run Ollama in Docker containers with GPU support.
