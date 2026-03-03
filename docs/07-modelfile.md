# Modelfile

> **Create custom models with tailored personalities, parameters, and behaviors.**

---

## What Is a Modelfile?

A Modelfile is a text file that defines how to create or customize a model in Ollama. Think of it as a `Dockerfile` but for LLMs — it specifies the base model, system prompt, parameters, and template.

---

## Basic Example

Create a file named `Modelfile`:

```dockerfile
# Use llama3.2 as the base model
FROM llama3.2

# Set a system prompt
SYSTEM """
You are a helpful coding assistant specializing in Python.
Always provide code examples with explanations.
Use type hints in all Python code.
"""

# Adjust parameters
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER num_ctx 4096
```

Build and run it:

```bash
# Create the model
ollama create python-assistant -f Modelfile

# Run it
ollama run python-assistant
```

---

## Modelfile Instructions

### `FROM` (Required)

Specifies the base model. Every Modelfile must start with a `FROM` instruction.

```dockerfile
# From a library model
FROM llama3.2
FROM mistral:7b
FROM codellama:13b

# From a local GGUF file
FROM ./my-model.gguf

# From a Safetensors directory
FROM ./model-directory/
```

### `SYSTEM`

Sets the system prompt that defines the model's behavior.

```dockerfile
# Single line
SYSTEM You are a helpful assistant that speaks like a pirate.

# Multi-line (use triple quotes)
SYSTEM """
You are a senior software engineer at a tech company.
You provide thorough, well-reasoned code reviews.
You always consider edge cases and performance implications.
When suggesting improvements, explain the reasoning behind each change.
"""
```

### `PARAMETER`

Tune model inference behavior.

```dockerfile
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER num_ctx 4096
PARAMETER repeat_penalty 1.1
PARAMETER stop "<|end|>"
PARAMETER seed 42
```

#### Parameter Reference

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `temperature` | 0.8 | 0.0–2.0 | Creativity/randomness. Lower = more focused, higher = more creative |
| `top_p` | 0.9 | 0.0–1.0 | Nucleus sampling. Consider tokens with cumulative probability ≤ top_p |
| `top_k` | 40 | 1–100 | Consider only the top K most likely tokens |
| `num_ctx` | 2048 | 1–131072 | Context window size (in tokens) |
| `num_predict` | -1 | -2 to ∞ | Max tokens to generate (-1 = infinite, -2 = fill context) |
| `repeat_penalty` | 1.1 | 0.0–2.0 | Penalty for repeating tokens |
| `repeat_last_n` | 64 | 0–num_ctx | How far back to check for repetition (0 = disabled) |
| `seed` | 0 | any int | Random seed (0 = random, fixed value = reproducible) |
| `stop` | (none) | string | Stop sequence(s) — generation stops when encountered |
| `tfs_z` | 1.0 | 0.0–2.0 | Tail-free sampling parameter (1.0 = disabled) |
| `mirostat` | 0 | 0, 1, 2 | Mirostat sampling (0 = disabled, 1 = v1, 2 = v2) |
| `mirostat_tau` | 5.0 | 0.0–10.0 | Mirostat target entropy |
| `mirostat_eta` | 0.1 | 0.0–1.0 | Mirostat learning rate |
| `num_gpu` | auto | 0–999 | Number of layers to offload to GPU |
| `num_thread` | auto | 1–N | Number of CPU threads |

### `TEMPLATE`

Define the prompt template using Go template syntax. This controls how messages are formatted before being sent to the model.

```dockerfile
TEMPLATE """
{{- if .System }}<|system|>
{{ .System }}<|end|>
{{ end }}
{{- range .Messages }}<|{{ .Role }}|>
{{ .Content }}<|end|>
{{ end }}<|assistant|>
"""
```

#### Template Variables

| Variable | Description |
|----------|-------------|
| `{{ .System }}` | System prompt content |
| `{{ .Prompt }}` | User prompt (generate endpoint) |
| `{{ .Response }}` | Model response (for training format) |
| `{{ .Messages }}` | Array of chat messages |
| `{{ .Message.Role }}` | Message role (system, user, assistant) |
| `{{ .Message.Content }}` | Message content |

