#!/bin/bash
set -e

echo "=========================================="
echo "  Vacbo Open Library - Manual Backup"
echo "=========================================="

echo "Triggering backup..."
docker compose exec backup backup

echo ""
echo "Backup complete. Recent backups:"
ls -lah backups/*.tar.gz 2>/dev/null | tail -5 || echo "No backups found"
