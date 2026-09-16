---
last_mapped_commit: 0efa1be56b39cf66a1d99c84de7d1a4732847da9
last_mapped_at: 2026-09-15
---
# MEU-HERMES — Architecture

> Date: 2026-09-16
> Repo kind: Hermes AI-agent config backup (declarative config + prompt identity + skill packs + plugins + ops automation)
> Source of truth for live agent home (`%LOCALAPPDATA%\hermes` on Windows, `$HOME/.hermes` on Linux)

## 1. Pattern / Architectural Style

- **Declarative config backup repo (no build, no server code).** Live behavior is interpreted by the external `hermes` binary; this repo only versions the inputs.
- **Convention-over-configuration skill system:** every capability is a folder with `SKILL.md` frontmatter (`name`, `description`) plus optional `scripts/`, `references/`, `templates/`.
- **Hook-based plugin extension:** Python adapters registered via `plugin.yaml` (`pre_tool_call`) that shell out to an external Rust binary (`rtk`).
- **Template + installer restore pattern:** `install.sh` / manual `Copy-Item` steps copy versioned files into the runtime home; `.env` secrets never versioned.
- **Cron-driven ops layer:** shell scripts in `scripts/` scheduled by `cron-jobs/hermes-crontab`, logging to `~/.hermes/logs/`.

## 2. Layers

### 2.1 Identity / Prompt Layer

- `SOUL.md` — agent name (Hermes), language (pt-BR), expertise areas (cybersecurity, coding, Linux, research, UI/UX), tool rules (RTK-first, Honcho memory, Raptor via Kali, 21st.dev Step 0), response format.
- `memory-backup/SOUL.md`, `memory-backup/USER.md`, `memory-backup/config.yaml` — point-in-time snapshots used by `backup-memory.sh` / `restore-memory.sh`.
- `SKILL-TIME-DEV-IA.md` — root spec for the `time-de-dev-ia` orchestrator role (Hermes=manager, Linear=board, Orca/opencode=executor, GSD phase loop).

### 2.2 Configuration Layer

- `config.yaml` (active, 232 lines, `_config_version: 44`, model `nemotron-3-ultra` via `ollama-cloud`) and `config-hermes.yaml` (variant, model `gpt-oss:120b`, extra plugin `orca-status`).
- Key sections in `config.yaml`: `model`, `database`, `agent`, `terminal`, `memory` (provider `honcho`), `delegation`, `skills`, `plugins` (`opencode`, `rtk-rewrite`), `security`, `gateway`, `mcp_servers` (`linear`, `21st`), `platform_toolsets` (`hermes-cli`, `hermes-telegram`, `hermes-discord`, etc.).
- `honcho.json` — memory peer binding (`peerName: gabriellucas`, `aiPeer: hermes`, `workspace: hermes`, `recallMode: hybrid`).
- `rtk-config.toml` — token-saver tuning (`[tracking]`, `[filters]`, `[tee]`, `[telemetry]`, `[hooks]`, `[limits]`).
- `.env.example` (549 lines) — template for all provider keys (`OLLAMA_API_KEY`, `LINEAR_API_KEY`, `TWENTYFIRST_API_KEY`, etc.); real `.env` is git-ignored.

### 2.3 Capability Layer (skills/)

- 30+ top-level domains under `skills/`: `skills/apple/`, `skills/cybersecurity/`, `skills/productivity/`, `skills/brand/`, `skills/design-system/`, `skills/ui-ux-pro-max/`, `skills/raptor/`, `skills/time-de-dev-ia/`, `skills/opencode/`, `skills/email/`, `skills/web/`, `skills/obra/`, etc.
- Standard skill shape: `skills/<domain>/<skill>/SKILL.md` + `scripts/*.py|*.cjs|*.sh` + `references/*.md` + `templates/*` + `tests/test_*.py`.
- Flagship skills: `skills/raptor/SKILL.md` (Kali WSL backend at `~/raptor`, Semgrep 1.177 in `~/raptor-tools` venv), `skills/ui-ux-pro-max/SKILL.md` (79 styles/192 palettes + mandatory 21st.dev lookup), `skills/time-de-dev-ia/SKILL.md` (GSD loop + Linear mapping), `skills/opencode/SKILL.md` (CLI delegation), `skills/rtk/SKILL.md` (token compression), `skills/email/himalaya/SKILL.md` (Himalaya CLI).
- `skills/.bundled_manifest`, `skills/.curator_state`, `skills/.hub/` — Hermes skill-hub bookkeeping; `install.sh` merges without deleting bundled skills.

### 2.4 Extension Layer (plugins/)

- `plugins/rtk-rewrite/__init__.py` — `register(ctx)` checks `shutil.which("rtk")`, subscribes `_pre_tool_call` to `pre_tool_call`; rewrites `terminal.command` via `subprocess.run(["rtk","rewrite",command], timeout=2)`, fail-open on codes `{1,2}`, accepts `{0,3}`.
- `plugins/rtk-rewrite/plugin.yaml` — declares `provides_hooks: [pre_tool_call]`.
- `plugins/opencode/__init__.py`, `plugins/opencode/plugin.yaml`, `plugins/opencode/README.md` — OpenCode CLI delegation integration (enabled via `hermes plugins enable opencode` in `install.sh`).

