---
name: time-de-dev-ia
description: "Use when managing dev tasks with Hermes + Linear + executor: create tasks, ask Orca-vs-opencode, dispatch agent, review PRs, merge."
category: software-development
---

# Time de Dev com IA (Hermes + Linear + Orca)

> **Brinde da aula.** Coloque este arquivo em:
> `~/AppData/Local/hermes/skills/time-de-dev-ia/SKILL.md`

## Os 3 papéis

- **Você** = o dono. Dá o pedido e aprova.
- **Hermes** = o gerente. Entende o pedido, divide em tarefas, revisa.
- **Linear** = o mural. Tarefas com status, prioridade e dono.
- **Executor** = o braço (ESCOLHA abaixo). Cada tarefa vira um dev de IA
  isolado que coda e abre PR.

## Escolha do executor (PERGUNTAR SEMPRE)

Toda tarefa nova: pergunte ao dono **"Orca ou opencode?"** antes de
disparar. Nunca assuma um padrão silencioso.

| Executor | Quando | Como disparar |
|---|---|---|
| **Orca** (app desktop) | Prefere acompanhar visualmente; worktrees gerenciados | Se houver CLI (`orca worktree create ...`), use-o. Senão, entregue o prompt de 5 blocos pronto + spec do worktree (repo, branch base, nome) pro dono colar no app |
| **opencode** (CLI) | Automação total via terminal | `opencode run '<prompt 5 blocos>'` no workdir do repo (ver skill `opencode`); `-f` pra anexar arquivos, `--thinking` pra debug |

Se o CLI do Orca não existir no PATH, informe e siga de opencode.

## Quando usar

- Pedido de feature, correção ou página nova chega → GSD phase loop abaixo → registrar tarefa no Linear → disparar agente no Orca → revisar PR → mergear.
- Nunca codar direto no main. Nunca pular o mural. Nunca pular o Verify.
- Trabalho abaixo do threshold do loop (typo, fix trivial) → `/gsd-quick` em vez do loop cheio.

## Fluxo GSD (phase loop — OBRIGATÓRIO em feature/fix de tamanho real)

Ritmo oficial do GSD Core (Discuss → Plan → Execute → Verify → Ship).
Cada fase mora em `.planning/phases/` e o estado global em `.planning/STATE.md`.
Leia `STATE.md` primeiro em toda sessão.

| Passo | Comando | Produz | Regra |
|---|---|---|---|
| 0. Onboard (1ª vez no repo) | `/gsd-onboard` | `.planning/PROJECT.md`, `ROADMAP.md`, `STATE.md`, `.planning/codebase/` | Greenfield usa `/gsd-new-project` |
| 1. Discuss | `/gsd-discuss-phase N` | `{fase}-CONTEXT.md` | Captura decisões ANTES de planejar; sem chute do planner |
| 2. Plan | `/gsd-plan-phase N` | `{fase}-RESEARCH.md`, `{fase}-PLAN.md`, `{fase}-VALIDATION.md` | Plan-checker valida; split se `estimate.tokens` > `workflow.smart_zone_tokens` |
| 3. Execute | `/gsd-execute-phase N` | `{fase}-SUMMARY.md`, commits atômicos | Waves paralelas, 1 executor = 1 contexto limpo 200k; 1 plano = 1 issue Linear (ver mapeamento) |
| 4. Verify | `/gsd-verify-work N` | `{fase}-UAT.md`, fix plans | Fase só é done com requirement + decision coverage; `backstop` sem evidência = `human_needed`, nunca `passed` silencioso |
| 5. Ship | `/gsd-ship N` | PR rico + `STATE.md` atualizado | Gates: `SECURITY.md threats_open=0`, checks verdes; depois arquiva fase |

Comandos de navegação: `/gsd-next` (roteador state-aware), `/gsd-progress` (status + avanço), `/gsd-phase` (CRUD de fases no ROADMAP), `/gsd-code-review` (gate de qualidade), `/gsd-quick` (abaixo do threshold).

## Onde o GSD mora (REGRA DURA — sem exceção)

