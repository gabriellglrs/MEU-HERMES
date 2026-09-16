# MEU-HERMES — Roadmap v1

## Milestone v1.0 — Fluxo operacional de verdade

### Phase 1: Fechar os loops E2E
**Goal:** Nenhum PR ou issue de validação em aberto; worktrees órfãos limpos.
**Success Criteria:**
1. PR #1 do snake-gsd revisado e mergeado (ou fechado com motivo) pelo dono
2. GAB-19 e GAB-20 em `Done` no Linear com PR anexado
3. Worktree órfão `snake-game` removido ou religado; `C:\DEV\snake-gsd` íntegro
4. `git status` do MEU-HERMES sem deleções pendentes de `skills-hermes/` (resolver: restaurar ou assumir)

### Phase 2: GSD de verdade no repo
**Goal:** Phase loop executável via comandos próprios, backup fiel ao ambiente.
**Success Criteria:**
1. `install.sh`/README restauram o setup a partir deste repo sem passo manual faltando
2. Skill, SOUL e `config.yaml` do backup idênticos ao ambiente ativo
3. `gsd-tools smart-entry` e `progress` respondem a partir de qualquer fase

### Phase 3: Resiliência
**Goal:** Sem ponto único de falha no executor e no Hermes.
**Success Criteria:**
1. Executor reserva funcional (Claude/Codex logado no Orca ou Ollama local respondendo via OpenCode)
2. `hermes doctor` sem warnings (gateway + config version)
3. 1 fase GSD real executada de ponta a ponta via `/gsd-*` (discuss → ship)
