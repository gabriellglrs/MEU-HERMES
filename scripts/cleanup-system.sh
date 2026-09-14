#!/bin/bash
# ============================================
# Limpeza do Sistema - MEU-HERMES
# ============================================
# Limpa cache, logs antigos e pacotes órfãos
# Uso: ./cleanup-system.sh [--dry-run]
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    echo -e "${YELLOW}modo dry-run habilitado${NC}"
fi

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            LIMPEZA DO SISTEMA - $(date '+%d/%m/%Y %H:%M')           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Espaço livre antes
echo -e "${BLUE}═══ ESPAÇO ANTES ═══${NC}"
df -h / | awk 'NR==2 {print "  Livre: " $4 " | Total: " $2}'
echo ""

# 1. Limpar cache do apt
echo -e "${BLUE}═══ CACHE APT ═══${NC}"
if command -v apt &> /dev/null; then
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get clean
        sudo apt-get autoremove -y
        echo -e "${GREEN}✓ Cache apt limpo${NC}"
    else
        echo -e "${YELLOW}  [DRY-RUN] apt-get clean${NC}"
    fi
fi
echo ""

# 2. Limpar logs antigos
echo -e "${BLUE}═══ LOGS ANTIGOS ═══${NC}"
if [ "$DRY_RUN" = false ]; then
    sudo journalctl --vacuum-time=7d --quiet
    sudo find /var/log -name "*.gz" -delete 2>/dev/null || true
    sudo find /var/log -name "*.old" -delete 2>/dev/null || true
    echo -e "${GREEN}✓ Logs antigos removidos${NC}"
else
    echo -e "${YELLOW}  [DRY-RUN] Limpeza de logs${NC}"
fi
echo ""

# 3. Limpar cache do Docker
echo -e "${BLUE}═══ DOCKER ═══${NC}"
if command -v docker &> /dev/null; then
    if [ "$DRY_RUN" = false ]; then
        docker system prune -f 2>/dev/null || true
        echo -e "${GREEN}✓ Cache do Docker limpo${NC}"
    else
        echo -e "${YELLOW}  [DRY-RUN] docker system prune${NC}"
    fi
fi
echo ""

# 4. Limpar cache do npm
echo -e "${BLUE}═══ NPM ═══${NC}"
if command -v npm &> /dev/null; then
    if [ "$DRY_RUN" = false ]; then
        npm cache clean --force 2>/dev/null || true
        echo -e "${GREEN}✓ Cache npm limpo${NC}"
    else
        echo -e "${YELLOW}  [DRY-RUN] npm cache clean${NC}"
    fi
fi
echo ""

# 5. Limpar cache do pip
echo -e "${BLUE}═══ PIP ═══${NC}"
if command -v pip &> /dev/null; then
    if [ "$DRY_RUN" = false ]; then
        pip cache purge 2>/dev/null || true
        echo -e "${GREEN}✓ Cache pip limpo${NC}"
    else
        echo -e "${YELLOW}  [DRY-RUN] pip cache purge${NC}"
    fi
fi
echo ""

# 6. Limpar arquivos temporários
echo -e "${BLUE}═══ ARQUIVOS TEMPORÁRIOS ═══${NC}"
if [ "$DRY_RUN" = false ]; then
    sudo find /tmp -type f -atime +7 -delete 2>/dev/null || true
    sudo find /var/tmp -type f -atime +7 -delete 2>/dev/null || true
    echo -e "${GREEN}✓ Arquivos temporários limpos${NC}"
else
    echo -e "${YELLOW}  [DRY-RUN] Limpeza de /tmp e /var/tmp${NC}"
fi
echo ""

# 7. Pacotes órfãos
echo -e "${BLUE}═══ PACOTES ÓRFÃOS ═══${NC}"
if command -v apt &> /dev/null; then
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get autoremove -y
        echo -e "${GREEN}✓ Pacotes órfãos removidos${NC}"
    else
        echo -e "${YELLOW}  [DRY-RUN] apt-get autoremove${NC}"
    fi
fi
echo ""

# Espaço livre depois
echo -e "${BLUE}═══ ESPAÇO DEPOIS ═══${NC}"
df -h / | awk 'NR==2 {print "  Livre: " $4 " | Total: " $2}'
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   LIMPEZA CONCLUÍDA                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
