---
last_mapped_commit: 0efa1be56b39cf66a1d99c84de7d1a4732847da9
last_mapped_at: 2026-09-15
---
# STACK — MEU-HERMES (Hermes AI-agent config backup)

> Date: 2026-09-16
> Repo root: `C:\DEV\MEU-HERMES`
> Type: config-backup repo (no compiled app; Hermes Agent home snapshot + skills/plugins/scripts)

## 1. Languages

- **Python 3.10+ / 3.11** — plugins + skill scripts (stdlib only + `pytest` for tests).
  - `plugins/opencode/__init__.py` (shutil/sys, fail-open adapter)
  - `plugins/rtk-rewrite/__init__.py` (subprocess bridge to `rtk rewrite`, 2s timeout)
  - `skills/web/blocked-page-recovery/scripts/recover_page.py` (`urllib`, `argparse`, `json`)
  - `skills/productivity/xlsx/scripts/*.py` (`xlsx_create.py`, `xlsx_read.py`, `xlsx_edit.py`, `xlsx_recalc.py`, `csv_to_xlsx.py`)
  - `skills/nousresearch/youtube-content/scripts/fetch_transcript.py`
  - `skills/ui-ux-pro-max/scripts/*.py` + `skills/design-system/scripts/slide-token-validator.py`
- **Bash (POSIX sh)** — automation + installer.
  - `install.sh`, `backup-memory.sh`, `restore-memory.sh`
  - `scripts/daily-briefing.sh`, `scripts/monitor-system.sh`, `scripts/backup-configs.sh`, `scripts/cleanup-system.sh`, `scripts/security-check.sh`
- **Node.js 18+ (CommonJS `.cjs`)** — design/brand token tooling.
  - `skills/design-system/scripts/validate-tokens.cjs`, `skills/design-system/scripts/generate-tokens.cjs`, `skills/design-system/scripts/slide_search_core.py`
  - `skills/brand/scripts/validate-asset.cjs`, `skills/brand/scripts/sync-brand-to-tokens.cjs`, `skills/brand/scripts/inject-brand-context.cjs`
- **PowerShell 7+** — Windows restore path documented in `README.md` (`Copy-Item` to `%LOCALAPPDATA%\hermes`).
- **Rust (external binary)** — RTK 0.48.0 token-killer invoked as `rtk` CLI, configured by `rtk-config.toml`.
- **Markdown/YAML/TOML/JSON** — all agent configuration (see below).

## 2. Runtime

- **Hermes Agent v0.21.3** (Windows `%LOCALAPPDATA%\hermes`, Linux `$HOME/.hermes`) — primary runtime, not built here.
- **Terminal backend: `local`** with Docker/SSH/Modal/Singularity options (`config.yaml` → `terminal.backend`, `TERMINAL_*` in `.env.example`).
  - Container image: `nikolaik/python-nodejs:python3.11-nodejs20` (`TERMINAL_MODAL_IMAGE` in `.env.example`)
  - Limits: `container_cpu: 2`, `container_memory: 8192`, `lifetime_seconds: 600`, `timeout: 300`
- **Python venvs**: `~/raptor-tools` (Semgrep 1.177) for Kali scans; `.venv` hints in `skills/banner-design/SKILL.md`.
- **Node**: `npx shadcn-ui@latest`, `npm i -g opencode-ai@latest`, `npm install -g @openai/codex`, `npm install -g @anthropic-ai/claude-code`.
- **Cron/crontab** — `cron-jobs/hermes-crontab` (8 jobs: briefing, monitor, backup, cleanup, security, apt upgrade, git push, error count).

## 3. Frameworks

- **Hermes plugin SDK (Python `register(ctx)` + `pre_tool_call` hook)** — `plugins/rtk-rewrite/plugin.yaml`, `plugins/opencode/plugin.yaml`.
- **Hermes Skills spec (`SKILL.md` + `DESCRIPTION.md`)** — 40+ skills under `skills/` (e.g. `skills/raptor/SKILL.md`, `skills/ui-ux-pro-max/SKILL.md`, `skills/time-de-dev-ia/SKILL.md`).
- **Tailwind CSS + shadcn/ui + React** — target stack for `skills/ui-styling/` and `skills/design-system/references/tailwind-integration.md`.
- **Chart.js 4.4.1 via CDN** — slides (`skills/design-system/SKILL.md`).
- **Manim CE v0.20.1 + LaTeX + ffmpeg** — `skills/creative/manim-video/SKILL.md` (optional).

## 4. Dependencies

- **Python dev/test**: `pytest>=8.0.0`, `pytest-cov>=4.1.0`, `pytest-mock>=3.12.0` (`skills/ui-styling/scripts/requirements.txt`); stdlib-only at runtime.
- **External CLIs (not vendored)**: `hermes`, `rtk`, `opencode`, `codex`, `claude`, `gh` (GitHub CLI 2.101), `op` (1Password), `himalaya`, `wsl -d kali-linux`, `semgrep`, `gdb`, `radare2`, `afl++`, `coccinelle`, `z3`.
- **No `package.json` / `requirements.txt` at root** — this repo intentionally has zero build dependencies; see `install.sh` which curls `https://hermes.ai/install.sh`.
- **Cached bytecode**: `plugins/*/ __pycache__/*.pyc` (cpython-311) and `skills/ui-ux-pro-max/scripts/__pycache__/*.pyc` (cpython-314) — not sources.

## 5. Configuration

- `config.yaml` — active Hermes config (`model.nemotron-3-ultra`, `provider: ollama-cloud`, `mcp_servers.linear`, `mcp_servers.21st`, `plugins`, `memory.provider: honcho`, `web.search_backend: searxng`).
- `config-hermes.yaml` — variant with `model.gpt-oss:120b` + extra plugin `orca-status`.
- `SOUL.md` — persona + hard rules (RTK-always, 21st Step-0, Raptor, Honcho flow).
- `honcho.json` — Honcho peer `gabriellucas` / workspace `hermes`, `recallMode: hybrid`.
- `rtk-config.toml` — `[tracking]`, `[display]`, `[filters]`, `[tee]`, `[telemetry]`, `[limits]` (e.g. `grep_max_results = 50`).
- `.env.example` — 549-line template for all provider/tool keys (never commit real `.env`; `.gitignore` covers it).
- `.planning/config.json` — orchestrator workflow (`research`, `plan_check`, `verifier`, `max_concurrent_agents: 3`).
- `cron-jobs/hermes-crontab`, `scripts/README.md`, `README.md`, `INSTALACAO-E-CONFIGURACAO.md`, `AUDITORIA-E-PLANEJAMENTO.md`, `SKILL-TIME-DEV-IA.md`.

> Updated: 2026-09-16
