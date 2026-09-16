---
last_mapped_commit: 0efa1be56b39cf66a1d99c84de7d1a4732847da9
last_mapped_at: 2026-09-15
---
# CONCERNS — MEU-HERMES (Hermes AI-agent config backup repo)

> Date: 2026-09-16
> Updated: 2026-09-16
> Focus: tech-debt / bugs / security / performance / fragile-areas
> Repo type: Hermes agent home backup (`config.yaml`, `SOUL.md`, `skills/`, `plugins/`, `scripts/`, `cron-jobs/`, `memory-backup/`)

## 0. TL;DR (highest risk first)

1. **Live secret committed:** `honcho.json` contains a real `hch-v3-...` apiKey AND is git-tracked — rotate immediately, purge history.
2. **Nightly `git add . && git push` cron** in `cron-jobs/hermes-crontab` can publish secrets/tarballs accidentally.
3. **Fail-open security posture:** `config.yaml` / `config-hermes.yaml` set `tirith_fail_open: true`, `trust_env: true`, `strict: false`.
4. **Plaintext secret backup:** `scripts/backup-configs.sh` copies `~/.hermes/.env` verbatim into timestamped dirs + tarball.
5. **Config drift:** `config.yaml` vs `config-hermes.yaml` diverged (model, plugins, `mcp_servers.21st`) with no single source of truth.
6. **Working-tree drift vs origin:** `skills-hermes/*` deleted (22 files), `SKILL-TIME-DEV-IA.md` + `skills/time-de-dev-ia/SKILL.md` modified, `.planning/` untracked.

---

## 1. Security — secrets handling

### 1.1 CRITICAL: live Honcho API key tracked in git

- File: `honcho.json` (line 2: `"apiKey": "hch-v3-qlio..."`, `peerName`, `workspace`, `recallMode`, `messageMaxChars: 25000`)
- Evidence: `git ls-files` lists `honcho.json`; `.gitignore` does NOT ignore it (only `.env`, `auth.json`, `*.key`, `*.pem`, `state.db*`).
- Impact: anyone with repo read access gets cross-session memory API access as `gabriellucas`/`hermes`.
- Fix (2026-09-16): rotate key at Honcho dashboard, `git rm --cached honcho.json`, add `honcho.json` + `**/honcho.json` to `.gitignore`, purge with `git filter-repo` / BFG, use `HONCHO_API_KEY` env + `~/.honcho/config.json` reference as `README.md` already suggests.

### 1.2 `.env` redaction is partial / misleading

- Template: `.env.example` (549 lines) correctly comments out providers (`OPENROUTER_API_KEY`, `GOOGLE_API_KEY`, `OLLAMA_API_KEY`, `GITHUB_TOKEN`, `SLACK_BOT_TOKEN`, `TELEGRAM_BOT_TOKEN`, `SUDO_PASSWORD`) but tail lines 546-549 contain `LINEAR_API_KEY=***`, `OLLAMA_API_KEY=***`, `TWENTYFIRST_API_KEY=***`.
- Risk: `***` looks like redaction after the fact; history may contain real values — audit `git log -p -- .env.example`, `git log -p -- config.yaml`.
- Good: `.gitignore` ignores `.env` and real `.env` is NOT in `git ls-files` (only `.env.example` is tracked).
- Fragile: `scripts/backup-configs.sh` lines 39-41 do `cp ~/.hermes/.env "$DEST_DIR/hermes/"` with no redaction, then `tar -czf backup-configs-*.tar.gz`; `backup-memory.sh` relies on `hermes sessions export --format jsonl --redact` — if `--redact` regresses, `memory-backup/sessions_*.jsonl` leaks.
- Fix: never copy `.env`; copy `.env.example` or `env --redact`; add `backup-configs-*.tar.gz`, `hermes-memory-backup_*.tar.gz`, `memory-backup/sessions_*.jsonl` handling policy; add pre-commit secret scan (`gitleaks`/`trufflehog`).

### 1.3 MCP headers interpolate raw env vars

