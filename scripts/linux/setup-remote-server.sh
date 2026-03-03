#!/usr/bin/env bash

# Remote Server Setup Script
# Installs Ollama, configures systemd for remote access, and optionally sets up UFW.

set -e

echo "🦙 Ollama Remote Server Setup"
echo "------------------------------"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo ./setup-remote-server.sh)"
  exit 1
fi

# 1. Install Ollama
echo "📥 Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
sleep 2

# 2. Configure systemd for 0.0.0.0
echo "⚙️ Configuring systemd for remote access (0.0.0.0)..."
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/override.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF

# 3. Reload and restart
echo "🔄 Restarting Ollama service..."
systemctl daemon-reload
systemctl restart ollama

# 4. Optional Firewall (UFW) Setup
read -p "Do you want to configure UFW to allow port 11434? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v ufw &> /dev/null; then
        echo "🔒 Configuring UFW..."
        read -p "Enter the IP address or subnet to allow (e.g., 192.168.1.0/24 or your public IP): " ALLOW_IP
        
        ufw allow from "$ALLOW_IP" to any port 11434 proto tcp
        ufw enable
        ufw status | grep 11434
    else
        echo "⚠️ UFW is not installed. Skipping firewall setup."
    fi
fi

echo "------------------------------"
echo "✅ Server setup complete!"
echo "You can now connect from your client using:"
echo "export OLLAMA_HOST=http://<this-server-ip>:11434"
echo "ollama list"