- **`.planning/` mora na RAIZ do projeto (repo git), nunca no Hermes home, nunca solto.**
  Ex: `C:\DEV\MEU-HERMES\.planning\` (STATE.md, ROADMAP.md, PROJECT.md, config.json, phases/, codebase/).
- **Todo comando GSD roda com cwd = raiz do projeto.** Hermes, opencode e `gsd-tools` sempre com workdir no repo. Sem cwd certo, nada executa.
- **Gate de entrada:** se `.planning/STATE.md` não existe → PARAR e rodar `/gsd-onboard` (repo com código) ou `/gsd-new-project` (greenfield) primeiro. Sem STATE, não há fase, não há plano, não há Linear.
- **`.planning/` é trackeado no git** (`commit_docs: true` default). `config.json`, `codebase/`, fases e STATE sempre commitados — é assim que o worktree Orca enxerga o planejamento (worktree herda arquivos trackeados do git).
- **Orca worktree ≠ projeto.** O worktree (`~/orca/workspaces/<repo>/<nome>`) é checkout isolado para executar; o planejamento continua morando no repo principal. Executor roda com workdir = path do worktree e lê o plano que o Hermes entregou no prompt.

## Mapeamento GSD ↔ Linear ↔ Orca (sempre juntos)

- **1 plano GSD = 1 issue Linear.** Hermes cria a issue a partir do `PLAN.md` (título = `[Fase N][Plano M] nome do plano`, descrição com goal + acceptance criteria + link da fase). Guarda o `tracker-id` (ex. `GAB-19`) no plano. Sem fase/plano, sem issue.
- **1 issue Linear = 1 worktree Orca.** `orca worktree create --repo name:<repo> --name <slug> --base-branch main --linear-issue GAB-XX --comment "<fase/plano>"` — branch `gabriellglrs/<slug>`, como validado no teste E2E (GAB-19 → `teste-fluxo-e2e`).
- **Executor roda DENTRO do worktree.** `opencode run '<prompt 5 blocos>'` com `workdir` = path do worktree (OpenCode via Zen já configurado; Ollama local não instalado — Orca não tem `account add ollama`, Ollama entra via OpenCode).
- **Completion flow (sempre via Orca CLI):** `orca linear attach GAB-XX --url <PR> --title "PR/MR link"` → `orca linear comment add GAB-XX --body-file -` (2-4 frases + link) → `orca linear status set GAB-XX --to "In Review"`. Só move de `triage/backlog/unstarted`; nunca regride `started/completed/canceled`.
- **GSD config do projeto** mora em `.planning/config.json` (NÃO no `config.yaml` do Hermes): `response_language: "pt"`, `workflow.use_worktrees: true`, `workflow.verifier: true`, `workflow.code_review: true`. Ver `docs/CONFIGURATION.md` do gsd-core.

## Fluxo padrão (resumo executável)

1. **Tarefa no Linear** (via MCP do Linear no Hermes): título claro, descrição com o pedido, prioridade.
2. **Perguntar o executor** (Orca ou opencode — ver seção acima) e **disparar**:
   - Orca CLI: `orca worktree create --repo name:seu-repo --name nome-da-task --base-branch main --agent claude --prompt "..." --activate`
   - opencode: `opencode run '<prompt>'` no repo (background + `process poll/log` se longo)
3. **Acompanhar**: Orca → `orca worktree list`; opencode → logs da sessão; ambos → `git log --oneline -3` no worktree (commit presente = trabalhou).
4. **Revisar o PR**: `gh pr view <n>` e `gh pr diff <n>` — conferir se os arquivos batem com a fronteira do prompt.
5. **Checks verdes**: `gh pr checks <n> --watch` — teste e lint obrigatórios.
6. **Merge**: `gh pr merge <n> --squash --delete-branch`.
7. **Fechar a tarefa no Linear**.

## O prompt do agente (5 blocos)

1. **TAREFA** numerada e específica (arquivos exatos quando possível)
2. **CONTEXTO** (o que já existe, padrões do repo)
3. **FRONTEIRAS** — "NAO toque em X (outra tarefa cuida)" — isso permite paralelizar
4. **REGRAS** — leia AGENTS.md; testes verdes; nunca segredos; não faça deploy
5. **ENTREGA** — branch própria + `gh pr create` base main + "NAO mergeie" + relatório final

## Regras de ouro

- **Paralelismo = dividir por DONO DE ARQUIVO.** Nunca 2 agentes ativos no mesmo arquivo.
- **Deploy de produção é do DONO.** Agente e gestor nunca deployam sem o OK.
- **Segredos nunca** em prompt, commit ou env.
- **Revisar antes de mergear.** Não confiar só no título do PR.
- **Nada entra quebrado.** CI vermelho = não mergeia.

## Comandos rápidos

| Ação | Comando |
|---|---|
| Listar worktrees (Orca) | `orca worktree list` |
| Criar agente (Orca) | `orca worktree create --repo name:... --name ... --base-branch main --agent claude --prompt "..." --activate` |
| Criar agente (opencode) | `opencode run '<prompt>'` (+ `-f arquivo`, `--thinking`) |
| PR aberto do agente | `gh pr list --head <branch>` |
| Diff do PR | `gh pr diff <n>` |
| Checks | `gh pr checks <n> --watch` |
| Merge | `gh pr merge <n> --squash --delete-branch` |
