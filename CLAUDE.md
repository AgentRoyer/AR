# AgentRoyer (AR)

Multi-language stack behind an nginx HTTPS reverse proxy, run with Docker Compose inside a GitHub Codespace (Docker-in-Docker).

- `ARsetup.md` — the full install recipe. There is no `run_task.py`; steps are executed by hand.
- Services (`docker-compose.yml`): `app-cfml` (Lucee 7, :8001), `app-rust` (:8002), `app-go` (:8003), `app-python` (Flask, :8004), `nginx` (:443/:80).
- URLs: `https://localhost` (landing page), `https://{cfml,rust,go,python}.localhost`.
- `.env` and `.certs/` (self-signed) are gitignored — never commit them.

## Codespace gotchas

- Container-to-container TCP times out after a restart (DinD iptables FORWARD). Fix:
  ```bash
  BR=br-$(docker network inspect ar_agentroyer-net -f '{{.Id}}' | cut -c1-12)
  sudo iptables-legacy -I FORWARD -i $BR -j ACCEPT
  sudo iptables-legacy -I FORWARD -o $BR -j ACCEPT
  ```
- After `sed -i nginx.conf`, restart nginx: the single-file bind mount keeps the old inode.
- Claude Code state lives in `/workspaces/.claude-home` (symlinked into `~` by `scripts/claude-persist.sh` on every start), so conversations survive restarts and rebuilds.
