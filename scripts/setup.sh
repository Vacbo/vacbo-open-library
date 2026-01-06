#!/bin/bash
set -e

echo "=========================================="
echo "  Vacbo Open Library - Server Setup"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please run as regular user (vacbo), not root${NC}"
    exit 1
fi

echo -e "${GREEN}[1/6] Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}[2/6] Installing required packages...${NC}"
sudo apt install -y curl wget git htop

echo -e "${GREEN}[3/6] Verifying Docker installation...${NC}"
if command -v docker &> /dev/null; then
    echo "Docker is installed: $(docker --version)"
else
    echo -e "${YELLOW}Docker not found. Installing...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}Please log out and back in for Docker permissions${NC}"
fi

echo -e "${GREEN}[4/6] Creating project directories...${NC}"
mkdir -p config/calibre-web
mkdir -p config/caddy/data
mkdir -p config/caddy/config
mkdir -p library
mkdir -p backups

echo -e "${GREEN}[5/6] Setting permissions...${NC}"
PUID=$(id -u)
PGID=$(id -g)
echo "User ID: $PUID, Group ID: $PGID"
sudo chown -R $PUID:$PGID config/ library/ backups/

echo -e "${GREEN}[6/6] Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
else
    echo -e "${YELLOW}UFW not found. Configuring iptables...${NC}"
    sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
    if command -v netfilter-persistent &> /dev/null; then
        sudo netfilter-persistent save
    else
        sudo apt install -y iptables-persistent
        sudo netfilter-persistent save
    fi
fi

echo ""
echo "=========================================="
echo -e "${GREEN}  Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env and configure"
echo "2. Copy your Calibre library to ./library/"
echo "3. Run: docker compose up -d"
echo "4. Access: https://library.vacbo.dev"
echo ""
echo "Your user IDs for .env:"
echo "  PUID=$PUID"
echo "  PGID=$PGID"
