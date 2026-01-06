# Vacbo Open Library

A secure, self-hosted community Calibre library running on Oracle Cloud ARM64.

## Features

- **Calibre-Web** - Beautiful web interface for your ebook library
- **Secure** - HTTPS with automatic certificates, security headers
- **OAuth** - Login with Google or GitHub accounts
- **Cloudflare** - DDoS protection and global CDN
- **Auto Backups** - Daily backups with 7-day retention
- **Docker** - Easy deployment and updates

## Quick Start

```bash
# Clone and configure
git clone https://github.com/yourusername/vacbo-open-library.git
cd vacbo-open-library
cp .env.example .env
nano .env  # Fill in your values

# Copy your Calibre library
scp -r /path/to/calibre/library/* ./library/

# Start services
docker compose up -d

# Access your library
# URL: https://library.vacbo.dev
# Default: admin / admin123 (CHANGE IMMEDIATELY)
```

## Architecture

```
Internet → Cloudflare (DDoS/CDN) → Caddy (HTTPS) → Calibre-Web
                                      ↓
                                 Auto Backups
```

## Services

| Service | Port | Purpose |
|---------|------|---------|
| Caddy | 80, 443 | Reverse proxy, HTTPS |
| Calibre-Web | 8083 (internal) | Library interface |
| Backup | - | Daily automated backups |

## Documentation

- [Deployment Guide](docs/DEPLOYMENT.md) - Step-by-step setup
- [OAuth Setup](docs/OAUTH_SETUP.md) - Google/GitHub login
- [Maintenance](docs/MAINTENANCE.md) - Backups, updates, troubleshooting

## Requirements

- Docker and Docker Compose
- Domain with Cloudflare DNS
- Cloudflare API token (DNS edit permissions)

## Security

- All traffic encrypted (HTTPS/TLS 1.3)
- Security headers (HSTS, CSP, X-Frame-Options)
- Cloudflare DDoS protection
- OAuth authentication (Google/GitHub)
- Daily encrypted backups

## License

MIT License