### 2.5 Automation / Ops Layer

- `scripts/daily-briefing.sh`, `scripts/monitor-system.sh`, `scripts/backup-configs.sh`, `scripts/cleanup-system.sh`, `scripts/security-check.sh` (+ `scripts/README.md` usage matrix).
- `cron-jobs/hermes-crontab` — 8 schedules (08:00 briefing, :30 monitor, 02:00 backup, Sun 03:00 cleanup, 06:00 security, Tue 04:00 apt upgrade, 22:00 git backup, hourly error count).
- `backup-memory.sh` (export `hermes sessions export --format jsonl --redact` + copy `SOUL.md`/`MEMORY.md`/`USER.md`/`config.yaml`/user skills + `tar -czf hermes-memory-backup_<TS>.tar.gz`) and `restore-memory.sh` (interactive restore with confirmations).
- `install.sh` — idempotent Linux installer (`HERMES_HOME=$HOME/.hermes`, backup to `backups/manual_<TS>`, copy configs/skills/plugins/scripts/cron-jobs, `chmod +x`, `.env` check).

## 3. Data Flow

1. **Boot:** `hermes` binary reads `$HERMES_HOME/config.yaml` + `SOUL.md` + `honcho.json` + `rtk-config.toml` + `.env` (+ `mcp_servers.linear`, `mcp_servers.21st` if keys present).
2. **Turn:** user prompt → `SOUL.md` system rules → Honcho recall (`honcho_profile` → `honcho_context` → `honcho_reasoning` → `honcho_conclude`) → skill routing by `SKILL.md` frontmatter/description → tool call.
3. **Tool interception:** `terminal` calls pass through `plugins/rtk-rewrite/__init__.py:pre_tool_call` → `rtk rewrite` → compressed command executes locally / docker / ssh / modal per `terminal.backend`.
4. **Delegated flows:**
   - Dev: Hermes → Linear issue (`mcp_servers.linear`) → Orca worktree or `opencode run` → `gh pr` → review → merge → Linear close (see `SKILL-TIME-DEV-IA.md`).
   - Security: Hermes (`skills/raptor/SKILL.md`) → `wsl -d kali-linux` → `~/raptor/raptor.py scan|sca|agentic` → findings → Linear tasks → fix.
   - UI: `skills/ui-ux-pro-max/SKILL.md` Step 0 → 21st.dev MCP `search`/`get_component` (or web) → local design system (`scripts/search.py --design-system`) → implementation citing URLs.
5. **Persistence:** sessions → `hermes sessions export` → `memory-backup/sessions_<TS>.jsonl` + `memory-backup/metadata.json` + `hermes-memory-backup_<TS>.tar.gz`; daily cron also pushes git backup at 22:00.

## 4. Key Abstractions

- **Skill (`SKILL.md`):** markdown + YAML frontmatter contract; discovered by description matching, not imports.
- **Plugin hook (`pre_tool_call`):** fail-open Python shim; real logic lives in external `rtk` Rust CLI.
- **Peer/workspace memory (Honcho):** `peerName`/`workspace` scoping with `per-directory` session strategy and `every-turn` injection.
- **MCP server entry:** URL + `Authorization: Bearer ${VAR}` + `connect_timeout` in `config.yaml:mcp_servers`.
- **Platform toolset:** per-channel capability list under `config.yaml:platform_toolsets` (`cli`, `telegram`, `discord`, `whatsapp`, `slack`, `signal`, `homeassistant`, `teams`, `google_chat`).
- **Guardrails:** `tool_loop_guardrails`, `gateway.bot_loop_guard`, `gateway.restart_loop_guard`, `gateway.respawn_storm`, `gateway.startup_watchdog`, `security.tirith_*`.

## 5. Entry Points

- `config.yaml` — primary runtime entry (model, memory, plugins, MCPs, gateway).
- `SOUL.md` — primary behavior entry (identity + mandatory tool workflows).
- `honcho.json` — memory entry; `rtk-config.toml` — token-economy entry; `.env` (from `.env.example`) — secrets entry.
- `install.sh` (Linux) / `README.md` PowerShell restore block (Windows) — provisioning entries.
- `plugins/rtk-rewrite/__init__.py:register` / `_pre_tool_call` — only code execution hook.
- `scripts/daily-briefing.sh` (08:00), `cron-jobs/hermes-crontab` (scheduler table), `backup-memory.sh` / `restore-memory.sh` (memory lifecycle).
- `SKILL-TIME-DEV-IA.md`, `skills/raptor/SKILL.md`, `skills/ui-ux-pro-max/SKILL.md`, `skills/opencode/SKILL.md` — flagship capability entries.
- `.planning/config.json` — GSD orchestrator tuning (`response_language: pt`, `use_worktrees: true`, `verifier/code_review: true`).

---
*Generated: 2026-09-16 | Scope: arch | Source: repo-wide Glob/Grep/Read of config, SOUL, skills, plugins, scripts, cron, memory-backup, docs*
