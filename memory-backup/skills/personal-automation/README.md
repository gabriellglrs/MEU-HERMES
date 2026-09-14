# Personal Automation - Hermes Agent Skill

Conjunto de automações pessoais para o Hermes Agent. Scripts autocontidos para organização de arquivos, backup, agendamento, monitoramento e chamadas HTTP.

## Scripts

### 1. hermes-file-organizer.sh

Organiza arquivos por tipo (extensão) e data de modificação. Deduplica por hash MD5.

```bash
# Organizar Downloads em categorias
./scripts/hermes-file-organizer.sh --source ~/Downloads --target ~/Organized --dedup --verbose

# Simular sem mover
./scripts/hermes-file-organizer.sh --source ~/Downloads --target ~/Organized --dry-run
```

**Flags:** `--source`, `--target`, `--dedup`, `--dry-run`, `--verbose`, `--log`

---

### 2. hermes-backup.sh

Backup incremental com tar, verificação SHA256 e retenção configurável.

```bash
# Backup com checksum e notificação
./scripts/hermes-backup.sh --source ~/Documents --dest ~/Backups --checksum --notify

# Backup com retenção de 5 cópias
./scripts/hermes-backup.sh --source ~/Documents --dest ~/Backups --retain 5 --checksum
```

**Flags:** `--source`, `--dest`, `--name`, `--checksum`, `--notify`, `--retain`, `--dry-run`

---

### 3. hermes-scheduler.sh

Gerencia jobs crontab com identificação Hermes e notificação.

```bash
# Listar jobs Hermes
./scripts/hermes-scheduler.sh --list

# Criar job de backup diário
./scripts/hermes-scheduler.sh --name "daily-backup" --schedule "0 2 * * *" \
  --command "/path/to/hermes-backup.sh --source ~/Documents --dest ~/Backups --checksum"

# Remover job
./scripts/hermes-scheduler.sh --name "daily-backup" --remove
```

**Flags:** `--name`, `--schedule`, `--command`, `--notify`, `--remove`, `--list`

---

### 4. hermes-monitor.sh

Monitora disco, memória e processos críticos com alertas configuráveis.

```bash
# Verificação completa com alertas
./scripts/hermes-monitor.sh --disk-warn 80 --disk-crit 90 --processes "node,python" --notify

# Check único
./scripts/hermes-monitor.sh --check-once --verbose
```

**Flags:** `--disk-warn`, `--disk-crit`, `--processes`, `--notify`, `--check-once`

---

### 5. hermes-api-bridge.py

Chamadas HTTP com cache por URL, retry exponencial e formatação de saída.

```bash
# GET com cache
python3 scripts/hermes-api-bridge.py --url https://api.github.com/users/octocat

# POST com headers customizados
python3 scripts/hermes-api-bridge.py --url https://httpbin.org/post \
  --method POST --data '{"key":"value"}' --header "Authorization: Bearer TOKEN"

# Saída em tabela, sem cache
python3 scripts/hermes-api-bridge.py --url https://api.example.com/data \
  --output table --no-cache --retries 5
```

**Flags:** `--url`, `--method`, `--header`, `--data`, `--cache-ttl`, `--no-cache`, `--retries`, `--output`

---

## Variáveis de Ambiente

| Variável | Descrição | Default |
|----------|-----------|---------|
| `HERMES_LOG_DIR` | Diretório de logs | `/tmp` |
| `HERMES_BACKUP_SRC` | Fonte para backup | `~/Documents` |
| `HERMES_BACKUP_DST` | Destino para backup | `~/Backups` |
| `HERMES_API_CACHE_TTL` | TTL cache (segundos) | `3600` |
| `HERMES_MONITOR_DISK_WARN` | Warning disco (%) | `80` |
| `HERMES_MONITOR_DISK_CRIT` | Crítico disco (%) | `90` |
| `HERMES_NOTIFY_TARGET` | Alvo notificação Hermes | stdout |

## Boas-Práticas

- **Logging:** Todos os logs em `$HERMES_LOG_DIR/hermes-automation.log`
- **Idempotência:** Reexecução segura em todos os scripts
- **Credenciais:** Variáveis de ambiente, nunca hardcoded
- **Notificação:** Integração com `hermes-notify` quando disponível
- **Erros:** Exit codes padronizados (0=ok, 1=erro)

## Estrutura

```
personal-automation/
├── SKILL.md              # Definição do skill
├── workflow.md           # Orquestração das automações
├── README.md             # Este arquivo
├── scripts/
│   ├── hermes-file-organizer.sh
│   ├── hermes-backup.sh
│   ├── hermes-scheduler.sh
│   ├── hermes-monitor.sh
│   └── hermes-api-bridge.py
└── templates/
    └── notification.md   # Template de notificação
```
