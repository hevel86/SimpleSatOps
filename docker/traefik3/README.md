# 🧭 Traefik v3 Stack (SimpleSatOps)

This folder contains an automated, secure, and reproducible Traefik v3 reverse proxy setup using Docker Compose.

> ✅ Built for portability and Infrastructure-as-Code (IaC) practices.

---

## 📦 Stack Contents

```
traefik3/
├── cf_api_token.txt # 🔒 Cloudflare DNS token (auto-created)
├── .env # 🌐 Environment overrides (from .env.example)
├── docker-compose.yml # 🐳 Main stack
├── data/
│ ├── acme.json # 🔒 TLS cert store (auto-created)
│ └── traefik.yml # ⚙️ Static configuration (auto-created if missing)
├── rules/ # 📂 Optional dynamic routing rules
└── README.md # 📘 This file
```
---

## 🚀 Quick Start

From the repo root:

```bash
./scripts/traefik3-init.sh
```
