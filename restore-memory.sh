#!/bin/bash
# ============================================
# Restauração da Memória do Hermes
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

echo -e "${GREEN}🧠 Restauração da Memória do Hermes${NC}"
echo "=================================="

# Verificar se há backup
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ Nenhum backup encontrado em: $BACKUP_DIR${NC}"
    echo "Execute primeiro: ./backup-memory.sh"
    exit 1
fi

# Confirmar restauração
echo -e "${YELLOW}⚠️  Isso vai restaurar a memória do Hermes do backup.${NC}"
echo -e "${YELLOW}   Sessões atuais serão substituídas.${NC}"
read -p "Continuar? (s/N): " confirm
if [[ ! "$confirm" =~ ^[Ss]$ ]]; then
    echo "Restauração cancelada."
    exit 0
fi

# 1. Restaurar SOUL.md
echo -e "${YELLOW}👤 Restaurando SOUL.md...${NC}"
if [ -f "$BACKUP_DIR/SOUL.md" ]; then
    cp "$BACKUP_DIR/SOUL.md" "$HERMES_HOME/"
    echo -e "${GREEN}   ✓ SOUL.md restaurado${NC}"
fi

# 2. Restaurar MEMORY.md e USER.md
echo -e "${YELLOW}📝 Restaurando memórias...${NC}"
if [ -f "$BACKUP_DIR/MEMORY.md" ]; then
    cp "$BACKUP_DIR/MEMORY.md" "$HERMES_HOME/"
    echo -e "${GREEN}   ✓ MEMORY.md restaurado${NC}"
fi
if [ -f "$BACKUP_DIR/USER.md" ]; then
    cp "$BACKUP_DIR/USER.md" "$HERMES_HOME/"
    echo -e "${GREEN}   ✓ USER.md restaurado${NC}"
fi

# 3. Restaurar config.yaml (opcional)
echo -e "${YELLOW}⚙️  Restaurando config.yaml...${NC}"
if [ -f "$BACKUP_DIR/config.yaml" ]; then
    read -p "Restaurar config.yaml? Isso substitui a configuração atual (s/N): " restore_config
    if [[ "$restore_config" =~ ^[Ss]$ ]]; then
        cp "$HERMES_HOME/config.yaml" "$HERMES_HOME/config.yaml.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        cp "$BACKUP_DIR/config.yaml" "$HERMES_HOME/"
        echo -e "${GREEN}   ✓ config.yaml restaurado${NC}"
    else
        echo -e "${YELLOW}   ⊘ config.yaml preservado${NC}"
    fi
fi

# 4. Restaurar skills
echo -e "${YELLOW}📚 Restaurando skills...${NC}"
if [ -d "$BACKUP_DIR/skills" ]; then
    for skill in "$BACKUP_DIR/skills"/*/; do
        skill_name=$(basename "$skill")
        if [[ "$skill_name" != "." && "$skill_name" != ".." ]]; then
            cp -r "$skill" "$HERMES_HOME/skills/"
            echo -e "${GREEN}   ✓ Skill '$skill_name' restaurada${NC}"
        fi
    done
fi

# 5. Importar sessões (se existirem)
echo -e "${YELLOW}📦 Importando sessões...${NC}"
SESSIONS_FILE=$(ls -t "$BACKUP_DIR"/sessions_*.jsonl 2>/dev/null | head -1)
if [ -n "$SESSIONS_FILE" ]; then
    echo "   Encontrado: $SESSIONS_FILE"
    read -p "   Importar sessões? (s/N): " import_sessions
    if [[ "$import_sessions" =~ ^[Ss]$ ]]; then
        hermes sessions import "$SESSIONS_FILE" 2>/dev/null || true
        echo -e "${GREEN}   ✓ Sessões importadas${NC}"
    fi
else
    echo -e "${YELLOW}   ⊘ Nenhuma sessão encontrada no backup${NC}"
fi

echo ""
echo -e "${GREEN}✅ Restauração concluída!${NC}"
echo ""
echo "Próximos passos:"
echo "1. Reinicie o Hermes: hermes"
echo "2. Verifique se tudo está funcionando"
echo ""
