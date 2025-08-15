#!/bin/bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../docker/traefik3"

echo "🚀 Initializing Traefik 3 setup..."

# 1. Copy .env.example to .env if needed
if [ ! -f .env ]; then
    echo "📄 Copying .env.example → .env"
    cp .env.example .env
else
    echo "✅ .env already exists"
fi

# 2. Create cf_api_token.txt if missing
if [ ! -f cf_api_token.txt ]; then
    echo "🔐 Creating cf_api_token.txt with placeholder"
    echo "PUT_YOUR_CF_API_TOKEN_HERE" > cf_api_token.txt
else
    echo "✅ cf_api_token.txt already exists"
fi

# 3. Create data/ and rules/ directories
mkdir -p data rules

# 4. Create acme.json if missing, set perms
if [ ! -f data/acme.json ]; then
    echo "📄 Creating data/acme.json"
    touch data/acme.json
    chmod 600 data/acme.json
else
    echo "✅ data/acme.json exists"
fi

# 5. Create data/traefik.yml if missing
if [ ! -f data/traefik.yml ]; then
    echo "📄 Creating base data/traefik.yml"
    cat > data/traefik.yml <<EOF
entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"

providers:
  docker:
    exposedByDefault: false
  file:
    directory: /config
    watch: true

api:
  dashboard: true

certificatesResolvers:
  cloudflare:
    acme:
      email: you@example.com
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
EOF
else
    echo "✅ data/traefik.yml already exists"
fi

# 6. (Optional) Start stack
echo "🐳 Launching stack..."
docker compose up -d

echo "✅ Traefik 3 setup complete."
