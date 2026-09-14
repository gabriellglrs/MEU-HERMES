---
name: personal-automation
description: "Conjunto de automações pessoais para o Hermes Agent"
version: "1.0.0"
author: "Hermes Skill"
triggers:
  - "organizar arquivos"
  - "organize files"
  - "backup"
  - "agendar tarefa"
  - "schedule task"
  - "monitorar"
  - "monitor"
  - "chamar api"
  - "call api"
  - "automatizar"
  - "automate"
---

<objective>
Conjunto integrado de automações pessoais para o Hermes Agent que permite:
- Organizar arquivos automaticamente por tipo e data, com deduplicação por hash
- Realizar backups incrementais com verificação de integridade
- Criar e gerenciar jobs de agendamento (crontab) com notificação de resultados
- Monitorar espaço em disco e processos críticos, enviando alertas
- Fazer chamadas HTTP a APIs com cache e retry automático
</objective>

<execution_context>
Este skill opera como um módulo utilitário autônomo dentro do Hermes.
Todos os scripts seguem boas-práticas de:
- Logging estruturado em /tmp/hermes-automation.log
- Idempotência em todas as operações
- Uso de variáveis de ambiente para credenciais (nunca hardcoded)
- Notificação de resultados via hermes-notify ou saída padrão
- Código defensivo com tratamento de erros e traps de limpeza
</execution_context>

<context>
O skill é acionado quando o usuário solicita uma das automações listadas em triggers.
Cada automação é encapsulada em um script independente no diretório scripts/.
O workflow.md orquestra chamadas sequenciais ou paralelas conforme a necessidade.
Os scripts são autocontidos e podem ser executados diretamente via CLI.
Todos os caminhos são relativos ao diretório do skill: SKILL_DIR.
</context>

<process>
## Fluxo Geral

1. Identificar qual automação o usuário deseja (file-organizer, backup, scheduler, monitor, api-bridge)
2. Ler as variáveis de ambiente necessárias ou usar defaults seguros
3. Executar o script correspondente com os argumentos apropriados
4. Coletar saída e status de retorno
5. Notificar o usuário sobre o resultado

## Variáveis de Ambiente Suportadas

| Variável | Descrição | Default |
|----------|-----------|---------|
| HERMES_LOG_DIR | Diretório de logs | /tmp |
| HERMES_BACKUP_SRC | Diretório fonte para backup | ~/Documents |
| HERMES_BACKUP_DST | Diretório destino para backup | ~/Backups |
| HERMES_API_CACHE_TTL | TTL do cache em segundos | 3600 |
| HERMES_MONITOR_DISK_WARN | Limite warning disco (%) | 80 |
| HERMES_MONITOR_DISK_CRIT | Limite crítico disco (%) | 90 |
| HERMES_NOTIFY_TARGET | Alvo de notificação Hermes | stdout |

## Referências

- workflow.md: Orquestração completa das automações
- scripts/: Scripts executáveis de cada automação
- templates/: Templates para notificações
</process>

## Workflow Reference

Consulte `workflow.md` para a orquestração completa das automações.