- Files: `config.yaml` lines 200-210 (`mcp_servers.linear` + `mcp_servers.21st` with `Authorization: Bearer ${LINEAR_API_KEY}` / `${TWENTYFIRST_API_KEY}`), `config-hermes.yaml` lines 201-206 (linear only).
- Combined with `gateway.trust_env: true` (both configs) any skill/plugin code execution can read env — documented SSH-backend benefit in `.env.example` lines 260-274 does not apply to default `terminal.backend: local`.
- Fix: keep interpolation (do not hardcode), but set `gateway.trust_env: false` + `strict: true` where possible, scope `media_delivery_allow_dirs`, shorten `trust_recent_files_seconds: 600`.

### 1.4 Fail-open guardrails

- Files: `config.yaml` lines 114-118, `config-hermes.yaml` lines 171-175: `security.redact_secrets: true` (good) BUT `tirith_enabled: true` + `tirith_timeout: 5` + `tirith_fail_open: true`; `tool_loop_guardrails.hard_stop_enabled: false`; `gateway.strict: false`.
- Plugins fail open too: `plugins/opencode/__init__.py` (`_check_opencode()` warns once, returns False) and `plugins/rtk-rewrite/__init__.py` (`_pre_tool_call()` swallows `TimeoutExpired`/all `Exception`, 2s `subprocess.run(["rtk","rewrite",command])`).
- Fix: fail-closed for destructive tools, alert on `rtk rewrite` non-zero exit codes (`ACCEPTED_REWRITE_RETURN_CODES = {0,3}` vs `EXPECTED_PASSTHROUGH_RETURN_CODES = {1,2}` currently only `_warn()` to stderr).

---

## 2. Security — execution / supply chain

- File: `install.sh` lines 20-23: `curl -fsSL https://hermes.ai/install.sh | bash` with no checksum/pin; lines 43-82 `cp -rv skills/*`, `plugins/*`, `scripts/*`, `cron-jobs/*` + `chmod +x`.
- File: `cron-jobs/hermes-crontab` line 30: `0 4 * * 2 sudo apt-get update && sudo apt-get upgrade -y` (unattended sudo upgrade, no pin); line 34: `0 22 * * * cd ~/MEU-HERMES && git add . && git commit -m "backup: $(date...)" && git push` — commits whatever is in workdir including tarballs, `.planning/`, deleted `skills-hermes/`.
- File: `skills/web/blocked-page-recovery/scripts/recover_page.py`, `skills/media/youtube-content/scripts/fetch_transcript.py`, `skills/productivity/xlsx/scripts/*.py` — vendored executables with no lockfile audit; `skills/.hub/lock.json` + `skills/.hub/taps.json` + `skills/.hub/audit.log` need review before auto-update.
- Fix: pin installer hash, replace cron `git add .` with explicit `git add memory-backup config.yaml SOUL.md`, require `git diff --check` + secret scan.

---

## 3. Tech debt / bugs (observed 2026-09-16)

