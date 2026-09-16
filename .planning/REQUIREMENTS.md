# MEU-HERMES — v1 Requirements

## v1 Requirements

### Orquestração

- [ ] **ORC-01**: Dono consegue pedir feature e Hermes cria issue `[Fase N][Plano M]` no Linear com goal + acceptance criteria
- [ ] **ORC-02**: Cada plano vira 1 worktree Orca linkado (`--linear-issue`) com branch própria
- [ ] **ORC-03**: Executor OpenCode roda dentro do worktree a partir do plano e entrega código + testes verdes
- [ ] **ORC-04**: PR aberto a partir do worktree com corpo rico (fase, planos, verificação)
- [ ] **ORC-05**: Completion flow fecha o loop (attach PR, comentário, `In Review` → `Done` pós-merge)

### GSD

- [ ] **GSD-01**: Phase loop roda via comandos próprios (`gsd-tools --cwd`, skills `/gsd-*`) — nunca hand-rolled
- [ ] **GSD-02**: `.planning/` (STATE, ROADMAP, phases, codebase) commitado e herdado pelos worktrees via git
- [ ] **GSD-03**: Verify antes de Ship em toda fase (UAT + requirement coverage; backstop sem evidência = `human_needed`)

### Backup

- [ ] **BAK-01**: `install.sh` restaura setup completo no Linux a partir deste repo
- [ ] **BAK-02**: Skill, SOUL e `config.yaml` do backup refletem o ambiente ativo (`%LOCALAPPDATA%\hermes`)

### Resiliência

- [ ] **RES-01**: Executor reserva disponível (conta Claude/Codex no Orca ou Ollama local)
- [ ] **RES-02**: Gateway Hermes sem warnings pendentes (`hermes doctor` limpo)

## v2 Requirements

- Dashboard/observabilidade do fluxo (STATE → Linear → PR em uma visão)
- Automação do completion flow (ship dispara attach/comment/status sozinho)

## Out of Scope

- Deploy em produção pelo agente — decisão sempre do dono
- Merge sem review humano
- Auditoria de terceiros no Raptor

## Traceability

| REQ-ID | Phase |
|---|---|
| ORC-01 – ORC-05 | Phase 1 (já provados no E2E; falta fechar os loops) |
| GSD-01 – GSD-03 | Phase 2 |
| BAK-01 – BAK-02 | Phase 2 |
| RES-01 – RES-02 | Phase 3 |
