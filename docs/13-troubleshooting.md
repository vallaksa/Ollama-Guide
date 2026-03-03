# Troubleshooting

> **Solutions to the most common Ollama errors and issues.**

---

## Connection & Server Issues

### Error: `could not connect to ollama app, is it running?`
**Cause:** The Ollama server is not running or crashed.
**Fix:**
- **macOS/Windows:** Launch the Ollama application.
- **Linux:** Run `sudo systemctl start ollama` or `ollama serve`.
- **Check Status:** `curl http://localhost:11434`

### Error: `bind: address already in use`
**Cause:** Another process (or another instance of Ollama) is already using port `11434`.
**Fix:**
```bash
# Find what's using the port (Linux/macOS)
lsof -i :11434
# Or
netstat -tulpn | grep 11434

# Kill the conflicting process
kill -9 <PID>
```
Or, change Ollama's port by setting `OLLAMA_HOST=127.0.0.1:8080`.

### Issue: Cannot access Ollama from another computer
**Cause:** By default, Ollama only listens on `localhost` (127.0.0.1) for security.
**Fix:** Set the environment variable `OLLAMA_HOST=0.0.0.0:11434` and restart the server. See [Server Deployment](09-server-deployment.md).

---

## Model Loading & Performance

### Error: `llama runner process has terminated` or `signal: killed`
**Cause:** The system ran out of RAM/VRAM (Out of Memory - OOM).
**Fix:**
1. Try a smaller model (e.g., `llama3.2:1b` instead of `llama3.2`).
2. Try a model with higher quantization (e.g., `q4_0`).
3. Close other applications using large amounts of memory.
4. If using `num_ctx` in a Modelfile, reduce the context window size.

### Issue: Inference is extremely slow
**Cause:** The model is running on the CPU instead of the GPU.
**Fix:**
1. Verify Ollama sees your GPU: run `ollama ps` and look at the `PROCESSOR` column. It should say `100% GPU`.
2. **NVIDIA (Linux):** Ensure drivers are installed (`nvidia-smi`).
3. **AMD (Linux):** Ensure ROCm is installed (`rocm-smi`).
4. **Docker:** Ensure you passed the `--gpus all` flag and have the NVIDIA Container Toolkit.
See [GPU Setup](11-gpu-setup.md).

### Issue: `ollama ps` shows `50% CPU / 50% GPU`
**Cause:** The model is too large to fit entirely in your VRAM, so Ollama split it across the GPU and system RAM.
**Fix:** This is normal behavior to prevent OOM crashes, but it is slower than 100% GPU. To fix, either use a smaller model or add more VRAM.

---

## Downloading Models

### Error: `pull model manifest: file does not exist`
**Cause:** The model name or tag specifies a model that isn't in the Ollama registry.
**Fix:** Check the exactly spelling at [ollama.com/library](https://ollama.com/library). If omitting a tag (e.g., `ollama pull modelname`), ensure that a `:latest` tag exists for that model.

### Error: `EOF` or `unexpected EOF` during pull
**Cause:** The download connection dropped.
**Fix:** Run the `ollama pull <model>` command again. Ollama resumes downloads from where they left off.

---

## Custom Models (Modelfile)

### Error: `invalid parameter: <name>`
**Cause:** You used an unrecognized parameter in `PARAMETER` in your Modelfile.
**Fix:** Check the grammar. See the parameter list in the [Modelfile](07-modelfile.md) guide.

### Error: Model output is gibberish or repeats itself endlessly
**Cause:** Incorrect generation parameters.
**Fix:**
1. Check your Modelfile template.
2. Check `repeat_penalty` (default 1.1, try setting higher if repeating).
3. If you applied a LoRA adapter, ensure it was trained on the exact same base model architecture.

---

## Storage & Filesystem

### Issue: Root partition is full (Linux)
**Cause:** Ollama models are stored in `/usr/share/ollama/.ollama/models` (when running as systemd `ollama` user), filling up the root drive.
**Fix:** Move the storage location to a larger drive.
1. `sudo systemctl edit ollama`
2. Add: `Environment="OLLAMA_MODELS=/mnt/huge-drive/ollama/models"`
3. Move existing models: `sudo mv /usr/share/ollama/.ollama/models /mnt/huge-drive/ollama/`
4. `sudo systemctl daemon-reload && sudo systemctl restart ollama`

### Error: `permission denied` when creating or pulling models
**Cause:** The user running the `ollama` command doesn't have write access to the model directory.
**Fix:** If you ran `ollama serve` as root via `sudo` previously, the directory may be owned by root.
```bash
sudo chown -R $USER:$USER ~/.ollama
```

---

## Viewing Logs for Deeper Debugging

When in doubt, check the server logs. They contain the exact errors from the model runner.

- **macOS:** `cat ~/.ollama/logs/server.log`
- **Linux (systemd):** `journalctl -u ollama --no-pager | tail -n 50`
- **Windows:** `%LOCALAPPDATA%\Ollama\server.log`
- **Docker:** `docker logs ollama`

To enable highly verbose debug logs, set the environment variable:
`OLLAMA_DEBUG=1`

---

## Getting Help

If these steps don't solve your issue:
1. Search the [Ollama GitHub Issues](https://github.com/ollama/ollama/issues).
2. Ask in the [Ollama Discord](https://discord.gg/ollama).