1. **Dual config, no owner:** `config.yaml` (232 lines, model `nemotron-3-ultra`, plugins `opencode,rtk-rewrite`, has `mcp_servers.21st`) vs `config-hermes.yaml` (206 lines, model `gpt-oss:120b`, plugins `opencode,orca-status,rtk-rewrite`, no `21st`). `install.sh` copies `config.yaml`; `memory-backup/config.yaml` is a third copy. Add header comment + `scripts/diff-configs.sh` check.
2. **Uncommitted deletions:** `git status --porcelain` shows `D skills-hermes/github/*` (12 files: `SKILL.md`, `references/auth.md`, `ci-troubleshooting.md`, `code-review.md`, `conventional-commits.md`, `github-api-cheatsheet.md`, `issue-to-pr.md`, `issues.md`, `pr-workflow.md`, `repo-management.md`, `review-output-template.md`, `scripts/gh-env.sh`, `scripts/git-credential-token.py`, `templates/*`) + `D skills-hermes/opencode/SKILL.md`, `D skills-hermes/requesting-code-review/SKILL.md`, `D skills-hermes/simplify-code/SKILL.md`, `D skills-hermes/systematic-debugging/SKILL.md`, `D skills-hermes/test-driven-development/SKILL.md`; `M SKILL-TIME-DEV-IA.md`, `M skills/time-de-dev-ia/SKILL.md`. Decide: restore vs `git rm`.
3. **Linux-only scripts on Windows checkout:** `scripts/security-check.sh` (`apt`, `ss`, `journalctl`, `systemctl`, `ufw`), `scripts/daily-briefing.sh` (`top`, `free`, `journalctl`), `scripts/monitor-system.sh` (infinite `while true; clear`), `scripts/cleanup-system.sh` (`sudo apt-get clean/autoremove`, `journalctl --vacuum-time`, `docker system prune -f`, `find /tmp -delete`), `scripts/backup-configs.sh` (`cp -r /etc/nginx /etc/ssh /etc/docker`). On `C:\DEV\MEU-HERMES` these fail; `cron-jobs/hermes-crontab` paths `~/.hermes/scripts/*` + `~/MEU-HERMES` disagree with `backup-memory.sh` `BACKUP_DIR="$HOME/MEU-HERMES/memory-backup"`.
4. **Destructive restore:** `restore-memory.sh` overwrites `$HERMES_HOME/SOUL.md`, `MEMORY.md`, `USER.md`, `config.yaml` (with `.bak` only for config), bulk `cp -r` skills, optional `hermes sessions import` newest `sessions_*.jsonl` — no dry-run, no diff, `set -e` aborts mid-restore leaving half state.
5. **Stale docs:** `AUDITORIA-E-PLANEJAMENTO.md` still has `Data: $(date +%Y-%m-%d)` unrendered and Ubuntu-22.04/Orca AppImage plan; `INSTALACAO-E-CONFIGURACAO.md`, `README.md`, `SKILL-TIME-DEV-IA.md` predate `nemotron-3-ultra` + `21st` MCP change.
6. **Committed bloat:** `hermes-memory-backup_20260913_234833.tar.gz` tracked; `memory-backup/` contains `sessions_20260913_234833.jsonl`, `sessions_20260914_133431.jsonl`, `metadata.json` (hostname `INSS-PE02L9NU`, user `GABRIELLUCASRODRIGUE`, `hermes_version v0.21.2`), `SOUL.md`, `USER.md`, `config.yaml` — duplicates live files, balloons `git diff --stat`.
7. **Pycache present:** `plugins/opencode/__pycache__/__init__.cpython-311.pyc`, `plugins/rtk-rewrite/__pycache__/__init__.cpython-311.pyc`, `skills/ui-ux-pro-max/scripts/__pycache__/*.pyc` exist on disk (covered by `.gitignore` `__pycache__/`, `*.pyc` — verify not force-added).
8. **No tests/CI:** shell scripts have no `shellcheck`/`bats`; Python skills (`skills/productivity/xlsx/tests/test_xlsx_skill.py`, `skills/ui-ux-pro-max/scripts/tests/test_*.py`, `skills/ui-ux-pro-max/scripts/validate_data.py`) not wired to CI; `updates.pre_update_backup: false`, `non_interactive_local_changes: stash` risks silent stash loss.

---

## 4. Performance

- Files: `config.yaml` lines 10, 97-99 + `config-hermes.yaml` lines 10, 92-96: `agent.max_turns: 500`, `delegation.max_iterations: 250`, `max_concurrent_children: 5`, `max_spawn_depth: 3`, `orchestrator_enabled: true` — runaway cost if planner fans out (see `SOUL.md` Kanban fan-out pattern).
- Files: `config.yaml` lines 48-66: `compression.threshold: 0.5`, `target_ratio: 0.15`, `protect_last_n: 20`, `proactive_prune_min_result_chars: 8000` + `honcho.json` `messageMaxChars: 25000`, `injectionFrequency: every-turn`, `contextCadence: 1` — high per-turn injection; `memory.memory_char_limit: 8000`, `user_char_limit: 3000`, `nudge_interval: 10`.
- Files: `honcho.json` (`recallMode: hybrid`, `dialecticReasoningLevel: medium`, `dialecticDepth: 2`, `dialecticCadence: 2`) + `SOUL.md` Honcho table (`honcho_reasoning` medium-high cost) — prefer `honcho_profile`/`honcho_search`/`honcho_context` per `SOUL.md` flow.
- Files: `rtk-config.toml` (`history_days: 90`, `tee.mode: failures`, `telemetry.enabled: true`) + `SOUL.md` RTK section (`rtk git/test/build/docker`, `rtk gain`, `rtk discover`) — RTK mitigates verbosity but `terminal.lifetime_seconds: 600`, `code_execution.timeout: 300`, `max_tool_calls: 50`, `gateway.max_inbound_media_bytes: 134217728` (128 MB) allow heavy jobs.
- Fix: lower `max_turns`/`max_iterations` defaults, add per-skill budgets, keep RTK `rewrite` hook enabled, archive old `memory-backup/sessions_*.jsonl` out of git.

