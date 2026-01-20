# 🚀 Deployment Guide: Self-Hosted Supabase

## Panduan Instalasi Supabase di VPS Biznet untuk LeadX CRM

---

## 📋 Overview

LeadX CRM menggunakan **Self-Hosted Supabase** yang di-deploy di **VPS Biznet Gio** (Indonesia). Ini memberikan:
- ✅ Data di Indonesia (compliance)
- ✅ Full control atas infrastructure
- ✅ Semua fitur Supabase (Auth, Realtime, Storage)
- ✅ Biaya lebih predictable

---

## 🖥️ VPS Requirements

### Minimum Specifications

| Spec | Development | Production |
|------|-------------|------------|
| **RAM** | 4 GB | 8 GB |
| **vCPU** | 2 cores | 4 cores |
| **Storage** | 40 GB SSD | 100 GB SSD |
| **Network** | Public IP | Public IP + Domain |
| **OS** | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| **Biznet Plan** | Neo Lite 2 | Neo Lite 4 |

### Estimated Costs (Biznet Gio)

| Environment | Plan | Monthly Cost |
|-------------|------|--------------|
| Development/UAT | Neo Lite 2 (4GB RAM) | ~Rp 200.000 |
| Production | Neo Lite 4 (8GB RAM) | ~Rp 400.000 |
| **Total** | | **~Rp 600.000/mo** |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VPS BIZNET (Self-Hosted Supabase)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         DOCKER COMPOSE                               │    │
│  │                                                                      │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │  KONG (API Gateway)                     :8000 (API)           │  │    │
│  │  │                                         :8443 (API SSL)       │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  │                               │                                      │    │
│  │       ┌───────────────────────┼───────────────────────┐             │    │
│  │       │                       │                       │             │    │
│  │       ▼                       ▼                       ▼             │    │
│  │  ┌─────────┐            ┌─────────┐            ┌─────────┐         │    │
│  │  │PostgREST│            │ GoTrue  │            │Realtime │         │    │
│  │  │  :3000  │            │  :9999  │            │  :4000  │         │    │
│  │  └────┬────┘            └────┬────┘            └────┬────┘         │    │
│  │       │                      │                      │               │    │
│  │       └──────────────────────┼──────────────────────┘               │    │
│  │                              │                                      │    │
│  │                              ▼                                      │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │  PostgreSQL 15 + PostGIS                           :5432      │  │    │
│  │  │  (Primary Database)                                           │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  │                                                                      │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │  MinIO (S3-Compatible Storage)                     :9000      │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  │                                                                      │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │  Supabase Studio (Admin UI)                        :3000      │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  NGINX (Reverse Proxy + SSL)                                        │    │
│  │  ├── api.leadx.codehava.id    → Kong :8000                         │    │
│  │  ├── studio.leadx.codehava.id → Studio :3000                       │    │
│  │  └── admin.leadx.codehava.id  → Flutter Web (static)               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📝 Step-by-Step Installation

### Step 1: Initial Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl git wget ufw htop

# Configure firewall
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Step 2: Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add current user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo apt install -y docker-compose-plugin

# Verify installation
docker --version
docker compose version

# Re-login to apply group changes
exit
# Login again
```

### Step 3: Clone Supabase

```bash
# Create directory
sudo mkdir -p /opt/supabase
sudo chown $USER:$USER /opt/supabase
cd /opt/supabase

# Clone the repository
git clone --depth 1 https://github.com/supabase/supabase

# Navigate to docker directory
cd supabase/docker
```

### Step 4: Configure Environment

```bash
# Copy example environment
cp .env.example .env

# Generate secure keys
# JWT Secret (at least 32 characters)
openssl rand -base64 32

# ANON Key - Generate at https://supabase.com/docs/guides/self-hosting#api-keys
# SERVICE_ROLE Key - Generate at same URL

# Edit .env file
nano .env
```

**Key Environment Variables:**

```env
############
# Secrets
############
POSTGRES_PASSWORD=your_secure_postgres_password
JWT_SECRET=your_super_secret_jwt_token_at_least_32_characters
ANON_KEY=eyJhbG...your_anon_key
SERVICE_ROLE_KEY=eyJhbG...your_service_role_key

############
# Database
############
POSTGRES_HOST=db
POSTGRES_DB=postgres
POSTGRES_PORT=5432

############
# API
############
SITE_URL=https://leadx.codehava.id
API_EXTERNAL_URL=https://api.leadx.codehava.id

############
# Auth
############
GOTRUE_SITE_URL=https://leadx.codehava.id
GOTRUE_EXTERNAL_EMAIL_ENABLED=true
GOTRUE_MAILER_AUTOCONFIRM=false

############
# Studio
############
STUDIO_PORT=3000
SUPABASE_PUBLIC_URL=https://api.leadx.codehava.id

############
# Storage
############
STORAGE_BACKEND=s3
# Use local MinIO or external S3
```

### Step 5: Start Supabase

```bash
# Pull images (first time takes a while)
docker compose pull

# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### Step 6: Enable PostGIS

