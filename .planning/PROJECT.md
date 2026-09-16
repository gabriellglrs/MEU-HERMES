# MEU-HERMES — Project Context

Backup versionado das configurações do Hermes Agent (Windows) + skill de
orquestração do time de dev com IA (Hermes → Linear → Orca/OpenCode → PR).

## What This Is

- **Backup fiel** de `%LOCALAPPDATA%\hermes`: `config.yaml`, `SOUL.md`,
  `honcho.json`, `rtk-config.toml`, skills, plugins, scripts, cron-jobs.
  Restauração documentada em `README.md` (Windows PowerShell + Linux `install.sh`).
- **Orquestração dev**: skill `time-de-dev-ia` ensina o Hermes a gerenciar o
  fluxo pedido → issue Linear → worktree Orca → execução OpenCode → PR →
  review → merge → fechar issue, agora sob o phase loop do GSD Core
  (Discuss → Plan → Execute → Verify → Ship).
- **Prova operacional**: GAB-18/19/20, PRs #1 (MEU-HERMES, snake-gsd),
  worktrees linkados, testes 9/9 no snake-gsd.

## Requirements

### Validated

- ✓ Backup/restauração das configs do Hermes — existing (`install.sh`, `backup-memory.sh`, `restore-memory.sh`)
- ✓ MCPs Linear + 21st.dev registrados e habilitados — existing (`config.yaml`, `hermes mcp list`)
- ✓ Skill `time-de-dev-ia` com executor Orca-ou-opencode + prompt 5 blocos — existing
- ✓ Integração Orca ↔ Linear via CLI (attach/comment/status) — existing (validado GAB-19/20)
- ✓ `.planning/` na raiz do projeto com `config.json` + `codebase/` (7 docs) — existing
- ✓ Regras GSD na skill/SOUL (loop via CLI/skills, `.planning` na raiz, gate de STATE) — existing

### Active

- [ ] ROADMAP.md + STATE.md (destravar phase loop — este new-project)
- [ ] Fechar loops E2E abertos (review/merge PRs #1, GAB-19/20 → Done)
- [ ] Executor reserva (conta Claude/Codex no Orca ou Ollama local; hoje só OpenCode/Zen)
- [ ] 1 fase GSD real executada via `/gsd-*` de ponta a ponta

### Out of Scope

- Deploy em produção pelo agente — sempre decisão do dono
- Merge de PR sem review humano — proibido pela skill
- Terceiros/escopos não autorizados no Raptor — só repos próprios

## Key Decisions

| Decision | Rationale | Outcome |
|---|---|---|
| Projeto = Backup + orquestração | É o que o repo já é; visão confirmada pelo dono em 2026-09-16 | ✓ Decided |
| Executor padrão: OpenCode (Zen) em worktree Orca | Accounts Claude/Codex vazios; Ollama local ausente; E2E validado assim | ✓ Decided |
| Perguntar "Orca ou opencode?" sempre | Regra da skill; nunca assumir padrão silencioso | ✓ Decided |
| GSD via CLI/skills, zona manual só p/ Linear+PR | Loop hand-rolled não é GSD (achado do teste E2E) | ✓ Decided |
| Respostas em pt-BR | `response_language: pt` em `.planning/config.json` | ✓ Decided |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-09-16 after initialization*
