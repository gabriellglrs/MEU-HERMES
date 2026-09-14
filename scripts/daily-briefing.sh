#!/bin/bash
# ============================================
# Briefing Matinal - MEU-HERMES
# ============================================
# Executa verificação completa do sistema
# Uso: ./daily-briefing.sh
# ============================================

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           BRIEFING MATINAL - $(date '+%d/%m/%Y %H:%M')           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Status do Sistema
echo -e "${BLUE}═══ STATUS DO SISTEMA ═══${NC}"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo ""

# 2. Uso de Recursos
echo -e "${BLUE}═══ USO DE RECURSOS ═══${NC}"
echo "CPU:"
top -bn1 | grep "Cpu(s)" | awk '{print "  Uso: " $2 "% | Idle: " $8 "%"}'
echo ""
echo "Memória:"
free -h | awk '/Mem:/ {print "  Total: " $2 " | Usado: " $3 " | Livre: " $4}'
echo ""
echo "Disco:"
df -h / | awk 'NR==2 {print "  Total: " $2 " | Usado: " $3 " (" $5 ") | Livre: " $4}'
echo ""

# 3. Serviços Críticos
echo -e "${BLUE}═══ SERVIÇOS CRÍTICOS ═══${NC}"
for service in docker nginx sshd postgresql mysql; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $service: ativo"
    elif systemctl is-enabled --quiet $service 2>/dev/null; then
        echo -e "  ${YELLOW}●${NC} $service: inativo (mas habilitado)"
    fi
done
echo ""

# 4. Updates Disponíveis
echo -e "${BLUE}═══ ATUALIZAÇÕES ═══${NC}"
if command -v apt &> /dev/null; then
    updates=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo "0")
    echo "  Pacotes com update: $updates"
elif command -v dnf &> /dev/null; then
    updates=$(dnf check-update 2>/dev/null | wc -l || echo "0")
    echo "  Pacotes com update: $updates"
elif command -v pacman &> /dev/null; then
    echo "  Execute: pacman -Syu"
fi
echo ""

# 5. Logs de Erro (últimas 24h)
echo -e "${BLUE}═══ ERROS RECENTES ═══${NC}"
errors=$(journalctl --since "24 hours ago" -p err --no-pager -q 2>/dev/null | wc -l)
echo "  Erros nas últimas 24h: $errors"
if [ $errors -gt 0 ]; then
    echo "  Últimos 3 erros:"
    journalctl --since "24 hours ago" -p err --no-pager -q 2>/dev/null | tail -3 | sed 's/^/    /'
fi
echo ""

# 6. Conexões de Rede
echo -e "${BLUE}═══ REDE ═══${NC}"
echo "  IP local: $(hostname -I | awk '{print $1}')"
echo "  Conexões ativas: $(ss -tuln | grep -c LISTEN)"
echo ""

# 7. Processos com Maior Uso
echo -e "${BLUE}═══ TOP 5 PROCESSOS (CPU) ═══${NC}"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %s %s%% CPU | %s%% MEM\n", $11, $3, $4}'
echo ""

# 8. Alertas de Segurança
echo -e "${BLUE}═══ SEGURANÇA ═══${NC}"
failed_logins=$(journalctl --since "24 hours ago" | grep -c "Failed password" || echo "0")
echo "  Tentativas de login falhas: $failed_logins"
if [ $failed_logins -gt 10 ]; then
    echo -e "  ${RED}⚠ ALERTA: Muitas tentativas de login!${NC}"
fi
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    BRIEFING CONCLUÍDO                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
