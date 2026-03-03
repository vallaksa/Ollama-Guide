# API Reference

> **Ollama exposes a REST API on port `11434` for programmatic access to all model operations.**

---

## Base URL

```
http://localhost:11434
```

Override with the `OLLAMA_HOST` environment variable. All endpoints accept and return JSON.

---

## Health Check

```bash
curl http://localhost:11434
```

Response:
```
Ollama is running
```

---

## Generate Completion — `POST /api/generate`

Generate a response for a given prompt (single-turn).

### Request

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Explain Docker in one sentence.",
  "stream": false
}'
```

### Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `model` | string | ✅ | Model name |
| `prompt` | string | ✅ | The prompt to generate a response for |
| `stream` | bool | ❌ | Stream response tokens (default: `true`) |
| `images` | string[] | ❌ | Base64-encoded images (for multimodal models) |
| `system` | string | ❌ | Override the system prompt |
| `template` | string | ❌ | Override the prompt template |
| `context` | int[] | ❌ | Context from a previous response (for follow-ups) |
| `format` | string | ❌ | Response format: `"json"` for JSON output |
| `raw` | bool | ❌ | Skip prompt formatting (send raw text) |
| `keep_alive` | string | ❌ | Override keep-alive duration (e.g., `"10m"`, `"-1"`) |
| `options` | object | ❌ | Model parameters (temperature, top_p, etc.) |

### Options Object

```json
{
  "options": {
    "temperature": 0.7,
    "top_p": 0.9,
    "top_k": 40,
    "num_ctx": 4096,
    "num_predict": 256,
    "repeat_penalty": 1.1,
    "seed": 42,
    "stop": ["<|end|>"]
  }
}
```

### Response (Non-Streaming)

```json
{
  "model": "llama3.2",
  "created_at": "2024-01-01T00:00:00Z",
  "response": "Docker is a platform that packages applications into containers.",
  "done": true,
  "context": [1, 2, 3],
  "total_duration": 1234567890,
  "load_duration": 123456789,
  "prompt_eval_count": 15,
  "prompt_eval_duration": 123456789,
  "eval_count": 42,
  "eval_duration": 987654321
}
```

### Response (Streaming)

When `stream: true` (default), the response is a series of JSON objects:

```json
{"model":"llama3.2","response":"Docker","done":false}
{"model":"llama3.2","response":" is","done":false}
{"model":"llama3.2","response":" a","done":false}
...
{"model":"llama3.2","response":"","done":true,"total_duration":1234567890}
```

### Timing Fields

| Field | Description |
|-------|-------------|
| `total_duration` | Total time (nanoseconds) |
| `load_duration` | Time to load model (nanoseconds) |
| `prompt_eval_count` | Number of tokens in the prompt |
| `prompt_eval_duration` | Time to evaluate the prompt (nanoseconds) |
| `eval_count` | Number of generated tokens |
| `eval_duration` | Time to generate the response (nanoseconds) |

> **💡 Tip:** Tokens per second = `eval_count / eval_duration * 1e9`

---

## Chat — `POST /api/chat`

Generate a chat response with message history (multi-turn).

### Request

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is the capital of France?"},
    {"role": "assistant", "content": "The capital of France is Paris."},
    {"role": "user", "content": "What is its population?"}
  ],
  "stream": false
}'
```

### Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `model` | string | ✅ | Model name |
| `messages` | object[] | ✅ | Array of message objects |
| `stream` | bool | ❌ | Stream response (default: `true`) |
| `format` | string | ❌ | `"json"` for JSON output |
| `keep_alive` | string | ❌ | Override keep-alive |
| `options` | object | ❌ | Model parameters |
| `tools` | object[] | ❌ | Tool/function definitions for tool calling |

### Message Object

| Field | Type | Description |
|-------|------|-------------|
| `role` | string | `"system"`, `"user"`, or `"assistant"` |
| `content` | string | Message content |
| `images` | string[] | Base64-encoded images (multimodal) |

### Response

```json
{
  "model": "llama3.2",
  "created_at": "2024-01-01T00:00:00Z",
  "message": {
    "role": "assistant",
    "content": "The population of Paris is approximately 2.1 million."
  },
  "done": true,
  "total_duration": 1234567890,
  "eval_count": 28,
  "eval_duration": 987654321
}
```

---

## Embeddings — `POST /api/embed`

Generate vector embeddings for text.

### Request

```bash
curl http://localhost:11434/api/embed -d '{
  "model": "nomic-embed-text",
  "input": "The quick brown fox jumps over the lazy dog"
}'
```

### With Multiple Inputs

```bash
curl http://localhost:11434/api/embed -d '{
  "model": "nomic-embed-text",
  "input": [
    "First document text",
    "Second document text",
    "Third document text"
  ]
}'
```

### Response

