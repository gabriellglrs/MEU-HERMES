#!/bin/bash
# ============================================
# Backup de Configurações - MEU-HERMES
# ============================================
# Backup automático de configs importantes
# Uso: ./backup-configs.sh [diretório_destino]
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Diretório de destino
DEST_DIR="${1:-$HOME/backups/configs/$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$DEST_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           BACKUP DE CONFIGURAÇÕES - $(date '+%d/%m/%Y')           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 1. Configurações do Sistema
echo -e "${YELLOW}📦 Copiando configurações do sistema...${NC}"
mkdir -p "$DEST_DIR/system"
cp -r /etc/nginx "$DEST_DIR/system/" 2>/dev/null || true
cp -r /etc/ssh "$DEST_DIR/system/" 2>/dev/null || true
cp -r /etc/docker "$DEST_DIR/system/" 2>/dev/null || true
cp /etc/fstab "$DEST_DIR/system/" 2>/dev/null || true
cp /etc/hosts "$DEST_DIR/system/" 2>/dev/null || true
echo -e "${GREEN}✓ Configurações do sistema copiadas${NC}"

# 2. Configurações do Hermes
echo -e "${YELLOW}📦 Copiando configurações do Hermes...${NC}"
mkdir -p "$DEST_DIR/hermes"
cp ~/.hermes/config.yaml "$DEST_DIR/hermes/" 2>/dev/null || true
cp ~/.hermes/SOUL.md "$DEST_DIR/hermes/" 2>/dev/null || true
cp ~/.hermes/.env "$DEST_DIR/hermes/" 2>/dev/null || true
echo -e "${GREEN}✓ Configurações do Hermes copiadas${NC}"

# 3. Configurações do Docker
echo -e "${YELLOW}📦 Copiando configurações do Docker...${NC}"
mkdir -p "$DEST_DIR/docker"
if [ -f /var/run/docker.sock ]; then
    docker ps -a > "$DEST_DIR/docker/containers.txt" 2>/dev/null || true
    docker images > "$DEST_DIR/docker/images.txt" 2>/dev/null || true
    docker volume ls > "$DEST_DIR/docker/volumes.txt" 2>/dev/null || true
fi
echo -e "${GREEN}✓ Configurações do Docker copiadas${NC}"

# 4. Crontab
echo -e "${YELLOW}📦 Copiando crontab...${NC}"
mkdir -p "$DEST_DIR/cron"
crontab -l > "$DEST_DIR/cron/crontab.txt" 2>/dev/null || echo "Nenhum crontab encontrado"
echo -e "${GREEN}✓ Crontab copiado${NC}"

# 5. Lista de pacotes instalados
echo -e "${YELLOW}📦 Salvando lista de pacotes...${NC}"
mkdir -p "$DEST_DIR/packages"
if command -v apt &> /dev/null; then
    dpkg --get-selections > "$DEST_DIR/packages/apt-packages.txt" 2>/dev/null
elif command -v dnf &> /dev/null; then
    dnf list installed > "$DEST_DIR/packages/dnf-packages.txt" 2>/dev/null
elif command -v pacman &> /dev/null; then
    pacman -Q > "$DEST_DIR/packages/pacman-packages.txt" 2>/dev/null
fi
echo -e "${GREEN}✓ Lista de pacotes salva${NC}"

# 6. Compactar backup
echo -e "${YELLOW}📦 Compactando backup...${NC}"
BACKUP_NAME="backup-configs-$(date +%Y%m%d_%H%M%S).tar.gz"
cd "$(dirname "$DEST_DIR")"
tar -czf "$BACKUP_NAME" "$(basename "$DEST_DIR")"
echo -e "${GREEN}✓ Backup compactado: $BACKUP_NAME${NC}"

# 7. Resumo
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    BACKUP CONCLUÍDO                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📍 Local: $DEST_DIR"
echo "📦 Arquivo: $(dirname "$DEST_DIR")/$BACKUP_NAME"
echo "📊 Tamanho: $(du -sh "$DEST_DIR" | awk '{print $1}')"
echo ""
