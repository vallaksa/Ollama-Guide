# Available Models

> **A curated catalog of models available through Ollama, with sizes, use cases, and recommendations.**

---

## Browsing Models

The full, searchable model library is at **[ollama.com/library](https://ollama.com/library)**.

```bash
# Pull any model by name
ollama pull <model-name>

# Pull a specific variant
ollama pull <model-name>:<tag>
```

---

## Popular Models

### General Purpose (Chat & Reasoning)

| Model | Parameters | Size (Q4) | Developer | Best For |
|-------|-----------|-----------|-----------|----------|
| `llama3.2` | 3B | ~2.0 GB | Meta | Fast general chat, lightweight |
| `llama3.2:1b` | 1B | ~1.3 GB | Meta | Ultra-lightweight, edge devices |
| `llama3.1` | 8B | ~4.7 GB | Meta | Strong reasoning, versatile |
| `llama3.1:70b` | 70B | ~40 GB | Meta | Near-GPT-4 quality |
| `llama3.3` | 70B | ~43 GB | Meta | Latest Llama, best quality |
| `mistral` | 7B | ~4.1 GB | Mistral AI | Strong reasoning, balanced |
| `mixtral` | 8x7B | ~26 GB | Mistral AI | MoE architecture, expert-level |
| `gemma2` | 9B | ~5.4 GB | Google | High quality, well-rounded |
| `gemma2:2b` | 2B | ~1.6 GB | Google | Lightweight Google model |
| `phi3` | 3.8B | ~2.3 GB | Microsoft | Compact but powerful |
| `phi3:14b` | 14B | ~7.9 GB | Microsoft | Stronger Phi variant |
| `qwen2.5` | 7B | ~4.7 GB | Alibaba | Multilingual, strong reasoning |
| `qwen2.5:72b` | 72B | ~41 GB | Alibaba | Top-tier open model |
| `command-r` | 35B | ~20 GB | Cohere | Retrieval-augmented generation |

### Code Generation

| Model | Parameters | Size (Q4) | Developer | Best For |
|-------|-----------|-----------|-----------|----------|
| `codellama` | 7B | ~3.8 GB | Meta | General code generation |
| `codellama:34b` | 34B | ~19 GB | Meta | Complex code tasks |
| `codegemma` | 7B | ~5.0 GB | Google | Code completion, generation |
| `deepseek-coder-v2` | 16B | ~8.9 GB | DeepSeek | Strong code + reasoning |
| `starcoder2` | 7B | ~4.0 GB | BigCode | Multi-language code |
| `qwen2.5-coder` | 7B | ~4.7 GB | Alibaba | Code with Chinese language support |

### Embeddings

| Model | Parameters | Size | Developer | Dimensions |
|-------|-----------|------|-----------|------------|
| `nomic-embed-text` | 137M | ~274 MB | Nomic AI | 768 |
| `mxbai-embed-large` | 335M | ~670 MB | Mixedbread | 1024 |
| `all-minilm` | 23M | ~46 MB | Microsoft | 384 |
| `snowflake-arctic-embed` | 335M | ~670 MB | Snowflake | 1024 |

### Vision (Multimodal)

| Model | Parameters | Size (Q4) | Developer | Best For |
|-------|-----------|-----------|-----------|----------|
| `llava` | 7B | ~4.5 GB | LLaVA Team | Image understanding + chat |
| `llava:34b` | 34B | ~20 GB | LLaVA Team | High-quality image analysis |
| `llama3.2-vision` | 11B | ~7.9 GB | Meta | Vision + text reasoning |
| `moondream` | 1.8B | ~1.7 GB | Vikhyat | Lightweight vision model |
| `bakllava` | 7B | ~4.5 GB | SkunkworksAI | Image description |

### Specialized

| Model | Parameters | Size (Q4) | Developer | Best For |
|-------|-----------|-----------|-----------|----------|
| `meditron` | 7B | ~4.1 GB | EPFL | Medical domain |
| `sqlcoder` | 7B | ~4.1 GB | Defog | Natural language to SQL |
| `magicoder` | 7B | ~3.8 GB | ISCAS | Code generation with instructions |
| `dolphin-mixtral` | 8x7B | ~26 GB | Cognitive Computations | Uncensored, helpful assistant |
| `solar` | 10.7B | ~6.1 GB | Upstage | Korean + English multilingual |
| `yi` | 6B | ~3.5 GB | 01.AI | Chinese + English bilingual |
| `orca-mini` | 3B | ~1.9 GB | Pankaj Mathur | Compact, instruction-following |

### Cloud-Hosted Models (Remote Execution)

Ollama can act as a bridge to cloud-hosted models, allowing you to interface with massive parameter models through the standard Ollama API without needing the local hardware to run them.

| Model | Parameters | Developer | Best For | Hardware Needed |
|-------|-----------|-----------|----------|-----------------|
| `deepseek-v3.1:671b-cloud` | 671B | DeepSeek | State-of-the-art coding and reasoning | Cloud execution |
| `qwen3-coder:480b-cloud` | 480B | Alibaba | Massive-scale code generation | Cloud execution |
| `gpt-oss:120b-cloud` | 120B | Open Source | High-tier general assistant | Cloud execution |
| `kimi-k2.5:cloud` | Unknown | Moonshot AI | Long-context Chinese/English | Cloud execution |

> **💡 Tip:** To use these, your Ollama instance must be configured to route these specific tags to your cloud provider, or you must be connected to a remote Ollama server that handles the cloud bridging. Since inference happens in the cloud, performance is limited by your internet connection/API latency rather than your local GPU VRAM.

---

## Understanding Model Tags

Models use a `name:tag` format. The tag specifies the variant:

```
llama3.1:8b-instruct-q4_0
│        │  │         │
│        │  │         └─ Quantization level
│        │  └─ Variant (instruct, chat, code, text)
│        └─ Parameter count
└─ Model family
```

### Common Tags

| Tag Pattern | Meaning |
|-------------|---------|
| `:latest` | Default recommended version |
| `:7b`, `:13b`, `:70b` | Parameter count |
| `:instruct` | Fine-tuned for following instructions |
| `:chat` | Optimized for conversation |
| `:code` | Specialized for code generation |
| `:text` | Base model (no instruction tuning) |
| `:q4_0`, `:q4_1`, `:q5_0`, `:q5_1`, `:q8_0` | Quantization level |
| `:fp16` | Full precision (largest, highest quality) |

---

## Understanding Quantization

Quantization reduces model precision to decrease size and increase speed, with minimal quality loss.

| Quantization | Bits | Size vs FP16 | Quality | Speed | Best For |
|-------------|------|-------------|---------|-------|----------|
| `fp16` | 16-bit | 100% (baseline) | ★★★★★ | ★★☆☆☆ | Research, maximum quality |
| `q8_0` | 8-bit | ~50% | ★★★★☆ | ★★★☆☆ | Quality-focused production |
| `q5_1` | 5-bit | ~35% | ★★★★☆ | ★★★★☆ | Balanced quality + speed |
| `q5_0` | 5-bit | ~33% | ★★★☆☆ | ★★★★☆ | Good balance |
| `q4_1` | 4-bit | ~28% | ★★★☆☆ | ★★★★★ | Speed-focused |
| `q4_0` | 4-bit | ~25% | ★★★☆☆ | ★★★★★ | Maximum compression |

> **💡 Tip:** For most users, the default quantization (usually Q4) offers the best balance. Only use FP16 if you have ample VRAM and need maximum accuracy.

---

## Choosing the Right Model

### By Hardware

| Available RAM/VRAM | Recommended Models |
|-------------------|-------------------|
| **4 GB** | `llama3.2:1b`, `gemma2:2b`, `phi3`, `moondream` |
| **8 GB** | `llama3.2`, `mistral`, `codellama`, `llava` |
| **16 GB** | `llama3.1:8b`, `gemma2:9b`, `deepseek-coder-v2` |
| **32 GB** | `mixtral`, `command-r`, `codellama:34b` |
| **48+ GB** | `llama3.1:70b`, `qwen2.5:72b`, `llama3.3` |

### By Use Case

| Use Case | Recommended Model | Why |
|----------|------------------|-----|
| **Quick chatbot** | `llama3.2` | Fast, small, good quality |
| **Deep reasoning** | `llama3.1:8b` or `qwen2.5` | Strong analytical capabilities |
| **Code completion** | `deepseek-coder-v2` or `qwen2.5-coder` | Purpose-built for code |
| **Document Q&A (RAG)** | `command-r` + `nomic-embed-text` | Retrieval-optimized |
| **Image analysis** | `llama3.2-vision` or `llava` | Multimodal capabilities |
| **Embeddings** | `nomic-embed-text` | High-quality, efficient |
| **Low resources** | `llama3.2:1b` or `gemma2:2b` | Under 2 GB, still capable |
| **Maximum quality** | `llama3.3:70b` or `qwen2.5:72b` | Best open-source quality |

### Quick Decision Tree

```
Need code generation?
├── Yes → deepseek-coder-v2 or qwen2.5-coder
└── No
    Need image understanding?
    ├── Yes → llama3.2-vision or llava
    └── No
        Need embeddings?
        ├── Yes → nomic-embed-text
        └── No (general chat)
            Less than 8 GB RAM?
            ├── Yes → llama3.2:1b or phi3
            └── No
                Less than 16 GB RAM?
                ├── Yes → llama3.2 or mistral
                └── No → llama3.1:8b or gemma2:9b
```

---

## Managing Models

```bash
# List downloaded models
ollama list

# Show model details
ollama show llama3.2

# Check VRAM usage of loaded models
ollama ps

# Delete a model
ollama rm llama3.2

# Pull an update for an existing model
ollama pull llama3.2
```

---

## Next Steps

→ [Modelfile](07-modelfile.md) — Create custom models with tailored personalities and parameters.
