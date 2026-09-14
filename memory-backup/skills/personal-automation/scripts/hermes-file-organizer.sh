#!/usr/bin/env bash
# =============================================================================
# hermes-file-organizer.sh
# Organiza arquivos por tipo (extensão) e data de modificação.
# Deduplica arquivos por hash MD5.
# =============================================================================
set -euo pipefail

# --- Configuração ---
LOG_FILE="${HERMES_LOG_DIR:-/tmp}/hermes-automation.log"
DRY_RUN=false
DEDUP=false
VERBOSE=false
SOURCE=""
TARGET=""

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Funções ---
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [file-organizer] $1"
  echo -e "$msg" >> "$LOG_FILE"
  [[ "$VERBOSE" == true ]] && echo -e "${GREEN}$msg${NC}"
}

warn() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [file-organizer] WARN: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${YELLOW}$msg${NC}" >&2
}

err() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [file-organizer] ERROR: $1"
  echo -e "$msg" >> "$LOG_FILE"
  echo -e "${RED}$msg${NC}" >&2
}

usage() {
  cat <<EOF
Uso: $(basename "$0") [OPÇÕES]

Organiza arquivos por tipo e data, com deduplicação opcional por hash.

OPÇÕES:
  --source DIR     Diretório de origem (obrigatório)
  --target DIR     Diretório de destino (obrigatório)
  --dedup          Ativar deduplicação por hash MD5
  --dry-run        Simular sem mover arquivos
  --verbose        Saída detalhada
  --log            Ativar logging em arquivo
  -h, --help       Mostrar esta ajuda

EXEMPLOS:
  $(basename "$0") --source ~/Downloads --target ~/Organized --dedup
  $(basename "$0") --source /tmp/inbox --target ~/Sorted --dry-run

VARIÁVEIS DE AMBIENTE:
  HERMES_LOG_DIR   Diretório de logs (default: /tmp)

EXIT CODES:
  0  Sucesso
  1  Erro de argumentos ou execução
EOF
  exit 0
}

cleanup() {
  rm -f /tmp/hermes-fo-*.tmp 2>/dev/null || true
}
trap cleanup EXIT

# --- Mapeamento de extensões ---
get_category() {
  local ext="${1##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  case "$ext" in
    pdf)                        echo "Documents/PDF" ;;
    doc|docx|odt|rtf|tex)      echo "Documents/Word" ;;
    xls|xlsx|csv|ods)           echo "Documents/Spreadsheets" ;;
    ppt|pptx|odp)               echo "Documents/Presentations" ;;
    txt|md|markdown)            echo "Documents/Text" ;;
    jpg|jpeg|png|gif|bmp|svg|webp|heic|tiff)
                                echo "Images" ;;
    mp4|avi|mkv|mov|wmv|flv|webm)
                                echo "Videos" ;;
    mp3|wav|flac|aac|ogg|wma|m4a)
                                echo "Audio" ;;
    zip|tar|gz|bz2|xz|7z|rar|zst)
                                echo "Archives" ;;
    sh|bash|zsh)                echo "Scripts/Shell" ;;
    py|pyc|pyw)                 echo "Scripts/Python" ;;
    js|ts|jsx|tsx)              echo "Scripts/JavaScript" ;;
    html|css|scss|less)         echo "Web" ;;
    json|yaml|yml|toml|xml|ini|conf)
                                echo "Config" ;;
    exe|deb|rpm|AppImage|dmg)  echo "Executables" ;;
    iso|img|vmdk)               echo "DiskImages" ;;
    *)                          echo "Other" ;;
  esac
}

get_date_path() {
  local file="$1"
  local mod_date
  mod_date=$(stat -c '%Y' "$file" 2>/dev/null || stat -f '%m' "$file" 2>/dev/null)
  local year month day
  year=$(date -d "@$mod_date" '+%Y' 2>/dev/null || date -r "$mod_date" '+%Y' 2>/dev/null)
  month=$(date -d "@$mod_date" '+%m' 2>/dev/null || date -r "$mod_date" '+%m' 2>/dev/null)
  day=$(date -d "@$mod_date" '+%d' 2>/dev/null || date -r "$mod_date" '+%d' 2>/dev/null)
  echo "${year}/${month}/${day}"
}

compute_hash() {
  md5sum "$1" 2>/dev/null | awk '{print $1}' || md5 -q "$1" 2>/dev/null
}

# --- Parse argumentos ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)   SOURCE="$2"; shift 2 ;;
    --target)   TARGET="$2"; shift 2 ;;
    --dedup)    DEDUP=true; shift ;;
    --dry-run)  DRY_RUN=true; shift ;;
    --verbose)  VERBOSE=true; shift ;;
    --log)      VERBOSE=true; shift ;;
    -h|--help)  usage ;;
    *)          err "Argumento desconhecido: $1"; exit 1 ;;
  esac
done

# --- Validações ---
if [[ -z "$SOURCE" || -z "$TARGET" ]]; then
  err "Argumentos --source e --target são obrigatórios."
  usage
fi

if [[ ! -d "$SOURCE" ]]; then
  err "Diretório fonte não existe: $SOURCE"
  exit 1
fi

mkdir -p "$TARGET"

log "Iniciando organização: $SOURCE -> $TARGET (dedup=$DEDUP, dry_run=$DRY_RUN)"

# --- Estatísticas ---
declare -A seen_hashes
moved=0
skipped=0
duplicates=0
errors=0

# --- Processamento ---
while IFS= read -r -d '' file; do
  [[ -z "$file" ]] && continue

  # Deduplicação
  if [[ "$DEDUP" == true ]]; then
    hash=$(compute_hash "$file")
    if [[ -n "${seen_hashes[$hash]:-}" ]]; then
      log "Duplicata encontrada: $file (hash=$hash, original=${seen_hashes[$hash]})"
      if [[ "$DRY_RUN" == false ]]; then
        rm -f "$file"
      fi
      ((duplicates++))
      continue
    fi
    seen_hashes[$hash]="$file"
  fi

  # Determinar destino
  category=$(get_category "$file")
  date_path=$(get_date_path "$file")
  dest_dir="${TARGET}/${category}/${date_path}"
  dest_file="${dest_dir}/$(basename "$file")"

  # Evitar sobrescrever
  if [[ -f "$dest_file" ]]; then
    base="${dest_file%.*}"
    ext="${dest_file##*.}"
    counter=1
    while [[ -f "${base}_${counter}.${ext}" ]]; do
      ((counter++))
    done
    dest_file="${base}_${counter}.${ext}"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log "[DRY-RUN] Moveria: $file -> $dest_file"
  else
    mkdir -p "$dest_dir"
    if mv "$file" "$dest_file" 2>/dev/null; then
      log "Movido: $file -> $dest_file"
      ((moved++))
    else
      warn "Falha ao mover: $file"
      ((errors++))
    fi
  fi
done < <(find "$SOURCE" -type f -print0 2>/dev/null)

# --- Relatório ---
report="Organização concluída:\n"
report+="  Arquivos movidos: $moved\n"
report+="  Duplicatas removidas: $duplicates\n"
report+="  Erros: $errors\n"
report+="  Destino: $TARGET"

echo -e "$report"
log "$report"

[[ $errors -gt 0 ]] && exit 1
exit 0
