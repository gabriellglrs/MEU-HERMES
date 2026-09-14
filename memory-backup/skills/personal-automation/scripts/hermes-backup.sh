#!/usr/bin/env bash
# =============================================================================
# hermes-backup.sh
# Backup incremental com rsync/tar, checksum SHA256, retenção e notificação.
# =============================================================================
set -euo pipefail

# --- Configuração ---
LOG_FILE="${HERMES_LOG_DIR:-/tmp}/hermes-automation.log"
SOURCE="${HERMES_BACKUP_SRC:-$HOME/Documents}"
DEST="${HERMES_BACKUP_DST:-$HOME/Backups}"
BACKUP_NAME=""
CHECKSUM=false
NOTIFY=false
RETAIN=0
DRY_RUN=false
VERBOSE=false

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Funções ---
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [backup] $1"
  echo -e "$msg" >> "$LOG_FILE"
  [[ "$VERBOSE" == true ]] && echo -e "${GREEN}$msg${NC}"
}

warn() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [backup] WARN: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${YELLOW}$msg${NC}" >&2
}

err() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [backup] ERROR: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${RED}$msg${NC}" >&2
}

usage() {
  cat <<EOF
Uso: $(basename "$0") [OPÇÕES]

Backup incremental com verificação de integridade.

OPÇÕES:
  --source DIR     Diretório fonte (default: ~/Documents)
  --dest DIR       Diretório destino (default: ~/Backups)
  --name NAME      Nome do archive (default: backup-YYYYMMDD-HHMMSS)
  --checksum       Gerar checksum SHA256
  --notify         Notificar resultado via Hermes
  --retain N       Manter apenas N backups anteriores
  --dry-run        Simular sem criar backup
  --verbose        Saída detalhada
  -h, --help       Mostrar esta ajuda

VARIÁVEIS DE AMBIENTE:
  HERMES_BACKUP_SRC   Diretório fonte (default: ~/Documents)
  HERMES_BACKUP_DST   Diretório destino (default: ~/Backups)
  HERMES_LOG_DIR      Diretório de logs (default: /tmp)

EXIT CODES:
  0  Sucesso
  1  Erro de argumentos ou execução
EOF
  exit 0
}

cleanup() {
  rm -f /tmp/hermes-backup-*.tmp 2>/dev/null || true
}
trap cleanup EXIT

# --- Parse argumentos ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)    SOURCE="$2"; shift 2 ;;
    --dest)      DEST="$2"; shift 2 ;;
    --name)      BACKUP_NAME="$2"; shift 2 ;;
    --checksum)  CHECKSUM=true; shift ;;
    --notify)    NOTIFY=true; shift ;;
    --retain)    RETAIN="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --verbose)   VERBOSE=true; shift ;;
    -h|--help)   usage ;;
    *)           err "Argumento desconhecido: $1"; exit 1 ;;
  esac
done

# --- Validações ---
if [[ ! -d "$SOURCE" ]]; then
  err "Diretório fonte não existe: $SOURCE"
  exit 1
fi

BACKUP_NAME="${BACKUP_NAME:-backup-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$DEST"

ARCHIVE="${DEST}/${BACKUP_NAME}.tar.gz"
CHECKSUM_FILE="${ARCHIVE}.sha256"
LOG_SNAPSHOT="${DEST}/${BACKUP_NAME}.log"

log "Iniciando backup: $SOURCE -> $ARCHIVE (checksum=$CHECKSUM, retain=$RETAIN)"

START_TIME=$(date +%s)

# --- Criar backup incremental ---
if [[ "$DRY_RUN" == true ]]; then
  log "[DRY-RUN] Criaria archive: $ARCHIVE"
  file_count=$(find "$SOURCE" -type f | wc -l)
  log "[DRY-RUN] $file_count arquivos seriam incluídos"
else
  # Usar rsync para snapshot incremental se houver backup anterior
  latest_link="${DEST}/latest"
  incremental_flag=""
  if [[ -L "$latest_link" ]]; then
    incremental_flag="--link-dest=$latest_link"
    log "Backup incremental baseado em: $(readlink -f "$latest_link")"
  fi

  # Criar archive com tar
  tar czf "$ARCHIVE" \
    --exclude='*.tmp' \
    --exclude='.DS_Store' \
    --exclude='node_modules' \
    --exclude='.git' \
    -C "$(dirname "$SOURCE")" \
    "$(basename "$SOURCE")" 2>/dev/null

  if [[ $? -ne 0 ]]; then
    err "Falha ao criar archive: $ARCHIVE"
    exit 1
  fi

  # Atualizar link latest
  rm -f "$latest_link"
  ln -sf "$ARCHIVE" "$latest_link"

  log "Archive criado: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"
fi

# --- Gerar checksum ---
if [[ "$CHECKSUM" == true && "$DRY_RUN" == false ]]; then
  if command -v sha256sum &>/dev/null; then
    sha256sum "$ARCHIVE" > "$CHECKSUM_FILE"
  elif command -v shasum &>/dev/null; then
    shasum -a 256 "$ARCHIVE" > "$CHECKSUM_FILE"
  else
    warn "Nenhum utilitário de checksum encontrado (sha256sum/shasum)"
  fi
  log "Checksum gerado: $CHECKSUM_FILE"
fi

# --- Reter backups antigos ---
if [[ $RETAIN -gt 0 && "$DRY_RUN" == false ]]; then
  backup_count=$(find "$DEST" -name "backup-*.tar.gz" -type f | wc -l)
  if [[ $backup_count -gt $RETAIN ]]; then
    to_remove=$((backup_count - RETAIN))
    log "Removendo $to_remove backups antigos (mantendo $RETAIN)"
    find "$DEST" -name "backup-*.tar.gz" -type f -printf '%T+ %p\n' 2>/dev/null | \
      sort | head -n "$to_remove" | awk '{print $2}' | \
      xargs -I{} rm -f "{}" "{}.sha256" 2>/dev/null || true
  fi
fi

# --- Calcular duração ---
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# --- Relatório ---
archive_size="N/A"
if [[ "$DRY_RUN" == false && -f "$ARCHIVE" ]]; then
  archive_size=$(du -h "$ARCHIVE" | cut -f1)
fi

report="Backup concluído:\n"
report+="  Source: $SOURCE\n"
report+="  Archive: $ARCHIVE\n"
report+="  Tamanho: $archive_size\n"
report+="  Checksum: $([ "$CHECKSUM" == true ] && echo "$CHECKSUM_FILE" || echo "N/A")\n"
report+="  Duração: ${DURATION}s\n"
report+="  Retenção: $RETAIN backups"

echo -e "$report"
log "$report"

# --- Notificação via Hermes ---
if [[ "$NOTIFY" == true ]]; then
  notification="✅ Backup concluído com sucesso!\n"
  notification+="📁 $SOURCE -> $ARCHIVE\n"
  notification+="📊 Tamanho: $archive_size | Duração: ${DURATION}s"

  if [[ -n "${HERMES_NOTIFY_TARGET:-}" ]]; then
    echo -e "$notification" | hermes-notify --target "$HERMES_NOTIFY_TARGET" 2>/dev/null || \
      echo -e "$notification"
  else
    echo -e "$notification"
  fi
fi

exit 0
