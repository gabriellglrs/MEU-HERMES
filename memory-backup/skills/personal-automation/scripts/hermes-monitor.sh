#!/usr/bin/env bash
# =============================================================================
# hermes-monitor.sh
# Monitora espaço em disco e processos críticos, envia alertas.
# =============================================================================
set -euo pipefail

# --- Configuração ---
LOG_FILE="${HERMES_LOG_DIR:-/tmp}/hermes-automation.log"
DISK_WARN=80
DISK_CRIT=90
PROCESS_LIST=""
NOTIFY=false
CHECK_ONCE=false
VERBOSE=false

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Funções ---
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [monitor] $1"
  echo -e "$msg" >> "$LOG_FILE"
  [[ "$VERBOSE" == true ]] && echo -e "${GREEN}$msg${NC}"
}

warn() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [monitor] WARN: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${YELLOW}$msg${NC}" >&2
}

err() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [monitor] ERROR: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${RED}$msg${NC}" >&2
}

alert() {
  local level="$1"
  local message="$2"
  local icon="⚠️"
  [[ "$level" == "CRIT" ]] && icon="🔴"
  [[ "$level" == "OK" ]] && icon="✅"

  local alert_msg="${icon} [${level}] ${message}"
  echo -e "$alert_msg"

  if [[ "$NOTIFY" == true ]]; then
    if [[ -n "${HERMES_NOTIFY_TARGET:-}" ]]; then
      echo "$alert_msg" | hermes-notify --target "$HERMES_NOTIFY_TARGET" 2>/dev/null || \
        echo "$alert_msg"
    fi
  fi

  log "$alert_msg"
}

usage() {
  cat <<EOF
Uso: $(basename "$0") [OPÇÕES]

Monitora disco e processos, envia alertas.

OPÇÕES:
  --disk-warn N      Limite warning disco em % (default: 80)
  --disk-crit N      Limite crítico disco em % (default: 90)
  --processes LIST   Processos para monitorar (separado por vírgula)
  --notify           Enviar alertas via Hermes
  --check-once       Executar verificação única e sair
  --verbose          Saída detalhada
  -h, --help         Mostrar esta ajuda

EXEMPLOS:
  $(basename "$0") --disk-warn 75 --disk-crit 90 --processes "node,python" --notify
  $(basename "$0") --check-once --verbose

VARIÁVEIS DE AMBIENTE:
  HERMES_LOG_DIR          Diretório de logs (default: /tmp)
  HERMES_MONITOR_DISK_WARN  Limite warning (default: 80)
  HERMES_MONITOR_DISK_CRIT  Limite crítico (default: 90)

EXIT CODES:
  0  Todos os checks OK
  1  Pelo menos um check com status CRIT
  2  Erro de argumentos
EOF
  exit 0
}

# --- Parse argumentos ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk-warn)   DISK_WARN="$2"; shift 2 ;;
    --disk-crit)   DISK_CRIT="$2"; shift 2 ;;
    --processes)   PROCESS_LIST="$2"; shift 2 ;;
    --notify)      NOTIFY=true; shift ;;
    --check-once)  CHECK_ONCE=true; shift ;;
    --verbose)     VERBOSE=true; shift ;;
    -h|--help)     usage ;;
    *)             err "Argumento desconhecido: $1"; exit 2 ;;
  esac
done

# --- Overrides de variáveis de ambiente ---
DISK_WARN="${HERMES_MONITOR_DISK_WARN:-$DISK_WARN}"
DISK_CRIT="${HERMES_MONITOR_DISK_CRIT:-$DISK_CRIT}"

log "Iniciando monitoramento (disk_warn=$DISK_WARN%, disk_crit=$DISK_CRIT%)"

overall_status="OK"

# --- Verificação de Disco ---
check_disk() {
  echo "=== 📊 Verificação de Disco ==="

  while IFS= read -r line; do
    filesystem=$(echo "$line" | awk '{print $1}')
    usage_pct=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount=$(echo "$line" | awk '{print $6}')
    size=$(echo "$line" | awk '{print $2}')
    used=$(echo "$line" | awk '{print $3}')
    avail=$(echo "$line" | awk '{print $4}')

    if [[ "$usage_pct" -ge "$DISK_CRIT" ]]; then
      alert "CRIT" "Disco CRÍTICO: $mount ($usage_pct% usado) - $avail livre de $size"
      overall_status="CRIT"
    elif [[ "$usage_pct" -ge "$DISK_WARN" ]]; then
      alert "WARN" "Disco WARNING: $mount ($usage_pct% usado) - $avail livre de $size"
      [[ "$overall_status" != "CRIT" ]] && overall_status="WARN"
    else
      alert "OK" "Disco OK: $mount ($usage_pct% usado) - $avail livre de $size"
    fi
  done < <(df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs 2>/dev/null | tail -n +2 || \
           df -h 2>/dev/null | tail -n +2 | awk '{print $1, $2, $3, $4, $5, $6}')
}

# --- Verificação de Processos ---
check_processes() {
  if [[ -z "$PROCESS_LIST" ]]; then
    return
  fi

  echo ""
  echo "=== 🔍 Verificação de Processos ==="

  IFS=',' read -ra processes <<< "$PROCESS_LIST"
  for proc in "${processes[@]}"; do
    proc=$(echo "$proc" | xargs)  # trim whitespace
    pid=$(pgrep -f "$proc" 2>/dev/null | head -1 || true)

    if [[ -n "$pid" ]]; then
      cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null | xargs || echo "N/A")
      mem=$(ps -p "$pid" -o %mem= 2>/dev/null | xargs || echo "N/A")
      alert "OK" "Processo '$proc' ATIVO (PID=$pid, CPU=$cpu%, MEM=$mem%)"
    else
      alert "WARN" "Processo '$proc' NÃO ENCONTRADO"
      [[ "$overall_status" != "CRIT" ]] && overall_status="WARN"
    fi
  done
}

# --- Verificação de Memória ---
check_memory() {
  echo ""
  echo "=== 🧠 Verificação de Memória ==="

  if command -v free &>/dev/null; then
    mem_info=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')
    swap_info=$(free -m | awk 'NR==3{if($2>0) printf "%.1f%%", $3*100/$2; else print "N/A"}')
    alert "OK" "Memória: $mem_info | Swap: $swap_info"
  fi
}

# --- Executar verificações ---
check_disk
check_processes
check_memory

# --- Relatório final ---
echo ""
echo "=== 📋 Resumo ==="
echo "Status geral: $overall_status"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Log: $LOG_FILE"

log "Monitoramento concluído. Status: $overall_status"

# --- Exit code ---
case "$overall_status" in
  CRIT) exit 1 ;;
  WARN) exit 0 ;;
  *)    exit 0 ;;
esac
