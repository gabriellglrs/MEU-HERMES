#!/bin/bash
# ============================================
# Verificação de Segurança - MEU-HERMES
# ============================================
# Verifica segurança básica do sistema
# Uso: ./security-check.sh
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         VERIFICAÇÃO DE SEGURANÇA - $(date '+%d/%m/%Y %H:%M')        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 1. Verificar atualizações de segurança
echo -e "${BLUE}═══ ATUALIZAÇÕES DE SEGURANÇA ═══${NC}"
if command -v apt &> /dev/null; then
    updates=$(apt list --upgradable 2>/dev/null | grep -c "security" || echo "0")
    if [ "$updates" -gt 0 ]; then
        echo -e "  ${RED}⚠ $updates atualizações de segurança pendentes${NC}"
    else
        echo -e "  ${GREEN}✓ Sistema atualizado${NC}"
    fi
fi
echo ""

# 2. Verificar portas abertas
echo -e "${BLUE}═══ PORTAS ABERTAS ═══${NC}"
echo "  Portas TCP em escuta:"
ss -tuln | grep LISTEN | awk '{print "    " $5}' | head -10
echo ""

# 3. Verificar logins falhos
echo -e "${BLUE}═══ TENTATIVAS DE LOGIN FALHAS ═══${NC}"
failed=$(journalctl --since "24 hours ago" | grep -c "Failed password" || echo "0")
if [ "$failed" -gt 10 ]; then
    echo -e "  ${RED}⚠ $failed tentativas nas últimas 24h${NC}"
    echo "  Últimas tentativas:"
    journalctl --since "24 hours ago" | grep "Failed password" | tail -3 | sed 's/^/    /'
else
    echo -e "  ${GREEN}✓ $failed tentativas (normal)${NC}"
fi
echo ""

# 4. Verificar serviços críticos
echo -e "${BLUE}═══ SERVIÇOS CRÍTICOS ═══${NC}"
for service in sshd docker nginx; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $service: ativo"
    fi
done
echo ""

# 5. Verificar permissões de arquivos sensíveis
echo -e "${BLUE}═══ PERMISSÕES DE SEGURANÇA ═══${NC}"
if [ -f ~/.ssh/id_rsa ]; then
    perms=$(stat -c %a ~/.ssh/id_rsa 2>/dev/null || echo "N/A")
    if [ "$perms" = "600" ]; then
        echo -e "  ${GREEN}✓${NC} ~/.ssh/id_rsa: permissões corretas ($perms)"
    else
        echo -e "  ${RED}⚠${NC} ~/.ssh/id_rsa: permissões incorretas ($perms) - deveria ser 600"
    fi
fi
echo ""

# 6. Verificar firewall
echo -e "${BLUE}═══ FIREWALL ═══${NC}"
if command -v ufw &> /dev/null; then
    status=$(ufw status 2>/dev/null | head -1)
    echo "  UFW: $status"
elif command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --state &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} firewalld: ativo"
    else
        echo -e "  ${YELLOW}●${NC} firewalld: inativo"
    fi
else
    echo -e "  ${YELLOW}●${NC} Nenhum firewall detectado"
fi
echo ""

# 7. Verificar atualizações do kernel
echo -e "${BLUE}═══ KERNEL ═══${NC}"
echo "  Versão atual: $(uname -r)"
echo ""

# 8. Verificar processos suspeitos
echo -e "${BLUE}═══ PROCESSOS SUSPEITOS ═══${NC}"
suspicious=$(ps aux | grep -E "(nc|netcat|ncat|socat)" | grep -v grep | wc -l)
if [ "$suspicious" -gt 0 ]; then
    echo -e "  ${RED}⚠ Processos suspeitos detectados:${NC}"
    ps aux | grep -E "(nc|netcat|ncat|socat)" | grep -v grep | sed 's/^/    /'
else
    echo -e "  ${GREEN}✓ Nenhum processo suspeito detectado${NC}"
fi
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║               VERIFICAÇÃO CONCLUÍDA                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
