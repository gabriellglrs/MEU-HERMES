#!/usr/bin/env bash
# =============================================================================
# hermes-scheduler.sh
# Wrapper para gerenciar jobs crontab com notificação de resultados.
# =============================================================================
set -euo pipefail

# --- Configuração ---
LOG_FILE="${HERMES_LOG_DIR:-/tmp}/hermes-automation.log"
JOB_NAME=""
SCHEDULE=""
COMMAND=""
NOTIFY=false
REMOVE=false
LIST_ONLY=false
VERBOSE=false

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Funções ---
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [scheduler] $1"
  echo -e "$msg" >> "$LOG_FILE"
  [[ "$VERBOSE" == true ]] && echo -e "${GREEN}$msg${NC}"
}

warn() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [scheduler] WARN: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${YELLOW}$msg${NC}" >&2
}

err() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [scheduler] ERROR: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${RED}$msg${NC}" >&2
}

usage() {
  cat <<EOF
Uso: $(basename "$0") [OPÇÕES]

Gerencia jobs crontab com notificação de resultados.

OPÇÕES:
  --name NAME        Nome do job (obrigatório para add/remove)
  --schedule CRON    Expressão cron (obrigatório para add)
  --command CMD      Comando a executar (obrigatório para add)
  --notify           Notificar execução via Hermes
  --remove           Remover job existente
  --list             Listar jobs ativos
  --verbose          Saída detalhada
  -h, --help         Mostrar esta ajuda

EXEMPLOS:
  $(basename "$0") --list
  $(basename "$0") --name "daily-backup" --schedule "0 2 * * *" --command "/path/to/backup.sh"
  $(basename "$0") --name "daily-backup" --remove

VARIÁVEIS DE AMBIENTE:
  HERMES_LOG_DIR   Diretório de logs (default: /tmp)

EXIT CODES:
  0  Sucesso
  1  Erro de argumentos ou execução
EOF
  exit 0
}

# --- Parse argumentos ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)      JOB_NAME="$2"; shift 2 ;;
    --schedule)  SCHEDULE="$2"; shift 2 ;;
    --command)   COMMAND="$2"; shift 2 ;;
    --notify)    NOTIFY=true; shift ;;
    --remove)    REMOVE=true; shift ;;
    --list)      LIST_ONLY=true; shift ;;
    --verbose)   VERBOSE=true; shift ;;
    -h|--help)   usage ;;
    *)           err "Argumento desconhecido: $1"; exit 1 ;;
  esac
done

# --- Listar jobs ---
if [[ "$LIST_ONLY" == true ]]; then
  echo "=== Jobs Hermes no Crontab ==="
  crontab -l 2>/dev/null | grep -E "^# \[hermes\]" || echo "(nenhum job Hermes encontrado)"
  exit 0
fi

# --- Validar argumentos ---
if [[ "$REMOVE" == false ]]; then
  if [[ -z "$JOB_NAME" || -z "$SCHEDULE" || -z "$COMMAND" ]]; then
    err "Para adicionar job: --name, --schedule e --command são obrigatórios."
    usage
  fi
else
  if [[ -z "$JOB_NAME" ]]; then
    err "Para remover job: --name é obrigatório."
    usage
  fi
fi

# --- Funções de crontab ---
get_crontab() {
  crontab -l 2>/dev/null || echo ""
}

add_job() {
  local current_cron
  current_cron=$(get_crontab)

  # Verificar se job já existe
  if echo "$current_cron" | grep -q "# \[hermes\] ${JOB_NAME}$"; then
    warn "Job '${JOB_NAME}' já existe. Atualizando..."
    current_cron=$(echo "$current_cron" | grep -v "# \[hermes\] ${JOB_NAME}$")
  fi

  # Preparar comando com logging
  local log_cmd="$COMMAND"
  if [[ "$NOTIFY" == true ]]; then
    log_cmd="${COMMAND} 2>&1 | while read line; do echo \"[\$(date)] [${JOB_NAME}] \$line\" >> \"${LOG_FILE}\"; done"
  fi

  # Adicionar novo job
  local new_cron="${current_cron}
# [hermes] ${JOB_NAME}
${SCHEDULE} ${log_cmd}"

  echo "$new_cron" | crontab -
  log "Job '${JOB_NAME}' adicionado: ${SCHEDULE} -> ${COMMAND}"
  echo -e "${GREEN}✅ Job '${JOB_NAME}' adicionado com sucesso.${NC}"
  echo -e "   Agendamento: ${SCHEDULE}"
  echo -e "   Comando: ${COMMAND}"
}

remove_job() {
  local current_cron
  current_cron=$(get_crontab)

  if ! echo "$current_cron" | grep -q "# \[hermes\] ${JOB_NAME}$"; then
    warn "Job '${JOB_NAME}' não encontrado no crontab."
    exit 1
  fi

  # Remover job e sua linha de comentário
  local new_cron
  new_cron=$(echo "$current_cron" | sed "/# \[hermes\] ${JOB_NAME}$/,/^$/d" | sed '/^$/d')

  if [[ -z "$new_cron" ]]; then
    crontab -r 2>/dev/null || true
  else
    echo "$new_cron" | crontab -
  fi

  log "Job '${JOB_NAME}' removido"
  echo -e "${GREEN}✅ Job '${JOB_NAME}' removido com sucesso.${NC}"
}

# --- Executar ---
if [[ "$REMOVE" == true ]]; then
  remove_job
else
  add_job
fi

exit 0
