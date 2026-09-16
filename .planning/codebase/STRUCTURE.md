---
last_mapped_commit: 0efa1be56b39cf66a1d99c84de7d1a4732847da9
last_mapped_at: 2026-09-15
---
# MEU-HERMES — Structure

> Date: 2026-09-16
> Root: `C:\DEV\MEU-HERMES` (backup of `%LOCALAPPDATA%\hermes` + Kali Raptor backend)
> Installer target: `$HOME/.hermes` (Linux) / `%LOCALAPPDATA%\hermes` (Windows)

## 1. Directory Layout (top level)

- `config.yaml` — active Hermes config (232 lines, model `nemotron-3-ultra`, MCPs `linear`+`21st`, plugins `opencode`+`rtk-rewrite`).
- `config-hermes.yaml` — alternate variant (206 lines, model `gpt-oss:120b`, extra plugin `orca-status`).
- `SOUL.md` — agent identity + tool doctrines (267 lines: RTK, Honcho table, 4-phase debugging, Kanban, Raptor, 21st Step 0).
- `honcho.json` — memory binding (peer `gabriellucas`, workspace `hermes`, `recallMode: hybrid`).
- `rtk-config.toml` — RTK display/filter/tee/telemetry/hook/limit tuning (68 lines).
- `.env.example` — 549-line secrets template (`OLLAMA_API_KEY`, `LINEAR_API_KEY`, `TWENTYFIRST_API_KEY`, terminal/browser/voice/Teams/Slack/Telegram/Stt blocks); real `.env` git-ignored.
- `README.md` — status table (v0.21.3), file table, Windows/Linux restore steps, dev/security/UI flows, links.
- `INSTALACAO-E-CONFIGURACAO.md` — original install guide; `AUDITORIA-E-PLANEJAMENTO.md` — audit/plan (251 lines); `SKILL-TIME-DEV-IA.md` — dev-team orchestrator spec (101 lines, GSD loop + Orca-vs-opencode).
- `install.sh` — Linux provisioner (106 lines, backup + copy + `chmod +x` + `hermes plugins enable opencode`).
- `backup-memory.sh` / `restore-memory.sh` — memory export/import lifecycle (84 / 100 lines).
- `backup-memory.sh` writes to `memory-backup/`; `restore-memory.sh` reads back with `s/N` confirmations.
- `honcho.json` + `.env.example` + `rtk-config.toml` are copied verbatim by `install.sh` if present.
- `hermes-memory-backup_20260913_234833.tar.gz` — compressed snapshot of `memory-backup/`.
- `.gitignore`, `.git/`, `.planning/` — VCS + GSD state (see §5).

## 2. Key Locations by Area

### 2.1 `skills/` — capability packs (34 entries, largest tree)

- Top-level domains: `skills/apple/`, `skills/autonomous-ai-agents/`, `skills/banner-design/`, `skills/brand/`, `skills/creative/`, `skills/cybersecurity/`, `skills/design/`, `skills/design-system/`, `skills/devops/`, `skills/email/`, `skills/github/`, `skills/media/`, `skills/note-taking/`, `skills/nousresearch/`, `skills/obra/`, `skills/opencode/`, `skills/productivity/`, `skills/raptor/`, `skills/research/`, `skills/rtk/`, `skills/slides/`, `skills/social-media/`, `skills/software-development/`, `skills/systematic-debugging/`, `skills/test-driven-development/`, `skills/time-de-dev-ia/`, `skills/ui-styling/`, `skills/ui-ux-pro-max/`, `skills/web/`.
- Direct skills (flat): `skills/banner-design/SKILL.md`, `skills/design/SKILL.md`, `skills/design-system/SKILL.md`, `skills/opencode/SKILL.md`, `skills/github/SKILL.md`, `skills/systematic-debugging/SKILL.md`, `skills/ui-styling/SKILL.md`, `skills/slides/SKILL.md`, `skills/rtk/SKILL.md`, `skills/time-de-dev-ia/SKILL.md`, `skills/test-driven-development/SKILL.md`, `skills/simplify-code/SKILL.md`, `skills/requesting-code-review/SKILL.md`, `skills/raptor/SKILL.md`, `skills/brand/SKILL.md`.
- Nested examples: `skills/email/himalaya/SKILL.md` (+ `references/message-composition.md`, `references/configuration.md`), `skills/email/email-inbox-triage/SKILL.md`, `skills/apple/imessage/SKILL.md`, `skills/apple/findmy/SKILL.md`, `skills/apple/apple-notes/SKILL.md`, `skills/productivity/xlsx/SKILL.md` (+ `scripts/xlsx_*.py`, `references/restructuring.md`, `tests/test_xlsx_skill.py`), `skills/productivity/docx/SKILL.md`, `skills/cybersecurity/web-app-security/*.md` (16 guides: `sql-injection-*`, `jwt-token-*`, `graphql-*`, etc.), `skills/cybersecurity/threat-hunting/*.md`, `skills/web/blocked-page-recovery/SKILL.md` (+ `scripts/recover_page.py`), `skills/obra/using-superpowers/SKILL.md` (+ `references/pi-tools.md`, `hermes-tools.md`, `gemini-tools.md`, `codex-tools.md`, `antigravity-tools.md`), `skills/ui-ux-pro-max/SKILL.md` (+ `scripts/*.py`, `scripts/tests/test_*.py`), `skills/brand/scripts/*.cjs` (`validate-asset.cjs`, `sync-brand-to-tokens.cjs`, `inject-brand-context.cjs`, `extract-colors.cjs`) + `templates/brand-guidelines-starter.md`, `skills/design-system/templates/design-tokens-starter.json`.
- Hub bookkeeping: `skills/.bundled_manifest`, `skills/.curator_state`, `skills/.hub/` — do not hand-edit; `install.sh` merges `skills/*` over them.

