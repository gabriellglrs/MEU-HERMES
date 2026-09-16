---
last_mapped_commit: 0efa1be56b39cf66a1d99c84de7d1a4732847da9
last_mapped_at: 2026-09-15
---
# INTEGRATIONS — MEU-HERMES (Hermes AI-agent config backup)

> Date: 2026-09-16
> Sources: `config.yaml`, `config-hermes.yaml`, `SOUL.md`, `.env.example`, `honcho.json`, `skills/*/SKILL.md`, `README.md`

## 1. External APIs (LLM providers — OpenAI-compatible)

All keys templated in `.env.example`; active provider set in `config.yaml` (`model.provider: ollama-cloud`, `model.default: nemotron-3-ultra`, `base_url: https://ollama.com/v1`).

- **Ollama Cloud** (`OLLAMA_API_KEY`, `OLLAMA_BASE_URL`) — primary; variant `config-hermes.yaml` uses `gpt-oss:120b`.
- **OpenRouter** (`OPENROUTER_API_KEY`) — documented fallback provider (`config.yaml` lines 217-232).
- **Fireworks AI** (`FIREWORKS_API_KEY`), **NovitaAI** (`NOVITA_API_KEY`), **Google AI Studio/Gemini** (`GOOGLE_API_KEY`/`GEMINI_API_KEY`), **z.ai/GLM** (`GLM_API_KEY`), **Kimi/Moonshot** (`KIMI_API_KEY`, `KIMI_CN_API_KEY`), **Arcee** (`ARCEEAI_API_KEY`), **MiniMax** (`MINIMAX_API_KEY`/`MINIMAX_CN_API_KEY`), **HuggingFace** (`HF_TOKEN`), **DeepInfra** (`DEEPINFRA_API_KEY`), **Qwen OAuth** (`~/.qwen/oauth_creds.json`), **Xiaomi MiMo** (`XIAOMI_API_KEY`), **Upstage** (`UPSTAGE_API_KEY`), **Ramp Router** (`RAMP_ROUTER_API_KEY`), **Nebius** (`NEBIUS_API_KEY`), **Tencent TokenHub/TokenPlan** (`TOKENHUB_API_KEY`, `TOKENPLAN_API_KEY`).
- **OpenCode Zen/Go/Free** (`OPENCODE_ZEN_API_KEY`, `OPENCODE_GO_API_KEY`) — curated coding models via `plugins/opencode/__init__.py` + `skills/autonomous-ai-agents/opencode/SKILL.md` (`npm i -g opencode-ai@latest`).
- **Tool APIs**: Exa (`EXA_API_KEY`), Parallel (`PARALLEL_API_KEY`), Firecrawl (`FIRECRAWL_API_KEY` — `web.extract_backend: firecrawl` in `config.yaml`), SearXNG (`web.search_backend: searxng`), FAL.ai (`FAL_KEY`), Browserbase (`BROWSERBASE_API_KEY`, `BROWSERBASE_PROJECT_ID`, `BROWSERBASE_PROXIES=true`), Reddit app (`REDDIT_CLIENT_ID`/`REDDIT_CLIENT_SECRET`), GitHub (`GITHUB_TOKEN`, `GITHUB_APP_ID` — `gh auth login` required per `README.md`), 1Password CLI (`op read/inject/run` in `SOUL.md`), Codex CLI (`codex exec` in `SOUL.md`).

## 2. Databases / Memory / Storage

- **Honcho (cross-session memory)** — `memory.provider: honcho` in `config.yaml`; `honcho.json` (`peerName: gabriellucas`, `workspace: hermes`, `recallMode: hybrid`); `HONCHO_API_KEY` in `.env.example`; flow `honcho_profile/search/context/reasoning/conclude` in `SOUL.md`.
- **SQLite WAL** — `database.journal_mode: wal` in `config.yaml`; sessions persisted via `gateway.write_sessions_json: true`.
- **Local filesystem stores** — `memory-backup/USER.md`, `memory-backup/SOUL.md`, `hermes-memory-backup_20260913_234833.tar.gz`, `backup-memory.sh` / `restore-memory.sh`; logs to `~/.hermes/logs/` (`scripts/README.md`).
- **No Postgres/MySQL/Redis** — none referenced; `platform_toolsets` are channel toolsets, not DBs.

## 3. Auth providers

