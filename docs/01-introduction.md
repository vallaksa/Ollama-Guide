# Introduction to Ollama

> **Ollama makes running large language models locally as simple as a single command.**

---

## What Is Ollama?

Ollama is an open-source tool that lets you **run large language models (LLMs) locally** on your own hardware. Instead of sending your prompts to a cloud API, everything runs on your machine — your data never leaves your computer.

### Key Features

| Feature | Description |
|---------|-------------|
| **Local inference** | Run models entirely on your hardware — no internet required after download |
| **Simple CLI** | Pull and run models with two commands |
| **REST API** | Built-in HTTP API on port `11434` for programmatic access |
| **Model library** | Access to hundreds of models (Llama, Mistral, Gemma, Phi, and more) |
| **Custom models** | Create personalized models with Modelfile syntax |
| **GPU acceleration** | Automatic GPU detection (NVIDIA CUDA, AMD ROCm, Apple Metal) |
| **Cross-platform** | macOS, Linux, and Windows support |
| **Lightweight** | Single binary, no Python environments or complex dependencies |

---

## Architecture Overview

Ollama uses a **client-server architecture**. When you run any `ollama` command, a client communicates with the Ollama server over HTTP.

```
┌─────────────────────────────────────────────────────┐
│                    Your Machine                      │
│                                                      │
│  ┌──────────┐      HTTP :11434      ┌─────────────┐ │
│  │ Ollama   │ ──────────────────▶  │   Ollama     │ │
│  │ CLI      │                       │   Server     │ │
│  └──────────┘                       │              │ │
│                                     │  ┌─────────┐ │ │
│  ┌──────────┐                       │  │ Model   │ │ │
│  │ Your App │ ──────────────────▶  │  │ Runner  │ │ │
│  │ (curl,   │      HTTP :11434      │  └────┬────┘ │ │
│  │  Python, │                       │       │      │ │
│  │  JS)     │                       │  ┌────▼────┐ │ │
│  └──────────┘                       │  │ GPU /   │ │ │
│                                     │  │ CPU     │ │ │
│                                     │  └─────────┘ │ │
│                                     └─────────────┘ │
│                                                      │
│  ~/.ollama/models/   ◄── Model storage               │
└─────────────────────────────────────────────────────┘
```

### How It Works (Step by Step)

1. **Server starts** — `ollama serve` launches the HTTP server on port `11434`.
2. **Client sends request** — The CLI (or any HTTP client) sends a request to the server.
3. **Model loads** — The server loads the requested model into memory (GPU or CPU).
4. **Inference runs** — The model processes your prompt and streams tokens back.
5. **Model stays warm** — The model remains in memory (default: 5 minutes) for fast follow-up requests.

> **📝 Note:** The server auto-starts on macOS and when using `ollama run`. On Linux servers, you'll typically run it as a systemd service (see [Server Deployment](09-server-deployment.md)).

---

## Why Use Ollama?

### Privacy
Your prompts and data never leave your machine. No API keys, no cloud logging, no data retention policies to worry about.

### Cost
No per-token charges. Once a model is downloaded, you can run unlimited inference for free.

### Speed
Local inference eliminates network round-trips. With a decent GPU, response times are often faster than cloud APIs.

### Offline Capability
After the initial model download, everything works offline — perfect for air-gapped environments, travel, or unreliable connections.

### Customization
Create custom models with system prompts, parameter tuning, and adapter layers using [Modelfiles](07-modelfile.md).

---

## Ollama vs. Alternatives

| Feature | Ollama | llama.cpp | LM Studio | vLLM |
|---------|--------|-----------|-----------|------|
| Ease of setup | ⭐⭐⭐ One command | ⭐ Compile from source | ⭐⭐⭐ GUI installer | ⭐⭐ pip install |
| CLI interface | ✅ Built-in | ✅ Basic | ❌ GUI only | ❌ Server only |
| REST API | ✅ Built-in | ⚠️ Optional server | ✅ Built-in | ✅ OpenAI-compatible |
| Model management | ✅ Pull/push/list | ❌ Manual files | ✅ GUI browser | ❌ Manual |
| GPU support | ✅ Auto-detect | ✅ Manual config | ✅ Auto-detect | ✅ CUDA only |
| Custom models | ✅ Modelfile | ⚠️ CLI args | ⚠️ Limited | ⚠️ Limited |
| Production server | ✅ systemd ready | ⚠️ Manual | ❌ Desktop only | ✅ Designed for it |

---

## System Requirements

### Minimum
- **RAM:** 8 GB (for 7B parameter models)
- **Storage:** 4–8 GB per model (varies by quantization)
- **OS:** macOS 12+, Linux (glibc 2.31+), Windows 10+

### Recommended
- **RAM:** 16+ GB
- **GPU:** NVIDIA with 8+ GB VRAM, Apple Silicon (M1 or later), or AMD with ROCm support
- **Storage:** SSD with 50+ GB free space for multiple models

> **💡 Tip:** A rough rule of thumb — you need approximately 1 GB of RAM/VRAM per billion parameters at 4-bit quantization. A 7B model needs ~4–5 GB, a 13B model needs ~8–10 GB, and a 70B model needs ~40+ GB.

---

## Next Steps

→ [Installation](02-installation.md) — Get Ollama installed on your system.
