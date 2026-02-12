# Repository Guidelines

## Project Structure & Module Organization
- Each service lives in its own directory (e.g., `traefik3`, `uptime_kuma`, `joplin`, `it-tools`, `ntfy`, `portainer`, `rustdesk`, `semaphoreui`, `wishlist`). Each contains a `docker-compose.yml` and typically a `.env` for overrides and a `secrets/` or token file when needed.
- Persistent data folders (e.g., `joplin/postgres13_data`, `uptime_kuma/uptime_kuma_data`) are kept alongside the compose file; avoid committing generated volume contents.
- Most stacks join the external `t3_proxy` network to be routed by Traefik; ensure that network exists (`docker network create t3_proxy`) before bringing up new services.

## Build, Test, and Development Commands
- Work inside a service directory: `cd traefik3 && docker compose pull && docker compose up -d` to start or refresh a stack.
- Validate configs before running: `docker compose config` (catches missing env vars or YAML errors).
- Inspect runtime state: `docker compose ps` and `docker compose logs -f <service>`; stop with `docker compose down` (add `--volumes` only when you intentionally want to wipe data).
- Keep `.env` files aligned with any `.env.example` (e.g., `traefik3/.env.example`) and load secrets through files when possible (`CF_DNS_API_TOKEN_FILE`, `postgres_secret`).

## Coding Style & Naming Conventions
- YAML is 2-space indented; prefer long-form keys for clarity. Service names mirror container names for easy lookup in logs.
- Environment variable keys are uppercase with underscores; define defaults in `.env` and reference in compose via `${VAR}`.
- Traefik labels follow the existing pattern: routers keyed by subdomain (e.g., `uptime-kuma.${DOMAINNAME}`) and `traefik.http.services.<name>.loadbalancer.server.port=<internalPort>`.

## Testing Guidelines
- No unit test suite exists; verification is runtime-focused. Run `docker compose config` and `docker compose up` to ensure containers start cleanly.
- For changes affecting routing, confirm Traefik picks up rules: `docker compose logs -f traefik` and load the target hostname through the proxy.
- When modifying images or volumes, confirm data persistence by restarting the stack and checking `docker compose ps` and service logs.

## Commit & Pull Request Guidelines
- Recent commits use `type(scope): detail` (e.g., `feat(docker): add uptime-kuma docker-compose`, `chore(docker): update traefik image tag`). Follow that format and keep scopes to the touched directory.
- PRs should state what service was changed, why, required env/secrets updates, and any migration notes. Include evidence of validation (commands run, log checks) and call out if data volumes need manual handling.

## Security & Configuration Tips
- Never commit real secrets; keep `.env`, `cf_api_token.txt`, and `secrets/` files local. Prefer the `_FILE` pattern for sensitive values.
- Sanity-check permissions on mounted host paths (especially `/var/run/docker.sock` and volume mounts) and avoid widening them beyond what the compose already specifies.
