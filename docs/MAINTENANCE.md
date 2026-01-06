# Maintenance Guide

Regular maintenance tasks for Vacbo Open Library.

## Automated Tasks

| Task | Schedule | Action |
|------|----------|--------|
| Backups | Daily 3 AM | Automatic |
| Backup cleanup | Daily | Keeps last 7 days |
| Certificate renewal | Auto | Caddy handles this |

## Weekly Checks

### Health Check

```bash
bash scripts/health-check.sh
```

### View Logs

```bash
docker compose logs --since 24h
docker compose logs calibre-web --since 24h
```

### Check Disk Space

```bash
df -h
du -sh backups/ library/ config/
```

## Monthly Tasks

### Update Containers

```bash
docker compose pull
docker compose up -d --force-recreate
docker image prune -f
```

### Verify Backups

```bash
ls -lah backups/

mkdir -p /tmp/backup-test
tar -xzf backups/$(ls -t backups/*.tar.gz | head -1) -C /tmp/backup-test
ls /tmp/backup-test/
rm -rf /tmp/backup-test
```

## Manual Operations

### Trigger Backup Now

```bash
bash scripts/backup-now.sh
```

### Restart Services

```bash
docker compose restart
```

### Full Restart

```bash
docker compose down && docker compose up -d
```

### View Container Logs

```bash
docker compose logs -f calibre-web
docker compose logs -f caddy
```

## Restore from Backup

### Full Restore

```bash
docker compose down
tar -xzf backups/library-backup-YYYYMMDD-HHMMSS.tar.gz -C ./
docker compose up -d
```

### Library Only

```bash
docker compose stop calibre-web
tar -xzf backups/library-backup-YYYYMMDD-HHMMSS.tar.gz ./library/
docker compose start calibre-web
```

## Common Issues

### Container keeps restarting

```bash
docker compose logs calibre-web --tail 100
sudo chown -R $(id -u):$(id -g) config/ library/
```

### Out of disk space

```bash
docker system prune -af
ls -lt backups/ | tail -n +8 | xargs rm -f
```

### Certificate issues

```bash
docker compose logs caddy | grep -i cert
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### Can't upload large books

The Caddyfile has 5-minute timeouts. For very large files, you may need to increase:

```caddyfile
transport http {
    read_timeout 600s
    write_timeout 600s
}
```

Then reload: `docker compose restart caddy`

## Emergency Procedures

### Service Down

```bash
docker compose restart
docker compose ps
docker compose logs --tail 50
```

### Data Corruption

```bash
docker compose down
tar -xzf backups/$(ls -t backups/*.tar.gz | head -1) -C ./
docker compose up -d
```

### Complete Reset

```bash
docker compose down -v
rm -rf config/calibre-web/*
docker compose up -d
```

Note: This requires reconfiguring Calibre-Web from scratch.

## Monitoring Commands

```bash
docker stats
docker compose top
htop
```

## Backup Location

Local backups are stored in `./backups/`. Consider:
- Periodically copying to external storage
- Setting up cloud backup (S3, Backblaze) in docker-compose.yml
