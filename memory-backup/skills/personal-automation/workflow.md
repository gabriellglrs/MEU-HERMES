# Workflow: Personal Automation

## Visão Geral

Orquestra as automações pessoais do Hermes Agent. Cada etapa pode ser executada de forma independente ou encadeada conforme necessário.

## Etapas

### 1. Organização de Arquivos (`hermes-file-organizer`)

**Quando executar:** Quando o usuário deseja limpar ou organizar um diretório.

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0")")"
bash "$SKILL_DIR/scripts/hermes-file-organizer.sh" \
  --source ~/Downloads \
  --target ~/Organized \
  --dedup \
  --log
```

**Flags disponíveis:**
- `--source DIR` — Diretório de origem (obrigatório)
- `--target DIR` — Diretório de destino (obrigatório)
- `--dedup` — Ativar deduplicação por hash MD5
- `--log` — Ativar logging em arquivo
- `--dry-run` — Simular sem mover arquivos

**Saída esperada:** Relatório de arquivos movidos e duplicatas removidas.

---

### 2. Backup Incremental (`hermes-backup`)

**Quando executar:** Quando o usuário deseja criar ou atualizar backup.

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0")")"
bash "$SKILL_DIR/scripts/hermes-backup.sh" \
  --source "${HERMES_BACKUP_SRC:-~/Documents}" \
  --dest "${HERMES_BACKUP_DST:-~/Backups}" \
  --name "backup-$(date +%Y%m%d)" \
  --checksum \
  --notify
```

**Flags disponíveis:**
- `--source DIR` — Diretório fonte (default: ~/Documents)
- `--dest DIR` — Diretório destino (default: ~/Backups)
- `--name NAME` — Nome do archive de backup
- `--checksum` — Gerar checksum SHA256 do backup
- `--notify` — Notificar resultado via Hermes
- `--retain N` — Manter apenas N backups anteriores

**Saída esperada:** Archive .tar.gz + checksum + notificação.

---

### 3. Agendamento de Tarefas (`hermes-scheduler`)

**Quando executar:** Quando o usuário deseja criar um job recorrente.

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0")")"
bash "$SKILL_DIR/scripts/hermes-scheduler.sh" \
  --name "daily-backup" \
  --schedule "0 2 * * *" \
  --command "bash $SKILL_DIR/scripts/hermes-backup.sh --source ~/Documents --dest ~/Backups" \
  --notify
```

**Flags disponíveis:**
- `--name NAME` — Nome do job (obrigatório)
- `--schedule CRON` — Expressão cron (obrigatório)
- `--command CMD` — Comando a executar (obrigatório)
- `--notify` — Notificar execução via Hermes
- `--remove` — Remover job existente
- `--list` — Listar jobs ativos

**Saída esperada:** Job adicionado ao crontab + confirmação.

---

### 4. Monitoramento (`hermes-monitor`)

**Quando executar:** Quando o usuário deseja verificar saúde do sistema.

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0")")"
bash "$SKILL_DIR/scripts/hermes-monitor.sh" \
  --disk-warn "${HERMES_MONITOR_DISK_WARN:-80}" \
  --disk-crit "${HERMES_MONITOR_DISK_CRIT:-90}" \
  --processes "node,python,nginx" \
  --notify
```

**Flags disponíveis:**
- `--disk-warn N` — Limite warning disco em % (default: 80)
- `--disk-crit N` — Limite crítico disco em % (default: 90)
- `--processes LIST` — Lista de processos para monitorar (separado por vírgula)
- `--notify` — Enviar alertas via Hermes
- `--check-once` — Executar verificação única e sair

**Saída esperada:** Status do disco + processos + alertas se necessário.

---

### 5. Bridge de API (`hermes-api-bridge`)

**Quando executar:** Quando o usuário deseja fazer chamadas HTTP com cache.

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0")")"
python3 "$SKILL_DIR/scripts/hermes-api-bridge.py" \
  --url "https://api.example.com/data" \
  --method GET \
  --cache-ttl "${HERMES_API_CACHE_TTL:-3600}" \
  --retries 3 \
  --output json
```

**Flags disponíveis:**
- `--url URL` — URL da API (obrigatório)
- `--method METHOD` — Método HTTP (default: GET)
- `--headers KEY:VALUE` — Headers HTTP (repetível)
- `--data BODY` — Corpo da requisição (POST/PUT)
- `--cache-ttl N` — TTL do cache em segundos
- `--retries N` — Número de tentativas (default: 3)
- `--output FORMAT` — Formato de saída: json, text, table

**Saída esperada:** Resposta da API formatada + status de cache.

---

## Orquestração Completa

Para executar todas as automações em sequência:

```bash
SKILL_DIR="$(dirname "$(readlink -f "$0")")"

echo "=== Etapa 1: Organizar arquivos ==="
bash "$SKILL_DIR/scripts/hermes-file-organizer.sh" \
  --source ~/Downloads --target ~/Organized --dedup --log

echo "=== Etapa 2: Backup ==="
bash "$SKILL_DIR/scripts/hermes-backup.sh" \
  --source ~/Documents --dest ~/Backups --name "backup-$(date +%Y%m%d)" --checksum --notify

echo "=== Etapa 3: Monitorar ==="
bash "$SKILL_DIR/scripts/hermes-monitor.sh" \
  --disk-warn 80 --disk-crit 90 --notify

echo "=== Concluído ==="
```

## Boas-Práticas

- **Logging:** Todos os scripts escrevem logs em `$HERMES_LOG_DIR/hermes-automation.log`
- **Idempotência:** Reexecutar qualquer script não causa efeitos colaterais
- **Credenciais:** Nunca hardcoded; usar variáveis de ambiente
- **Notificação:** Usar `hermes-notify` ou saída padrão para feedback ao usuário
- **Erros:** Todos os scripts retornam exit code 0 (sucesso) ou 1 (erro)
