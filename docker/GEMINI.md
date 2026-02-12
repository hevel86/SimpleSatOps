# Gemini Code Assistant Context

This document provides context for the Gemini Code Assistant to understand the `SimpleSatOps` repository.

## Directory Overview

This repository, `SimpleSatOps`, is a lightweight collection of satellite services for a remote VPS. It is designed for minimalism, resilience, and low-touch services, making it ideal for external-facing tools, backups, and remote monitoring. The repository primarily consists of Docker Compose service definitions and utility scripts. This is an operations/infrastructure project, not a traditional code project.

All services are containerized and managed through Docker Compose.

## Architecture

### Network Architecture
- All services join the external `t3_proxy` network to be routed through Traefik v3 reverse proxy.
- Traefik handles automatic HTTPS via Cloudflare DNS challenge with Let's Encrypt certificates.
- Services expose their web interfaces only through Traefik (no direct port bindings in most cases).
- Create the proxy network before deploying services: `docker network create t3_proxy`

### Service Structure
Each service lives in `docker/[service-name]/` containing:
- `docker-compose.yml` - service definition with Traefik labels for routing
- `.env` - environment overrides (not committed)
- `secrets/` or token files - sensitive values loaded via Docker secrets or `_FILE` pattern
- Persistent data directories - kept alongside compose file, never committed

Available services: traefik3, uptime_kuma, joplin, it-tools, ntfy, portainer, rustdesk, semaphoreui, wishlist

### Traefik Configuration
Traefik lives in `docker/traefik3/` with:
- `data/traefik.yml` - static configuration (API, entryPoints, certificatesResolvers)
- `data/acme.json` - TLS certificate storage (permissions: 600)
- `rules/` - optional dynamic routing rules loaded as file provider
- `cf_api_token.txt` - Cloudflare DNS API token (loaded as Docker secret)

Key traefik.yml settings:
- HTTP → HTTPS automatic redirect
- Cloudflare DNS challenge for wildcard certificates
- Docker provider with `exposedByDefault: false`
- Dashboard at `traefik.${DOMAINNAME}` with BasicAuth

#### Traefik Image Versioning
Traefik uses **named tags** (codenames) that track minor version branches:
- `traefik:ramequin` → 3.6.x branch (current)
- `traefik:chabichou` → 3.5.x branch
- `traefik:mimolette` → 2.11.x branch

**Prefer named tags over `latest` or semver tags:**
- Named tags provide automatic patch updates (3.6.0 → 3.6.1 → 3.6.2)
- Prevents unexpected jumps to new minor/major versions
- More stable for production deployments

## Usage and Development Conventions

### Initial Setup
```bash
# After cloning
./scripts/bootstrap.sh  # Sets up git hooks and pulls TruffleHog image

# Initialize Traefik stack
./scripts/traefik3-init.sh  # Creates .env, secrets, and config files
cd docker/traefik3
# Edit .env with your DOMAINNAME
# Edit cf_api_token.txt with your Cloudflare token
# Edit data/traefik.yml with your email for Let's Encrypt
docker compose up -d
```

### Working with Services
```bash
cd docker/<service-name>

# Validate configuration before running
docker compose config  # Catches missing env vars or YAML errors

# Start or update service
docker compose pull && docker compose up -d

# View logs
docker compose logs -f [service-name]

# Check status
docker compose ps

# Stop service (keeps data)
docker compose down

# Stop and wipe data (use with caution)
docker compose down --volumes
```

### Secret Management

This project uses `sops` for secret management. All files ending in `.yaml`, `.yml`, `.json`, `.ini`, or `.env` are encrypted by default. To edit a secret, you will need the `age` key and use the `sops` CLI.

**Example:**

```bash
sops docker/joplin/secrets/postgres_password.txt
```

### Secret Handling Rules
- Never commit real secrets: `.env`, `cf_api_token.txt`, `secrets/` directories
- Use Docker secrets or `_FILE` pattern for sensitive values
- TruffleHog pre-commit hook scans YAML/JSON/ENV files for secrets
- Bypass only if necessary: `SKIP_TRUFFLEHOG=1 git commit`


### Coding Standards

#### YAML Style
- 2-space indentation
- Long-form keys for clarity
- Service names mirror container names for easy log lookup

#### Commit Format
Conventional Commits enforced by `commit-msg` hook:
```
type(scope): lowercase description

Types: feat, fix, docs, infra, ci, chore, refactor
Scope: lowercase a-z, 0-9, _, -, /
```

Examples:
- `feat(docker): add uptime-kuma docker-compose`
- `fix(traefik): correct certresolver configuration`
- `chore(docker): update traefik image tag`

### Git Hooks
Repository uses custom hooks (`.githooks/`):
- `pre-commit` - TruffleHog secret scanning on YAML/ENV/JSON files
- `commit-msg` - Conventional Commits format validation
- Set up via `./scripts/bootstrap.sh`

## Common Workflows

### Adding a New Service
1. Create `docker/<service-name>/` directory
2. Create `docker-compose.yml` with service definition
3. Add to `t3_proxy` network
4. Add Traefik labels for routing: `<subdomain>.${DOMAINNAME}`
5. Create `.env.example` documenting required variables
6. Test: `docker compose config && docker compose up -d`
7. Verify Traefik routing: `docker compose -f docker/traefik3/docker-compose.yml logs -f traefik`

### Modifying Traefik Configuration
- Static config changes: edit `docker/traefik3/data/traefik.yml`, restart traefik
- Dynamic routing rules: add YAML files to `docker/traefik3/rules/`, auto-reloaded
- Check Traefik dashboard for active routes and services

### Troubleshooting Services
1. Validate compose file: `docker compose config`
2. Check container status: `docker compose ps`
3. Review logs: `docker compose logs -f [service]`
4. Verify network: `docker network inspect t3_proxy`
5. Check Traefik routing: view traefik logs or dashboard

### Troubleshooting Traefik Specifically
**Docker API Version Errors:**
If logs show "Error response from daemon: client version X.XX is too old":
1. Check Docker daemon API version: `docker version --format '{{.Server.APIVersion}}'`
2. Check current Traefik image version: `docker exec traefik3 traefik version`
3. **First step:** Check for newer Traefik image release before modifying configs
4. Review Traefik release notes/changelog for Docker API compatibility fixes
5. Upgrade to newer named tag (e.g., `chabichou` → `ramequin`) after checking for breaking changes
6. Verify DOCKER_API_VERSION and DOCKER_MIN_API_VERSION are set in docker-compose.yml

**Image Upgrade Process:**
1. Check current version: `docker inspect <image> | grep version`
2. Pull new tag: `docker pull traefik:<codename>`
3. Review release notes for breaking changes in labels, middleware, or config syntax
4. Update docker-compose.yml with new tag
5. Test: `docker compose config && docker compose up -d`
6. Monitor logs: `docker compose logs -f traefik` for errors

### Data Persistence
- Persistent data stored in directories alongside docker-compose.yml
- Examples: `uptime_kuma_data/`, `joplin/postgres13_data/`
- Never commit data directories
- Backup before using `docker compose down --volumes`
