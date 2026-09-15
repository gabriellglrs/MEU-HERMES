---
name: time-de-dev-ia
description: "Use when managing dev tasks with Hermes + Linear + Orca: create tasks, dispatch agents, review PRs, merge."
category: software-development
---

# Time de Dev com IA (Hermes + Linear + Orca)

> **Brinde da aula.** Coloque este arquivo em:
> `~/AppData/Local/hermes/skills/time-de-dev-ia/SKILL.md`

## Os 3 papéis

- **Você** = o dono. Dá o pedido e aprova.
- **Hermes** = o gerente. Entende o pedido, divide em tarefas, revisa.
- **Linear** = o mural. Tarefas com status, prioridade e dono.
- **Orca** = o braço. Cada tarefa vira um dev de IA isolado que coda e abre PR.

## Quando usar

- Pedido de feature, correção ou página nova chega → registrar tarefa no Linear → disparar agente no Orca → revisar PR → mergear.
- Nunca codar direto no main. Nunca pular o mural.

## Fluxo padrão

1. **Tarefa no Linear** (via MCP do Linear no Hermes): título claro, descrição com o pedido, prioridade.
2. **Disparar o agente** (via Orca CLI):
   ```bash
   orca worktree create --repo name:seu-repo --name nome-da-task --base-branch main --agent claude --prompt "..." --activate
   ```
3. **Acompanhar**: `orca worktree list` e `git log --oneline -3` no worktree (commit presente = trabalhou).
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
| Listar worktrees | `orca worktree list` |
| Criar agente | `orca worktree create --repo name:... --name ... --base-branch main --agent claude --prompt "..." --activate` |
| PR aberto do agente | `gh pr list --head <branch>` |
| Diff do PR | `gh pr diff <n>` |
| Checks | `gh pr checks <n> --watch` |
| Merge | `gh pr merge <n> --squash --delete-branch` |