```json
{
  "model": "nomic-embed-text",
  "embeddings": [
    [0.123, -0.456, 0.789, ...]
  ],
  "total_duration": 123456789,
  "load_duration": 12345678,
  "prompt_eval_count": 8
}
```

---

## List Models — `GET /api/tags`

List all locally available models.

```bash
curl http://localhost:11434/api/tags
```

### Response

```json
{
  "models": [
    {
      "name": "llama3.2:latest",
      "model": "llama3.2:latest",
      "modified_at": "2024-01-01T00:00:00Z",
      "size": 2000000000,
      "digest": "a6990ed6be41...",
      "details": {
        "parent_model": "",
        "format": "gguf",
        "family": "llama",
        "families": ["llama"],
        "parameter_size": "3.2B",
        "quantization_level": "Q4_0"
      }
    }
  ]
}
```

---

## Show Model Info — `POST /api/show`

Get detailed information about a model.

```bash
curl http://localhost:11434/api/show -d '{
  "name": "llama3.2"
}'
```

### Response

```json
{
  "modelfile": "FROM llama3.2\nPARAMETER temperature 0.8...",
  "parameters": "temperature 0.8\ntop_p 0.9...",
  "template": "{{ .System }}\n{{ .Prompt }}",
  "details": {
    "parent_model": "",
    "format": "gguf",
    "family": "llama",
    "parameter_size": "3.2B",
    "quantization_level": "Q4_0"
  },
  "model_info": {
    "general.architecture": "llama",
    "general.parameter_count": 3200000000,
    "llama.context_length": 8192
  }
}
```

---

## Pull Model — `POST /api/pull`

Download a model from the registry.

```bash
curl http://localhost:11434/api/pull -d '{
  "name": "llama3.2",
  "stream": true
}'
```

### Streaming Response

```json
{"status":"pulling manifest"}
{"status":"pulling a6990ed6be41","digest":"sha256:a6990ed6be41...","total":2000000000,"completed":500000000}
{"status":"pulling a6990ed6be41","digest":"sha256:a6990ed6be41...","total":2000000000,"completed":2000000000}
{"status":"verifying sha256 digest"}
{"status":"writing manifest"}
{"status":"success"}
```

---

## Push Model — `POST /api/push`

Push a model to the registry.

```bash
curl http://localhost:11434/api/push -d '{
  "name": "myusername/my-model",
  "stream": true
}'
```

---

## Create Model — `POST /api/create`

Create a custom model from a Modelfile.

```bash
curl http://localhost:11434/api/create -d '{
  "name": "my-custom-model",
  "modelfile": "FROM llama3.2\nSYSTEM You are a helpful assistant.\nPARAMETER temperature 0.7",
  "stream": true
}'
```

> **📝 Note:** The `modelfile` field contains the Modelfile content as a string (with `\n` for newlines).

---

## Copy Model — `POST /api/copy`

Duplicate a model under a new name.

```bash
curl http://localhost:11434/api/copy -d '{
  "source": "llama3.2",
  "destination": "my-llama"
}'
```

Returns `200 OK` on success (no body).

---

## Delete Model — `DELETE /api/delete`

Remove a model.

```bash
curl -X DELETE http://localhost:11434/api/delete -d '{
  "name": "my-llama"
}'
```

Returns `200 OK` on success (no body).

---

## List Running Models — `GET /api/ps`

Show models currently loaded in memory.

```bash
curl http://localhost:11434/api/ps
```

### Response

```json
{
  "models": [
    {
      "name": "llama3.2:latest",
      "model": "llama3.2:latest",
      "size": 5300000000,
      "digest": "a6990ed6be41...",
      "details": {
        "family": "llama",
        "parameter_size": "3.2B",
        "quantization_level": "Q4_0"
      },
      "expires_at": "2024-01-01T00:05:00Z",
      "size_vram": 5300000000
    }
  ]
}
```

---

## Error Handling

All endpoints return standard HTTP status codes:

| Status | Meaning |
|--------|---------|
| `200` | Success |
| `400` | Bad request (invalid parameters) |
| `404` | Model not found |
| `500` | Internal server error |

Error response format:
```json
{
  "error": "model 'nonexistent' not found, try pulling it first"
}
```

---

## Quick Reference Table

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check |
| `/api/generate` | POST | Single-turn completion |
| `/api/chat` | POST | Multi-turn chat |
| `/api/embed` | POST | Generate embeddings |
| `/api/tags` | GET | List local models |
| `/api/show` | POST | Model info |
| `/api/pull` | POST | Download model |
| `/api/push` | POST | Upload model |
| `/api/create` | POST | Create custom model |
| `/api/copy` | POST | Duplicate model |
| `/api/delete` | DELETE | Remove model |
| `/api/ps` | GET | Running models |

---

## Next Steps

→ [Server Deployment](09-server-deployment.md) — Deploy Ollama on a remote server.
