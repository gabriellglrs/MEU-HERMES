---
last_mapped_commit: 0efa1be56b39cf66a1d99c84de7d1a4732847da9
last_mapped_at: 2026-09-15
---
# Code Conventions — MEU-HERMES

> Date: 2026-09-16
> Repo: Hermes AI-agent config backup (`config.yaml`, `SOUL.md`, `skills/`, `plugins/`, `scripts/`)
> Focus: quality (style, naming, patterns, error handling)

## 1. Repository Shape

- Root is declarative config, not an app: `config.yaml` (active Hermes config, 232 lines), `config-hermes.yaml` (alternate model `gpt-oss:120b`), `SOUL.md` (persona + hard rules), `honcho.json`, `rtk-config.toml`, `.env.example`.
- Executable code lives in three places: `plugins/*/ __init__.py`, `skills/*/scripts/*.{py,cjs,sh}`, `scripts/*.sh` + `install.sh` / `backup-memory.sh` / `restore-memory.sh`.
- Docs-as-code: every skill ships `skills/<area>/<name>/SKILL.md` with YAML frontmatter (`name:`, `description:`, `version:`, `author:`, `platforms:`); references in `skills/<area>/<name>/references/*.md`; templates in `skills/brand/templates/brand-guidelines-starter.md`.
- `memory-backup/` mirrors live `%LOCALAPPDATA%/hermes` state (`memory-backup/config.yaml`, `memory-backup/SOUL.md`, `memory-backup/metadata.json`); do not edit by hand — regenerate via backup scripts.
- `cron-jobs/hermes-crontab` + `scripts/README.md` define the automation surface; logs go to `~/.hermes/logs/`.

## 2. Code Style

- **Python (plugins + skill helpers):** `#!/usr/bin/env python3`, `from __future__ import annotations`, 4-space indent, `snake_case` funcs/vars, `UPPER_SNAKE` constants (see `skills/web/blocked-page-recovery/scripts/recover_page.py`: `USER_AGENT`, `MIN_BODY_BYTES`, `INTERSTITIAL_TITLES`). Docstring-first modules that document usage + exit codes.
- **Node (brand/design skills):** `#!/usr/bin/env node`, JSDoc header with `Usage:` block, `camelCase` functions (`extractColorsFromMarkdown`, `generateColorScale`, `validateAsset` in `skills/brand/scripts/sync-brand-to-tokens.cjs` and `skills/brand/scripts/validate-asset.cjs`). `require('fs'|'path'|'child_process')`, no ESM — CommonJS only.
- **Bash (`scripts/*.sh`, `install.sh`):** `#!/bin/bash` + banner comment (`# ====...`), `set -e`, color vars `RED/GREEN/YELLOW/NC`, `UPPER_SNAKE` env (`DEST_DIR`, `HERMES_HOME`, `BACKUP_DIR`), user-facing `echo -e` with emoji prefix (`echo -e "${GREEN}✓ ..."` in `scripts/backup-configs.sh`).
- **YAML (`config.yaml`, `plugins/*/plugin.yaml`, `cron-jobs/hermes-crontab`):** 2-space indent, quoted empty strings (`service_tier: ''`), explicit lists for `plugins: enabled:`. Secrets only as `${VAR}` references (see `config.yaml` → `mcp_servers: linear: headers: Authorization: Bearer ${LINEAR_API_KEY}`); never inline tokens.
- **Markdown (`SOUL.md`, `README.md`, `skills/*/SKILL.md`):** ATX headings, fenced `bash/python` blocks, tables for matrices/contracts (see `SOUL.md` Honcho table + 4-phase debugging table). Language: `SOUL.md` + `scripts/*.sh` in pt-BR; skill code/comments in English.

## 3. Naming

