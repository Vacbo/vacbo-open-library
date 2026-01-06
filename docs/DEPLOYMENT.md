# Deployment Guide

Step-by-step guide to deploy Vacbo Open Library on Oracle Cloud ARM64.

## Prerequisites

- Oracle Cloud ARM64 instance (Always Free tier)
- Ubuntu 24.04 Minimal
- Domain pointed to your server via Cloudflare
- Cloudflare API token with DNS edit permissions

## Step 1: Server Preparation

SSH into your server:

```bash
ssh vacbo@your-server-ip
```

Clone the repository:

```bash
git clone https://github.com/yourusername/vacbo-open-library.git
cd vacbo-open-library
```

Run the setup script:

```bash
bash scripts/setup.sh
```

## Step 2: Configure Environment

Copy and edit the environment file:

```bash
cp .env.example .env
nano .env
```

Fill in your values:

| Variable | Value |
|----------|-------|
| `CLOUDFLARE_API_TOKEN` | Your new Cloudflare token |
| `ACME_EMAIL` | `contact@vacbo.dev` |
| `PUID` | Output from `id -u vacbo` |
| `PGID` | Output from `id -g vacbo` |
| `TZ` | `America/Sao_Paulo` |

## Step 3: Create Cloudflare API Token

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click **Create Token**
3. Use **Custom token** template
4. Configure:
   - Token name: `vacbo-library-dns`
   - Permissions: Zone → DNS → Edit
   - Zone Resources: Include → Specific zone → `vacbo.dev`
5. Click **Continue to summary** → **Create Token**
6. Copy the token to your `.env` file

## Step 4: Configure Cloudflare DNS

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select `vacbo.dev`
3. Go to **DNS** → **Records**
4. Add an **A record**:
   - Name: `library`
   - IPv4: Your Oracle Cloud public IP
   - Proxy: **Enabled** (orange cloud)
   - TTL: Auto

5. Go to **SSL/TLS** → **Overview**:
   - Set mode to **Full (strict)**

6. Go to **SSL/TLS** → **Edge Certificates**:
   - Enable **Always Use HTTPS**
   - Enable **Automatic HTTPS Rewrites**

## Step 5: Copy Your Library

Copy your existing Calibre library to the server:

```bash
scp -r /path/to/calibre/library/* vacbo@server:~/vacbo-open-library/library/
```

Verify `metadata.db` exists:

```bash
ls -la library/metadata.db
```

## Step 6: Start Services

```bash
docker compose up -d
```

Watch the logs:

```bash
docker compose logs -f
```

Wait for Caddy to obtain certificates (1-2 minutes).

## Step 7: Initial Configuration

1. Access https://library.vacbo.dev

2. Login with default credentials:
   - Username: `admin`
   - Password: `admin123`

3. **IMMEDIATELY** change the admin password:
   - Go to **Admin** → **Edit Users** → **admin**
   - Set a strong password
   - Click **Save**

4. Configure the database location:
   - Go to **Admin** → **Basic Configuration**
   - Set **Location of Calibre database** to: `/books`
   - Click **Save**

5. Enable self-registration (optional):
   - Go to **Admin** → **Configuration** → **Feature Configuration**
   - Enable **Allow Public Registration**
   - Click **Save**

6. Configure OAuth - see [OAuth Setup](OAUTH_SETUP.md)

## Step 8: Verify Deployment

Run the health check:

```bash
bash scripts/health-check.sh
```

Test external access:

```bash
curl -I https://library.vacbo.dev
```

Expected response:
- `HTTP/2 200`
- `strict-transport-security` header present
- `x-content-type-options: nosniff`

## Oracle Cloud Firewall

If you can't access the site, check Oracle Cloud's firewall:

1. Go to Oracle Cloud Console
2. Navigate to your instance
3. Go to **Primary VNIC** → **Subnet** → **Security Lists**
4. Add ingress rules for ports 80 and 443 (TCP, 0.0.0.0/0)

## Troubleshooting

### Containers won't start

```bash
docker compose logs calibre-web
docker compose logs caddy
```

### Certificate issues

```bash
docker compose logs caddy | grep -i cert
```

Verify your Cloudflare token:

```bash
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Permission issues

```bash
sudo chown -R $(id -u):$(id -g) config/ library/ backups/
```

### Can't connect to site

1. Check containers are running: `docker compose ps`
2. Check Oracle Cloud security lists (ports 80, 443)
3. Check Cloudflare DNS record points to correct IP
4. Check Cloudflare SSL/TLS is set to "Full (strict)"

## Next Steps

- [Configure OAuth](OAUTH_SETUP.md)
- [Maintenance Guide](MAINTENANCE.md)
