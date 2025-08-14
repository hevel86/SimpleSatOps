#!/bin/bash
set -euo pipefail

echo "🚀 Bootstrapping SimpleSatOps repository..."

# Set custom hooks path
if git config core.hooksPath &>/dev/null; then
    echo "✅ Git hooks path already set."
else
    git config core.hooksPath .githooks
    echo "✅ Set Git hooks path to .githooks"
fi

# Pull TruffleHog Docker image if Docker is available
if command -v docker &>/dev/null && docker info &>/dev/null; then
    echo "🐳 Pulling TruffleHog Docker image..."
    docker pull ghcr.io/trufflesecurity/trufflehog:latest
else
    echo "⚠️  Docker not found or not running. Skipping TruffleHog image pull."
fi

echo "🎉 Bootstrap complete."