- **OAuth**: OpenAI Codex (`hermes auth`), Nous Portal, Qwen (`qwen auth qwen-oauth`), GitHub App + `gh` CLI, Azure AD for Teams Bot (`TEAMS_CLIENT_ID`/`TEAMS_CLIENT_SECRET`/`TEAMS_TENANT_ID` in `.env.example`), GCP Service Account JSON for Google Chat (`GOOGLE_CHAT_SERVICE_ACCOUNT_JSON`).
- **API-key / Bearer**: all LLM/tool providers above + `LINEAR_API_KEY` + `TWENTYFIRST_API_KEY` injected as `Authorization: Bearer` headers in `config.yaml` → `mcp_servers`.
- **Allowlist gating**: `TELEGRAM_ALLOWED_USERS`, `SLACK_ALLOWED_USERS`, `TEAMS_ALLOWED_USERS`, `GOOGLE_CHAT_ALLOWED_USERS`, `WHATSAPP_ALLOWED_USERS`, `EMAIL_ALLOWED_USERS`, `GATEWAY_ALLOW_ALL_USERS=false` in `.env.example`; `security.redact_secrets: true`, `tirith_enabled: true` in `config.yaml`.
- **Voice/STT auth**: `VOICE_TOOLS_OPENAI_KEY`, `GROQ_API_KEY`, `ELEVENLABS_API_KEY` (`stt.language: pt`, `whisper-1` in `config.yaml`).

## 4. Webhooks / Messaging / Cron delivery

- **Telegram** (`TELEGRAM_BOT_TOKEN`, `TELEGRAM_WEBHOOK_URL`, `TELEGRAM_WEBHOOK_PORT`, long-poll default) — `platform_toolsets.telegram: hermes-telegram` in `config.yaml`.
- **Slack** (`SLACK_BOT_TOKEN`, `SLACK_APP_TOKEN` Socket Mode) — `hermes-slack`.
- **Discord / WhatsApp (Baileys `hermes whatsapp`) / Signal / HomeAssistant / QQBot / Yuanbao / Teams (port 3978) / Google Chat (Pub/Sub)** — all declared in `config.yaml` → `platform_toolsets`; IMAP/SMTP email (`EMAIL_IMAP_HOST`, `EMAIL_SMTP_HOST`) and Himalaya CLI (`himalaya envelope/message/template` in `SOUL.md`).
- **Cron → channel delivery**: `TELEGRAM_HOME_CHANNEL`, `TEAMS_HOME_CHANNEL`, `GOOGLE_CHAT_HOME_CHANNEL` + `cron.catch_up_missed: true` in `config.yaml`; 8 jobs in `cron-jobs/hermes-crontab` (briefing 08h, monitor 30min, backup 02h, cleanup Sun 03h, security 06h, apt Tue 04h, git push 22h, error-count hourly).

## 5. MCP servers

- **Linear** (`https://mcp.linear.app/mcp`, `Authorization: Bearer ${LINEAR_API_KEY}`, `connect_timeout: 60`) in `config.yaml` + `config-hermes.yaml`; usage `mcp_servers.linear` per `SOUL.md`; setup `hermes mcp add linear` per `INSTALACAO-E-CONFIGURACAO.md`; status registered-but-key-missing per `README.md`.
- **21st.dev** (`https://21st.dev/api/mcp`, `Authorization: Bearer ${TWENTYFIRST_API_KEY}`) in `config.yaml` only; mandatory Step-0 `search`/`get_component` in `SOUL.md` + `skills/ui-ux-pro-max/SKILL.md`; catalog `https://21st.dev/llms.txt`.
- **No other MCP servers** vendored; fallback-model providers (openrouter/openai-codex/nous/zai/kimi/minimax/bedrock) are commented examples in `config.yaml`.

## 6. Security / Infra backends

- **Kali Linux WSL (`kali-linux`)** — Raptor backend (`skills/raptor/SKILL.md`): `wsl -d kali-linux -- bash -lc ...`, `~/raptor/raptor.py scan/sca/agentic`, Semgrep 1.177 + gdb/radare2/afl++/coccinelle/z3; findings → Linear tasks; `OLLAMA_API_KEY` needed in Kali for LLM layer.
- **Tirith guardrails** (`security.tirith_enabled`, `tirith_timeout: 5`, `tirith_fail_open: true`) + `tool_loop_guardrails` + `gateway.bot_loop_guard/restart_loop_guard/respawn_storm` in `config.yaml`.
- **Browser**: `agent-browser` + Browserbase cloud, Camofox (`CAMOFOX_URL`), Lightpanda/Chrome engine (`AGENT_BROWSER_ENGINE`) in `.env.example`.

> Updated: 2026-09-16
