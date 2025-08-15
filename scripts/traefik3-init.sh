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
    cat > data/traefik.yml <<'EOF'
api:
  dashboard: true
  debug: true
  insecure: false

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"

serversTransport:
  insecureSkipVerify: true

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  # file:
  #   filename: /config.yml

certificatesResolvers:
  cloudflare:
    acme:
      email: your@email.com
      storage: acme.json
      caServer: https://acme-v02.api.letsencrypt.org/directory
      # caServer: https://acme-staging-v02.api.letsencrypt.org/directory
      dnsChallenge:
        provider: cloudflare
        # disablePropagationCheck: true
        # delayBeforeCheck: 60s
        resolvers: 
          - "1.1.1.1:53"
          - "1.0.0.1:53"

log:
  level: INFO
EOF
else
    echo "✅ data/traefik.yml already exists"
fi

echo "🧩 Init complete. You can now launch the stack manually after editing the proper files:"
echo "    docker compose up -d"
