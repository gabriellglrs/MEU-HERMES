#!/bin/bash
# ============================================
# Backup da Memória do Hermes
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Diretórios
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
BACKUP_DIR="$HOME/MEU-HERMES/memory-backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${GREEN}🧠 Backup da Memória do Hermes${NC}"
echo "=================================="

# Criar diretório de backup
mkdir -p "$BACKUP_DIR"

# 1. Exportar sessões para JSONL (formato seguro, texto)
echo -e "${YELLOW}📦 Exportando sessões...${NC}"
hermes sessions export --format jsonl --redact "$BACKUP_DIR/sessions_$TIMESTAMP.jsonl" 2>/dev/null || true

# 2. Copiar SOUL.md (personalidade)
echo -e "${YELLOW}👤 Copiando SOUL.md...${NC}"
cp "$HERMES_HOME/SOUL.md" "$BACKUP_DIR/SOUL.md" 2>/dev/null || true

# 3. Copiar MEMORY.md e USER.md (se existirem)
echo -e "${YELLOW}📝 Copiando memórias...${NC}"
cp "$HERMES_HOME/MEMORY.md" "$BACKUP_DIR/MEMORY.md" 2>/dev/null || true
cp "$HERMES_HOME/USER.md" "$BACKUP_DIR/USER.md" 2>/dev/null || true

# 4. Copiar config.yaml (sem chaves sensíveis)
echo -e "${YELLOW}⚙️  Copiando config.yaml...${NC}"
cp "$HERMES_HOME/config.yaml" "$BACKUP_DIR/config.yaml" 2>/dev/null || true

# 5. Copiar skills criadas pelo usuário (não as bundled)
echo -e "${YELLOW}📚 Copiando skills...${NC}"
mkdir -p "$BACKUP_DIR/skills"
if [ -d "$HERMES_HOME/skills" ]; then
    # Copiar apenas skills que não são bundled
    for skill in "$HERMES_HOME/skills"/*/; do
        skill_name=$(basename "$skill")
        # Verificar se não é uma skill bundled (excluindo as que vêm com o Hermes)
        if [[ "$skill_name" != "." && "$skill_name" != ".." && "$skill_name" != ".bundled_manifest" && "$skill_name" != ".curator_state" && "$skill_name" != ".curator_ledger.jsonl" && "$skill_name" != ".hub" ]]; then
            cp -r "$skill" "$BACKUP_DIR/skills/" 2>/dev/null || true
        fi
    done
fi

# 6. Criar arquivo de metadados
echo -e "${YELLOW}📋 Criando metadados...${NC}"
cat > "$BACKUP_DIR/metadata.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "hermes_version": "$(hermes --version 2>/dev/null | head -1)",
  "hostname": "$(hostname)",
  "user": "$(whoami)",
  "description": "Backup da memória do Hermes Agent"
}
EOF

# 7. Compactar
echo -e "${YELLOW}🗜️  Compactando...${NC}"
cd "$BACKUP_DIR/.."
tar -czf "hermes-memory-backup_$TIMESTAMP.tar.gz" -C "$HOME/MEU-HERMES" memory-backup/

echo ""
echo -e "${GREEN}✅ Backup concluído!${NC}"
echo ""
echo "Arquivos criados:"
echo "  - $BACKUP_DIR/ (arquivos individuais)"
echo "  - $HOME/MEU-HERMES/hermes-memory-backup_$TIMESTAMP.tar.gz (compactado)"
echo ""
echo "Para enviar ao GitHub:"
echo "  cd ~/MEU-HERMES"
echo "  git add memory-backup/"
echo "  git commit -m 'backup: memória $TIMESTAMP'"
echo "  git push"
