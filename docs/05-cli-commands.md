# CLI Commands

> **Complete reference for every Ollama command-line command.**

---

## Command Overview

| Command | Description |
|---------|-------------|
| `ollama serve` | Start the Ollama server |
| `ollama pull` | Download a model from the registry |
| `ollama push` | Push a model to the registry |
| `ollama run` | Run a model (auto-pulls if needed) |
| `ollama create` | Create a model from a Modelfile |
| `ollama list` | List locally available models |
| `ollama show` | Show model details |
| `ollama cp` | Copy/rename a model |
| `ollama rm` | Remove a model |
| `ollama ps` | Show running models |
| `ollama stop` | Stop a running model |
| `ollama help` | Show help information |

---

## `ollama serve`

Start the Ollama HTTP server.

```bash
ollama serve
```

The server binds to `127.0.0.1:11434` by default. Override with `OLLAMA_HOST`:
```bash
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

> **📝 Note:** On macOS, the server starts automatically with the app. On Linux, it typically runs as a systemd service.

---

## `ollama pull`

Download a model from the [Ollama library](https://ollama.com/library).

```bash
# Pull the default (latest) version
ollama pull llama3.2

# Pull a specific size variant
ollama pull llama3.2:1b

# Pull a specific quantization
ollama pull llama3.2:7b-q4_0

# Pull with verbose progress
ollama pull mistral --verbose
```

### Pull from a Registry

```bash
# Pull from a custom registry
ollama pull myregistry.com/namespace/model
```

> **💡 Tip:** `ollama run <model>` automatically pulls the model if it's not already downloaded — so you can skip the explicit pull for quick testing.

---

## `ollama push`

Push a local model to a registry.

```bash
# Push to the Ollama registry (requires authentication)
ollama push myusername/my-custom-model
```

You must first create the model with `ollama create` and be logged in with an Ollama.com account.

---

## `ollama run`

Run a model interactively. If the model isn't downloaded, it's pulled first.

```bash
# Start interactive chat
ollama run llama3.2

# Pass a single prompt (non-interactive)
ollama run llama3.2 "Explain recursion in one sentence"

# Pipe input
echo "Summarize this text" | ollama run llama3.2

# With a file as context
ollama run llama3.2 "Explain this code:" < main.py
```

### Runtime Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--verbose` | Show timing statistics | `ollama run llama3.2 --verbose` |
| `--nowordwrap` | Disable word wrapping | `ollama run llama3.2 --nowordwrap` |
| `--format json` | Force JSON output | `ollama run llama3.2 --format json "List 3 colors"` |
| `--keepalive` | Override keep-alive duration | `ollama run llama3.2 --keepalive 10m` |

### Interactive Chat Commands

Once inside a chat session:

| Command | Description |
|---------|-------------|
| `/bye` | Exit the chat |
| `/set parameter <name> <value>` | Adjust a model parameter |
| `/show info` | Display model information |
| `/show license` | Display model license |
| `/show modelfile` | Display the model's Modelfile |
| `/show parameters` | Display current parameters |
| `/show system` | Display the system prompt |
| `/show template` | Display the prompt template |
| `/clear` | Clear conversation context |
| `/load <model>` | Switch to a different model |
| `/save <model>` | Save current session as a model |
| `"""` | Toggle multi-line input mode |
| `/?` or `/help` | Show help |

---

## `ollama create`

Create a custom model from a [Modelfile](07-modelfile.md).

```bash
# Create from a Modelfile in the current directory
ollama create my-model -f ./Modelfile

# Create with quantization
ollama create my-model -f ./Modelfile --quantize q4_0
```

### Quantization Options

| Format | Description |
|--------|-------------|
| `q4_0` | 4-bit quantization, smaller, faster |
| `q4_1` | 4-bit quantization, slightly better quality |
| `q5_0` | 5-bit quantization, balanced |
| `q5_1` | 5-bit quantization, slightly better quality |
| `q8_0` | 8-bit quantization, highest quality |

---

## `ollama list`

List all locally available models.

```bash
ollama list
```

Output:
```
NAME              ID            SIZE      MODIFIED
llama3.2:latest   a6990ed6be41  2.0 GB    2 hours ago
mistral:latest    f974a74358d6  4.1 GB    1 day ago
codellama:7b      8fdf8f752f6e  3.8 GB    3 days ago
```

### List Running Models
```bash
ollama ps
```

Output:
```
NAME            ID            SIZE      PROCESSOR    UNTIL
llama3.2:latest a6990ed6be41  5.3 GB    100% GPU     4 minutes from now
```

---

## `ollama show`

Display detailed information about a model.

```bash
# Show model info summary
ollama show llama3.2

# Show specific sections
ollama show llama3.2 --modelfile     # Modelfile contents
ollama show llama3.2 --parameters    # Model parameters
ollama show llama3.2 --system        # System prompt
ollama show llama3.2 --template      # Prompt template
ollama show llama3.2 --license       # License text
```

---

## `ollama cp`

Copy (duplicate) a model under a new name.

```bash
ollama cp llama3.2 my-llama

# Verify
ollama list
```

> **📝 Note:** This creates a new reference to the same model weights — it doesn't duplicate the files, so it uses negligible extra disk space.

---

## `ollama rm`

Remove a downloaded model.

```bash
ollama rm llama3.2
```

Output:
```
deleted 'llama3.2'
```

> **⚠️ Warning:** This permanently deletes the model files. You'll need to `ollama pull` again to re-download.

---

## `ollama ps`

Show currently loaded/running models.

```bash
ollama ps
```

Output:
```
NAME            ID            SIZE      PROCESSOR    UNTIL
llama3.2:latest a6990ed6be41  5.3 GB    100% GPU     4 minutes from now
mistral:latest  f974a74358d6  6.8 GB    50% GPU/50% CPU  2 minutes from now
```

### Understanding the Output

| Column | Description |
|--------|-------------|
| **NAME** | Model name and tag |
| **SIZE** | Memory footprint (VRAM + RAM) |
| **PROCESSOR** | Where the model is running (GPU, CPU, or split) |
| **UNTIL** | When the model will be unloaded (based on keep-alive) |

---

## `ollama stop`

Force-unload a model from memory.

```bash
ollama stop llama3.2
```

This immediately frees the memory. Useful when switching between large models.

---

## `ollama help`

Show help for any command.

```bash
# General help
ollama help

# Help for a specific command
ollama help run
ollama help create
```

---

## Cheat Sheet

```bash
# Install and first run
curl -fsSL https://ollama.com/install.sh | sh
ollama run llama3.2

# Model management
ollama pull mistral         # Download
ollama list                 # List all models
ollama show mistral         # Inspect
ollama cp mistral my-model  # Duplicate
ollama rm my-model          # Delete

# Monitoring
ollama ps                   # Running models
ollama stop llama3.2        # Unload model

# Advanced
ollama create custom -f Modelfile  # Create custom model
ollama push user/model             # Push to registry
```

---

## Next Steps

→ [Available Models](06-available-models.md) — Browse the full model catalog.