### 2.2 `plugins/` — hook adapters (2 plugins)

- `plugins/rtk-rewrite/__init__.py` (80 lines, `register` + `_pre_tool_call` + `_check_rtk`), `plugins/rtk-rewrite/plugin.yaml` (`pre_tool_call`), `plugins/rtk-rewrite/__pycache__/` (build artifact, ignore).
- `plugins/opencode/__init__.py`, `plugins/opencode/plugin.yaml` (`name: opencode v1.0.0`), `plugins/opencode/README.md`, `plugins/opencode/__pycache__/` (ignore).

### 2.3 `scripts/` + `cron-jobs/` — ops automation

- `scripts/daily-briefing.sh` (morning briefing), `scripts/monitor-system.sh` (interval arg, `--once` in cron), `scripts/backup-configs.sh` (dest-dir arg), `scripts/cleanup-system.sh` (`--dry-run`), `scripts/security-check.sh`, `scripts/README.md` (160 lines: usage, cron install `crontab cron-jobs/hermes-crontab`, log table `~/.hermes/logs/`).
- `cron-jobs/hermes-crontab` (38 lines, 8 jobs — see Architecture §2.5).

### 2.4 `memory-backup/` — versioned memory snapshots

- `memory-backup/config.yaml`, `memory-backup/SOUL.md`, `memory-backup/USER.md`, `memory-backup/metadata.json` (hostname `INSS-PE02L9NU`, `hermes_version: v0.21.2`), `memory-backup/sessions_20260913_234833.jsonl`, `memory-backup/sessions_20260914_133431.jsonl`, `memory-backup/skills/` (user skills only, bundled excluded by `backup-memory.sh` loop).

### 2.5 `.planning/` — GSD orchestrator state

- `.planning/config.json` (25 lines: `response_language: pt`, `workflow.use_worktrees: true`, `verifier/code_review: true`, `parallelization.max_concurrent_agents: 3`).
- `.planning/codebase/` — this mapping output (`ARCHITECTURE.md`, `STRUCTURE.md`); empty before this run.

## 3. Naming Conventions

- **Config:** lowercase hyphenated yaml (`config.yaml`, `config-hermes.yaml`), `honcho.json` (lowercase json), `rtk-config.toml` (kebab toml), `.env.example` (dotted template).
- **Identity/docs:** UPPER snake markdown (`SOUL.md`, `USER.md`, `MEMORY.md`, `README.md`, `SKILL-TIME-DEV-IA.md`, `AUDITORIA-E-PLANEJAMENTO.md`, `INSTALACAO-E-CONFIGURACAO.md`).
- **Skills:** `skills/<domain>/<skill>/SKILL.md` (UPPER) with frontmatter `name: kebab-case` + `description: "..."`; helpers in `scripts/` (`snake_case.py`, `kebab-case.cjs`, `kebab-case.sh`), knowledge in `references/*.md`, starters in `templates/*`, tests in `tests/test_*.py` (`test_xlsx_skill.py`, `test_docx_skill.py`, `test_data_contracts.py`, etc.).
- **Plugins:** `plugins/<kebab-name>/__init__.py` + `plugin.yaml` (`name`, `version`, `description`, `hooks: [pre_tool_call]`); docs in `README.md`.
- **Ops:** `scripts/kebab-verb-noun.sh` (`daily-briefing.sh`, `security-check.sh`), single cron table `cron-jobs/hermes-crontab`, logs `~/.hermes/logs/<job>-YYYYMMDD.log`.
- **Memory snapshots:** `memory-backup/sessions_YYYYMMDD_HHMMSS.jsonl`, `hermes-memory-backup_YYYYMMDD_HHMMSS.tar.gz`, `metadata.json` with `timestamp`, `hermes_version`, `hostname`, `user`.
- **Shell vars:** `HERMES_HOME`, `BACKUP_DIR`, `TIMESTAMP` in `backup-memory.sh` / `restore-memory.sh` / `install.sh`; cron uses `~/.hermes/...` absolute paths with escaped `\%Y\%m\%d`.

## 4. Where To Add / Change Things

- New model/provider → edit `config.yaml:model` + add key to `.env` (from `.env.example`) — never commit secrets.
- New behavior rule → append to `SOUL.md` (Direct, técnico, eficiente) + snapshot via `backup-memory.sh`.
- New capability → create `skills/<domain>/<name>/SKILL.md` (+ `scripts/`, `references/` as needed); user skills auto-picked by `backup-memory.sh` exclusion loop.
- New terminal rewrite → extend `plugins/rtk-rewrite/__init__.py:_pre_tool_call` (keep fail-open) + declare in `plugins/rtk-rewrite/plugin.yaml`.
- New automation → add `scripts/<name>.sh` (document in `scripts/README.md`) + schedule line in `cron-jobs/hermes-crontab`, then `crontab cron-jobs/hermes-crontab`.
- New MCP → add `mcp_servers.<name>` block in `config.yaml` + key placeholder in `.env.example` + note in `README.md` status table.
- Restore on new machine → Windows: `README.md` PowerShell `Copy-Item` block; Linux: `bash install.sh` (copies `config.yaml`, `SOUL.md`, `honcho.json`, `rtk-config.toml`, `skills/`, `plugins/`, `scripts/`, `cron-jobs/`).

---
*Generated: 2026-09-16 | Scope: structure | Method: Glob `**/*` + Grep `SKILL.md` frontmatter + Read of configs, plugins, scripts, cron, install/restore, memory-backup, docs*