- Skills: `kebab-case` directory + `name:` slug match (`skills/test-driven-development/SKILL.md` → `name: test-driven-development`; `skills/systematic-debugging/SKILL.md`; `skills/brand/SKILL.md`). Sub-skills nest by domain: `skills/productivity/xlsx/`, `skills/software-development/github/`, `skills/web/blocked-page-recovery/`.
- Scripts: verb-noun `kebab-case`: `skills/brand/scripts/sync-brand-to-tokens.cjs`, `skills/brand/scripts/inject-brand-context.cjs`, `skills/brand/scripts/extract-colors.cjs`, `skills/productivity/xlsx/scripts/xlsx_read.py`, `xlsx_create.py`, `xlsx_edit.py`, `csv_to_xlsx.py`.
- Tests colocate: `skills/brand/scripts/tests/test_sync_brand_to_tokens.py`, `skills/productivity/xlsx/tests/test_xlsx_skill.py`, `skills/ui-ux-pro-max/scripts/tests/test_core.py`.
- Plugins: `plugins/rtk-rewrite/__init__.py` + `plugins/rtk-rewrite/plugin.yaml` (hook `pre_tool_call`); `plugins/opencode/__init__.py` + `plugins/opencode/plugin.yaml`. Private module state prefixed `_` (`_rtk_available`, `_check_rtk`, `_warn`).
- Assets: enforced regex in `skills/brand/scripts/validate-asset.cjs` → `{type}_{campaign}_{description}_{YYYYMMDD}_{variant}.{ext}` (e.g. `banner_claude-launch_hero-image_20251209.png`).

## 4. Patterns

- **Fail-open adapters:** both plugins verify binary via `shutil.which()` and only warn to `stderr`, never raise (see `plugins/rtk-rewrite/__init__.py::register()` → `_check_rtk()` and `plugins/opencode/__init__.py::_check_opencode()`). Hook mutates `args["command"]` in place.
- **CLI-per-script:** every helper is independently runnable with `--help/--json/--dry-run/--out` and prints machine-readable JSON to stdout, human logs to stderr/console (see `skills/productivity/xlsx/scripts/xlsx_read.py` modes `--sheets/--json/--csv/--formulas/--notes/--names`; `skills/brand/scripts/sync-brand-to-tokens.cjs --dry-run`).
- **Explicit UTF-8 I/O:** `read_text(encoding="utf-8")`, `open(..., encoding="utf-8")`, `json.dumps(..., ensure_ascii=False)`; tests force `LC_ALL=C` to prove it (see `skills/productivity/xlsx/tests/test_xlsx_skill.py::run()`).
- **Idempotent restores:** `install.sh` backs up `$HERMES_HOME/config.yaml` to `$HERMES_HOME/backups/manual_$(date ...)` before `cp -v`, uses `mkdir -p` + `|| true` on optional copies; `scripts/backup-configs.sh` uses `cp ... || true` per source.
- **Skill contract:** frontmatter + `## When to Use` + `## Quick Start` with copy-paste `bash` block; mandated flows codified in `SOUL.md` (RTK-first, 21st.dev Step 0 for UI, Raptor-via-Kali prefix `wsl -d kali-linux -- bash -lc ...`).

## 5. Error Handling

- Python plugins: broad `try/except Exception as e: _warn(str(e)); return` — degrade, never break the agent loop (see `plugins/rtk-rewrite/__init__.py::_pre_tool_call()` handling `subprocess.TimeoutExpired` with `timeout=2`, allow-listing `ACCEPTED_REWRITE_RETURN_CODES = {0,3}` vs `EXPECTED_PASSTHROUGH_RETURN_CODES = {1,2}`).
- Skill scripts: nonzero exits with JSON envelope `{"ok": false}` on stderr (asserted in `skills/productivity/xlsx/tests/test_xlsx_skill.py::test_help_and_errors`); Node CLIs `process.exit(1)` with `console.error('❌ ...')` + early `fs.existsSync` guards (see `skills/brand/scripts/sync-brand-to-tokens.cjs::main()`).
- Bash: `set -e` + `2>/dev/null || true` for optional paths, `command -v X &> /dev/null` feature checks (see `scripts/backup-configs.sh`, `install.sh` Hermes-presence check + `curl -fsSL` fallback).
- Secrets hygiene: `security: redact_secrets: true`, `tirith_enabled: true, tirith_fail_open: true` in `config.yaml`; `.env` never committed (see `.gitignore`: `.env`, `auth.json`, `*.key`, `state.db*`, `sessions/`, `__pycache__/`); `.env.example` keeps redacted `LINEAR_API_KEY=***` placeholders.

## 6. What Not To Do

- No inline secrets, no new top-level config keys without bumping `_config_version: 44` in `config.yaml`, no verbose terminal calls bypassing `rtk` (per `SOUL.md` RTK rule), no UI work without 2–3 `21st.dev` references, no fix without `systematic-debugging` Phase 1 + `test-driven-development` RED proof.
