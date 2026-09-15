# MEU-HERMES — Backup das configs do Hermes

Backup fiel de `%LOCALAPPDATA%\hermes` (Windows) + skill Raptor (backend Kali).
Restauração: copiar os arquivos de volta ou rodar `install.sh` (Linux).

---

## Status (2026-09-15, 2º turno)

| Item | Status | Notas |
|---|---|---|
| Hermes | ✅ v0.21.3 | Windows, `%LOCALAPPDATA%\hermes` |
| Modelo | ✅ nemotron-3-ultra | ollama-cloud, `OLLAMA_API_KEY` válida |
| Linear MCP | ⚠️ registrado | Falta `LINEAR_API_KEY` no `.env` + `hermes mcp add linear` |
| 21st.dev MCP | ⚠️ registrado | Falta `TWENTYFIRST_API_KEY` (criar em 21st.dev/mcp) |
| Skills dev | ✅ | `time-de-dev-ia`, `opencode`, `github`, `gsd-core`... |
| Skill `raptor` | ✅ | Auditoria via Kali (ver fluxo segurança) |
| Skills UI/UX | ✅ | `ui-ux-pro-max` + 6 (Step 0 obrigatório: 21st.dev) |
| RTK 0.48.0 | ✅ | Hook `rtk-rewrite` ativo no Hermes |
| Honcho memória | ✅ | Conectado, 8 fatos no peer card |
| GitHub CLI 2.101 | ⚠️ | Instalado mas **deslogado** → `gh auth login` |
| Raptor 3.1.0 (Kali) | ✅ | `~/raptor` + semgrep 1.177 (venv `~/raptor-tools`), gdb, radare2, afl++, coccinelle, z3 |
| Orca | ⬜ opcional | App desktop à parte (onorca.dev/download) |
| `hermes setup` | ⬜ pendente | Wizard interativo (provider/modelo) |

---

## Arquivos

| Arquivo | Descrição |
|---|---|
| `config.yaml` | Config ativa (MCPs linear + 21st, plugins, honcho, modelo) |
| `SOUL.md` | Personalidade + regras (RTK, 21st Step 0, Raptor, integrações) |
| `honcho.json` | Peer + workspace da memória |
| `rtk-config.toml` | Config do RTK |
| `.env.example` | Modelo do `.env` (**sem segredos** — valores redigidos) |
| `skills/` | Todas as skills (`raptor`, `ui-ux-pro-max/*`, `time-de-dev-ia`...) |
| `plugins/` | Plugins (`opencode`, `rtk-rewrite`) |
| `scripts/` | Automação (backup, briefing, monitor...) |
| `cron-jobs/` | `hermes-crontab` |
| `install.sh` | Instalação Linux (`$HOME/.hermes`) |
| `SKILL-TIME-DEV-IA.md` | Fonte da skill time-de-dev-ia |
| `INSTALACAO-E-CONFIGURACAO.md` | Guia original de instalação |
| `AUDITORIA-E-PLANEJAMENTO.md` | Planejamento e auditoria |

> **Segredos:** `.env` real NUNCA entra no git. Preencha a partir do
> `.env.example`: `OLLAMA_API_KEY`, `LINEAR_API_KEY`,
> `TWENTYFIRST_API_KEY` (+ `gh auth login`).

---

## Restauração

**Windows** (PowerShell):
```powershell
$H="$env:LOCALAPPDATA\hermes"
Copy-Item config.yaml,SOUL.md,honcho.json,rtk-config.toml $H -Force
Copy-Item skills\* "$H\skills\" -Recurse -Force
Copy-Item plugins\* "$H\plugins\" -Recurse -Force
Copy-Item scripts\* "$H\scripts\" -Recurse -Force
Copy-Item cron-jobs\* "$H\cron-jobs\" -Recurse -Force
Copy-Item .env.example "$H\.env"  # depois preencha as chaves!
hermes setup
```

**Linux:** `cd MEU-HERMES && bash install.sh`
(+ copiar `SKILL-TIME-DEV-IA.md` e `TWENTYFIRST_API_KEY` manualmente —
ver `skills/raptor/SKILL.md` pro setup do Raptor no Kali).

---

## Fluxos

**Dev:** Você → Hermes → Linear → Orca/opencode → PR → review → merge
(ver `SKILL-TIME-DEV-IA.md`)

**Segurança:** Hermes (skill `raptor`) → scan no Kali
(`~/raptor`, venv `~/raptor-tools`) → achados → tarefas no Linear →
fix → `gh pr` (ver `skills/raptor/SKILL.md`; só alvos autorizados)

**UI/UX:** skill `ui-ux-pro-max` → **Step 0: 21st.dev** (MCP `search` ou
web, 2–3 referências citadas) → design system local → implementar

---

## Links

- [Hermes Agent](https://hermes-agent.nousresearch.com)
- [Linear](https://linear.app)
- [21st.dev](https://21st.dev) · [MCP](https://21st.dev/mcp)
- [Raptor](https://github.com/gadievron/raptor)
- [UI-UX-Pro-Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)

---

*Backup atualizado em: 2026-09-15*
