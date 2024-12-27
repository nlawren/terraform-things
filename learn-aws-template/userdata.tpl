#!/bin/bash
sudo apt update -y &&
sudo apt install -y \
apt-transport-https \
gnupg-agentq &&
curl -fsSL https://tailscale.com/install.sh | sh &&
sudo apt upgrade -y
