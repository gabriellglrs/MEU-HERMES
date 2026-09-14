#!/bin/bash
# ============================================
# Script de Instalação - MEU-HERMES
# ============================================

set -e

echo "🚀 Instalando configuração MEU-HERMES..."

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório alvo
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

# Verificar se Hermes está instalado
if ! command -v hermes &> /dev/null; then
    echo -e "${YELLOW}⚠️  Hermes não encontrado. Instalando...${NC}"
    curl -fsSL https://hermes.ai/install.sh | bash
fi

echo -e "${GREEN}✓ Hermes encontrado${NC}"

# Criar diretório se não existir
mkdir -p "$HERMES_HOME"

# Backup da configuração atual
if [ -f "$HERMES_HOME/config.yaml" ]; then
    echo -e "${YELLOW}📦 Criando backup da configuração atual...${NC}"
    BACKUP_DIR="$HERMES_HOME/backups/manual_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "$HERMES_HOME/config.yaml" "$BACKUP_DIR/" 2>/dev/null || true
    cp "$HERMES_HOME/SOUL.md" "$BACKUP_DIR/" 2>/dev/null || true
    cp "$HERMES_HOME/honcho.json" "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ Backup em: $BACKUP_DIR${NC}"
fi

# Copiar configurações (fonte da verdade: MEU-HERMES)
echo -e "${GREEN}📋 Copiando configurações...${NC}"
cp -v config.yaml "$HERMES_HOME/"
cp -v SOUL.md "$HERMES_HOME/"
[ -f honcho.json ] && cp -v honcho.json "$HERMES_HOME/"
[ -f rtk-config.toml ] && cp -v rtk-config.toml "$HERMES_HOME/"

# Copiar skills (merge, sem apagar bundled)
echo -e "${GREEN}📚 Copiando skills...${NC}"
mkdir -p "$HERMES_HOME/skills"
if [ -d "skills" ]; then
    cp -rv skills/* "$HERMES_HOME/skills/" 2>/dev/null || true
fi

# Copiar plugins
echo -e "${GREEN}🔌 Copiando plugins...${NC}"
mkdir -p "$HERMES_HOME/plugins"
if [ -d "plugins" ]; then
    cp -rv plugins/* "$HERMES_HOME/plugins/" 2>/dev/null || true
else
    echo -e "${YELLOW}⚠️  Pasta plugins/ não existe no repo, pulando.${NC}"
fi

# Copiar scripts de automação
echo -e "${GREEN}🖥️  Copiando scripts...${NC}"
mkdir -p "$HERMES_HOME/scripts"
if [ -d "scripts" ]; then
    cp -rv scripts/* "$HERMES_HOME/scripts/" 2>/dev/null || true
    chmod +x "$HERMES_HOME/scripts/"*.sh 2>/dev/null || true
fi

# Copiar cron jobs
echo -e "${GREEN}⏰ Copiando cron-jobs...${NC}"
mkdir -p "$HERMES_HOME/cron-jobs"
if [ -d "cron-jobs" ]; then
    cp -rv cron-jobs/* "$HERMES_HOME/cron-jobs/" 2>/dev/null || true
fi

# Copiar utilitários de backup
[ -f backup-memory.sh ] && cp -v backup-memory.sh "$HERMES_HOME/"
[ -f restore-memory.sh ] && cp -v restore-memory.sh "$HERMES_HOME/"
chmod +x "$HERMES_HOME/backup-memory.sh" "$HERMES_HOME/restore-memory.sh" 2>/dev/null || true

# Verificar .env
if [ ! -f "$HERMES_HOME/.env" ]; then
    echo -e "${YELLOW}⚠️  Arquivo .env não encontrado!${NC}"
    echo -e "Crie o arquivo em: $HERMES_HOME/.env"
    echo ""
    echo "Exemplo:"
    echo "OPENAI_API_KEY=sua-chave-aqui"
    echo "ANTHROPIC_API_KEY=sua-chave-aqui"
fi

# Habilitar plugin opencode se existir
if [ -d "$HERMES_HOME/plugins/opencode" ]; then
    echo -e "${GREEN}🔌 Habilitando plugin opencode...${NC}"
    hermes plugins enable opencode 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}✅ Instalação concluída!${NC}"
echo ""
echo "Próximos passos:"
echo "1. Configure suas chaves de API em: $HERMES_HOME/.env"
echo "2. Reinicie o Hermes: hermes"
echo ""