PostGIS sudah enabled by default di Supabase. Verify:

```bash
# Connect to database
docker compose exec db psql -U postgres -d postgres

# Check PostGIS
SELECT PostGIS_version();

# If not enabled, run:
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

# Exit
\q
```

### Step 7: Setup Nginx Reverse Proxy

```bash
# Install Nginx
sudo apt install -y nginx

# Install Certbot for SSL
sudo apt install -y certbot python3-certbot-nginx

# Create Nginx config
sudo nano /etc/nginx/sites-available/leadx
```

**Nginx Configuration:**

```nginx
# API endpoint
server {
    server_name api.leadx.codehava.id;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}

# Studio (Admin Dashboard)
server {
    server_name studio.leadx.codehava.id;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/leadx /etc/nginx/sites-enabled/

# Test config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Get SSL certificates
sudo certbot --nginx -d api.leadx.codehava.id -d studio.leadx.codehava.id
```

---

## 🔧 Post-Installation Configuration

### Configure Database Extensions

```sql
-- Connect to database and run:

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Verify
SELECT * FROM pg_extension;
```

### Setup Backup (Cron Job)

```bash
# Create backup script
sudo nano /opt/supabase/backup.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/opt/supabase/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CONTAINER="supabase-docker-db-1"

mkdir -p $BACKUP_DIR

# Backup database
docker exec $CONTAINER pg_dump -U postgres postgres | gzip > $BACKUP_DIR/leadx_$TIMESTAMP.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completed: leadx_$TIMESTAMP.sql.gz"
```

```bash
# Make executable
chmod +x /opt/supabase/backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add line:
0 2 * * * /opt/supabase/backup.sh >> /var/log/supabase-backup.log 2>&1
```

---

## 🌐 DNS Configuration

Configure these DNS records:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | api.leadx | VPS_PUBLIC_IP | 300 |
| A | studio.leadx | VPS_PUBLIC_IP | 300 |
| A | admin.leadx | VPS_PUBLIC_IP | 300 |

---

## 🔐 Security Hardening

### 1. Change Default Credentials

```bash
# Edit .env and change all default passwords
nano /opt/supabase/supabase/docker/.env

# Restart services
docker compose down && docker compose up -d
```

### 2. Restrict Studio Access

```nginx
# In Nginx config for studio, add IP restriction:
server {
    server_name studio.leadx.codehava.id;
    
    # Allow only office IPs
    allow 103.xxx.xxx.xxx;  # Office IP
    deny all;
    
    location / {
        proxy_pass http://localhost:3000;
        # ... rest of config
    }
}
```

### 3. Enable Fail2ban

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## 📊 Monitoring

### Check Service Status

```bash
# All services
docker compose ps

# Individual service logs
docker compose logs -f db
docker compose logs -f kong
docker compose logs -f auth

# Resource usage
docker stats
```

### Health Check

```bash
# Database health
curl http://localhost:8000/rest/v1/ -H "apikey: $ANON_KEY"

# Auth health
curl http://localhost:8000/auth/v1/health
```

---

## 🔄 Updates & Maintenance

### Update Supabase

```bash
cd /opt/supabase/supabase/docker

# Pull latest changes
git pull

# Pull new images
docker compose pull

# Restart with new images
docker compose down
docker compose up -d
```

### Restart Services

```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart db
docker compose restart auth
```

---

## 🚨 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Port already in use | Check `sudo lsof -i :PORT` and stop conflicting service |
| Database connection refused | Ensure db container is running: `docker compose logs db` |
| Auth not working | Check GoTrue logs and JWT_SECRET config |
| SSL certificate error | Re-run `sudo certbot --nginx` |

### Recovery

```bash
# If something breaks, restore from backup:
gunzip < /opt/supabase/backups/leadx_TIMESTAMP.sql.gz | \
  docker exec -i supabase-docker-db-1 psql -U postgres -d postgres
```

---

## 📚 Environment Files Reference

### Production Environment

| Variable | Description | Example |
|----------|-------------|---------|
| `API_EXTERNAL_URL` | Public API URL | https://api.leadx.codehava.id |
| `SITE_URL` | Frontend URL | https://leadx.codehava.id |
| `JWT_SECRET` | JWT signing secret | Random 32+ chars |
| `POSTGRES_PASSWORD` | DB password | Secure random |

---

## 📋 Checklist

### Pre-Deployment
- [ ] VPS provisioned with minimum specs
- [ ] DNS records configured
- [ ] SSH key access configured
- [ ] Firewall rules set

### Installation
- [ ] Docker installed
- [ ] Supabase cloned
- [ ] Environment configured
- [ ] Services started
- [ ] PostGIS enabled
- [ ] Nginx configured
- [ ] SSL certificates obtained

### Post-Deployment
- [ ] Default credentials changed
- [ ] Backup script configured
- [ ] Monitoring setup
- [ ] Security hardening applied
- [ ] Flutter app connected and tested

---

*Dokumentasi ini akan diupdate seiring perkembangan deployment.*
