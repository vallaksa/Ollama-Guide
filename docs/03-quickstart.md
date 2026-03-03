# Quickstart

> **From zero to chatting with an AI in under 5 minutes.**

---

## Prerequisites

- Ollama installed ([Installation Guide](02-installation.md))
- At least 4 GB of free RAM (8 GB recommended)
- ~4 GB free disk space for your first model

---

## Step 1: Start the Server

On **macOS** and **Windows**, the server starts automatically when you launch the Ollama app.

On **Linux**, it runs as a systemd service:
```bash
# Check if it's running
sudo systemctl status ollama

# If not, start it
sudo systemctl start ollama
```

To start manually (any platform):
```bash
ollama serve
```

> **📝 Note:** The server listens on `http://localhost:11434` by default. You can verify it's running:
> ```bash
> curl http://localhost:11434
> ```
> Response: `Ollama is running`

---

## Step 2: Pull a Model

Download a model from the [Ollama model library](https://ollama.com/library):

```bash
ollama pull llama3.2
```

Output:
```
pulling manifest
pulling 00e1317cbf74... 100% ▕████████████████▏ 2.0 GB
pulling 4fa551d4f938... 100% ▕████████████████▏  12 KB
pulling 8ab4849b038c... 100% ▕████████████████▏  254 B
pulling 577073ffcc6c... 100% ▕████████████████▏  110 B
pulling ad1518640c43... 100% ▕████████████████▏  483 B
verifying sha256 digest
writing manifest
success
```

### Recommended Starter Models

| Model | Size | Best For |
|-------|------|----------|
| `llama3.2` | ~2 GB | General chat, fast responses |
| `llama3.2:1b` | ~1.3 GB | Lightweight, resource-constrained systems |
| `mistral` | ~4.1 GB | Strong reasoning, good balance |
| `phi3` | ~2.3 GB | Compact but capable, Microsoft |
| `gemma2:2b` | ~1.6 GB | Google's lightweight model |

---

## Step 3: Chat with a Model

### Interactive Chat
```bash
ollama run llama3.2
```

This opens an interactive chat session:
```
>>> What is the capital of France?
The capital of France is Paris. It's located in the north-central part of the
country along the Seine River.

>>> Tell me a fun fact about Paris
The Eiffel Tower was originally intended to be a temporary structure! It was
built for the 1889 World's Fair and was supposed to be dismantled after 20 years.

>>> /bye
```

### Useful Chat Commands

| Command | Description |
|---------|-------------|
| `/bye` | Exit the chat |
| `/set parameter temperature 0.8` | Adjust creativity (0.0–2.0) |
| `/set parameter num_ctx 4096` | Set context window size |
| `/show info` | Display model details |
| `/clear` | Clear chat context |
| `"""` | Begin/end multi-line input |

---

## Step 4: Generate via API

Ollama's REST API lets you integrate with any application:

### Single-Shot Generate
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Explain Docker in one sentence.",
  "stream": false
}'
```

Response:
```json
{
  "model": "llama3.2",
  "response": "Docker is a platform that packages applications and their dependencies into lightweight, portable containers that can run consistently across any environment.",
  "done": true,
  "total_duration": 1234567890
}
```

### Chat with Conversation History
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [
    {"role": "user", "content": "What is Kubernetes?"},
    {"role": "assistant", "content": "Kubernetes is a container orchestration platform."},
    {"role": "user", "content": "How does it relate to Docker?"}
  ],
  "stream": false
}'
```

> **📝 Note:** Set `"stream": true` (or omit it) to receive tokens as they're generated — great for real-time UIs.

---

## Step 5: List & Manage Models

```bash
# List downloaded models
ollama list
```

Output:
```
NAME              ID            SIZE      MODIFIED
llama3.2:latest   a6990ed6be41  2.0 GB    2 minutes ago
mistral:latest    f974a74358d6  4.1 GB    5 minutes ago
```

```bash
# Show model details
ollama show llama3.2

# Remove a model
ollama rm llama3.2

# Copy/rename a model
ollama cp llama3.2 my-llama
```

---

## What's Next?

Now that you're up and running, explore:

| Guide | What You'll Learn |
|-------|-------------------|
| [Configuration](04-configuration.md) | Customize port, storage, and behavior |
| [CLI Commands](05-cli-commands.md) | Master every command |
| [Available Models](06-available-models.md) | Browse the full model catalog |
| [API Reference](08-api-reference.md) | Build applications with the REST API |
| [Server Deployment](09-server-deployment.md) | Run Ollama on a remote server |
