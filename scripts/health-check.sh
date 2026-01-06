#!/bin/bash
set -e

echo "=========================================="
echo "  Vacbo Open Library - Health Check"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -n "Docker daemon: "
if docker info &> /dev/null; then
    echo -e "${GREEN}Running${NC}"
else
    echo -e "${RED}Not running${NC}"
    exit 1
fi

echo ""
echo "Container Status:"
echo "-----------------"
docker compose ps

echo ""
echo "Health Checks:"
echo "--------------"

echo -n "Calibre-Web: "
if docker compose exec -T calibre-web curl -sf http://localhost:8083/ > /dev/null 2>&1; then
    echo -e "${GREEN}Healthy${NC}"
else
    echo -e "${RED}Unhealthy${NC}"
fi

echo -n "Caddy: "
if curl -sf http://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}Healthy${NC}"
else
    echo -e "${YELLOW}Check externally${NC}"
fi

echo -n "External HTTPS: "
if curl -sf https://library.vacbo.dev/health > /dev/null 2>&1; then
    echo -e "${GREEN}Accessible${NC}"
else
    echo -e "${RED}Not accessible${NC}"
fi

echo ""
echo "Disk Usage:"
echo "-----------"
df -h | grep -E "^/dev|Filesystem"

echo ""
echo "Backup Status:"
echo "--------------"
if [ -d "./backups" ]; then
    LATEST_BACKUP=$(ls -t ./backups/*.tar.gz 2>/dev/null | head -1)
    if [ -n "$LATEST_BACKUP" ]; then
        echo "Latest backup: $LATEST_BACKUP"
        echo "Size: $(du -h "$LATEST_BACKUP" | cut -f1)"
        echo "Date: $(stat -c %y "$LATEST_BACKUP" 2>/dev/null || stat -f %Sm "$LATEST_BACKUP" 2>/dev/null)"
    else
        echo -e "${YELLOW}No backups found${NC}"
    fi
else
    echo -e "${YELLOW}Backup directory not found${NC}"
fi

echo ""
echo "=========================================="