### `ADAPTER`

Apply a LoRA or QLoRA adapter to the base model.

```dockerfile
FROM llama3.2
ADAPTER ./my-lora-adapter.gguf
```

### `LICENSE`

Specify the license for your custom model.

```dockerfile
LICENSE """
MIT License
Copyright (c) 2024 ...
"""
```

### `MESSAGE`

Pre-seed the conversation with example messages (few-shot prompting).

```dockerfile
MESSAGE user "What is 2+2?"
MESSAGE assistant "2+2 equals 4."

MESSAGE user "Explain what a variable is in programming."
MESSAGE assistant "A variable is a named container that stores a value in a program's memory. Think of it like a labeled box — the label is the variable name, and the contents are the value."
```

---

## Complete Examples

### Code Reviewer

```dockerfile
FROM llama3.1:8b

SYSTEM """
You are an expert code reviewer. When given code:
1. Identify bugs and potential issues
2. Suggest performance improvements
3. Check for security vulnerabilities
4. Recommend best practices
5. Rate the code quality (1-10)

Be constructive but thorough. Always explain WHY something is an issue.
"""

PARAMETER temperature 0.3
PARAMETER num_ctx 8192
PARAMETER top_p 0.85
```

### Creative Writer

```dockerfile
FROM mistral

SYSTEM """
You are an award-winning fiction writer. You craft vivid, engaging prose
with rich characters and compelling narratives. Your writing style is
literary but accessible. You show rather than tell.
"""

PARAMETER temperature 1.2
PARAMETER top_p 0.95
PARAMETER top_k 60
PARAMETER repeat_penalty 1.2
```

### Data Analyst

```dockerfile
FROM qwen2.5

SYSTEM """
You are a data analyst. You:
- Write SQL queries when asked about data
- Explain statistical concepts clearly
- Create data visualizations (describe them in detail)
- Always consider data quality and potential biases
- Format numbers with appropriate precision

When writing SQL, use standard SQL syntax unless told otherwise.
"""

PARAMETER temperature 0.2
PARAMETER num_ctx 4096
PARAMETER stop "```"

MESSAGE user "How would I find duplicate records in a users table?"
MESSAGE assistant "To find duplicate records based on email:

\`\`\`sql
SELECT email, COUNT(*) as count
FROM users
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY count DESC;
\`\`\`

This groups rows by email and filters for groups with more than one occurrence."
```

### JSON API Assistant

```dockerfile
FROM llama3.2

SYSTEM """
You are an API that responds only in valid JSON. Never include
explanatory text outside of JSON. Every response must be a valid
JSON object with appropriate keys.
"""

PARAMETER temperature 0.1
PARAMETER num_ctx 2048

MESSAGE user "List 3 programming languages"
MESSAGE assistant "{\"languages\": [\"Python\", \"JavaScript\", \"Go\"], \"count\": 3}"
```

---

## Workflow

```bash
# 1. Create your Modelfile
cat > Modelfile << 'EOF'
FROM llama3.2
SYSTEM "You are a helpful assistant."
PARAMETER temperature 0.7
EOF

# 2. Build the model
ollama create my-assistant -f Modelfile

# 3. Test it
ollama run my-assistant

# 4. Iterate — edit the Modelfile and rebuild
ollama create my-assistant -f Modelfile   # overwrites the previous version

# 5. Share (optional)
ollama push myusername/my-assistant
```

---

## Tips & Best Practices

- **Be specific in system prompts** — vague instructions lead to inconsistent behavior.
- **Use low temperature (0.1–0.4)** for factual/analytical tasks and higher (0.8–1.2) for creative tasks.
- **Set `num_ctx` appropriately** — larger context uses more memory but allows longer conversations.
- **Use `stop` sequences** to prevent the model from generating unwanted content.
- **Pre-seed with `MESSAGE`** for consistent output formats (few-shot prompting).
- **Test with edge cases** — try empty inputs, very long prompts, and adversarial inputs.

---

## Next Steps

→ [API Reference](08-api-reference.md) — Integrate Ollama into your applications with the REST API.