---

## 5. Fragile areas — watch list

| Area | Files | Why fragile |
|---|---|---|
| Secrets | `honcho.json`, `.env.example`, `config.yaml`, `config-hermes.yaml`, `memory-backup/sessions_*.jsonl`, `hermes-memory-backup_*.tar.gz` | live key tracked; `***` redaction unverified; tarballs/sessions may embed secrets |
| Backup/restore | `backup-memory.sh`, `restore-memory.sh`, `scripts/backup-configs.sh`, `memory-backup/metadata.json` | hardcoded `$HOME/MEU-HERMES`; `|| true` hides `hermes sessions export/import` failures; no checksum |
| Cron | `cron-jobs/hermes-crontab` | `git add .` auto-push; `sudo apt-get upgrade -y`; log dirs `~/.hermes/logs/` never rotated; `monitor-system.sh --once` flag unsupported (script ignores args, loops forever) |
| Plugins | `plugins/opencode/__init__.py`, `plugins/opencode/plugin.yaml`, `plugins/rtk-rewrite/__init__.py`, `plugins/rtk-rewrite/plugin.yaml` | version `1.0.0` vs `0.1.0`; no tests; silent fail-open; `rtk`/`opencode` binary presence assumed |
| Skills hub | `skills/.hub/lock.json`, `skills/.hub/taps.json`, `skills/.hub/audit.log`, `skills/.curator_state`, `skills/.bundled_manifest`, `skills/time-de-dev-ia/SKILL.md` | auto-curated; local `M` + upstream deletions diverge; `SKILL-TIME-DEV-IA.md` root copy drifts from namespaced copy |
| Gateway | `config.yaml` lines 126-163, `config-hermes.yaml` lines 122-159 | `scale_to_zero.idle_timeout_minutes: 2` + `restart_loop_guard`/`respawn_storm` can flap; `message_timestamps.enabled: false` hurts debugging; `auto_migrate: true` migrates without backup (`pre_update_backup: false`) |
| Docs | `SOUL.md`, `README.md`, `INSTALACAO-E-CONFIGURACAO.md`, `AUDITORIA-E-PLANEJAMENTO.md`, `SKILL-TIME-DEV-IA.md` | `SOUL.md` (267 lines) mandates Raptor/Kali (`wsl -d kali-linux`), 21st.dev-first UI, RTK-always — breaks on machines without WSL/Kali/MCP keys |

---

## 6. Recommended next steps (2026-09-16)

1. Rotate Honcho key; untrack + ignore `honcho.json`; scan history for `.env`, `hch-`, `ghp_`, `sk-`.
2. Replace cron `git add .` with explicit allowlist + secret scan; stop committing `*.tar.gz` (keep only `memory-backup/` text or use Releases).
3. Unify config: delete or symlink `config-hermes.yaml` → `config.yaml` (or document `config-hermes.yaml` as archive); add `scripts/diff-configs.sh`.
4. Harden `security-check.sh`/`backup-configs.sh`/`cleanup-system.sh` for Windows (`$IsWindows` guard) or mark Linux-only; fix `monitor-system.sh --once`.
5. Add `shellcheck`, `gitleaks`, `pytest -q skills/ui-ux-pro-max/scripts/tests` to CI; set `updates.pre_update_backup: true`.
6. Resolve `skills-hermes/` deletions (`git rm` vs restore) and commit `SKILL-TIME-DEV-IA.md` / `skills/time-de-dev-ia/SKILL.md` intentionally on branch `gabriellglrs/teste-fluxo-e2e` vs `main`.

---
*Generated 2026-09-16 by codebase-mapper (concerns focus). Sources: `git status`, `git log --oneline -10`, `git diff --stat`, `git ls-files`, `git remote -v`, plus reads of files listed above.*
