# SimpleSatOps

**Description:** Lightweight satellite services hosted on a remote VPS
**Tagline:** SimpleSatOps – keeping things stable on the edge of the system.

## Contents

- `docker/` – Docker Compose service definitions
- `scripts/` – Utility and automation scripts

## Philosophy

This repo complements `BrainiacOps`, focusing on minimalism, resilience, and low-touch services. Ideal for external-facing tools, backups, and remote monitoring.

## Deployment

1. Copy `.env.example` to `.env` and adjust settings.
2. Run `docker compose up -d` in each service directory.

## Bootstrap

To initialize the repo after cloning:

```bash
./scripts/bootstrap.sh
```
