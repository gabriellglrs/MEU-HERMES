#!/bin/bash
# ============================================
# Monitoramento do Sistema - MEU-HERMES
# ============================================
# Monitora CPU, memória, disco e rede
# Uso: ./monitor-system.sh [intervalo_em_segundos]
# ============================================

INTERVAL=${1:-5}

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         MONITORAMENTO EM TEMPO REAL - Ctrl+C para sair     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    clear
    echo "═══ $(date '+%H:%M:%S') ═══"
    echo ""
    
    # CPU
    echo "📊 CPU:"
    top -bn1 | grep "Cpu(s)" | awk '{print "  Uso: " $2 "%"}'
    load=$(uptime | awk -F'load average:' '{print $2}')
    echo "  Load Average:$load"
    echo ""
    
    # Memória
    echo "💾 MEMÓRIA:"
    free -h | awk '/Mem:/ {print "  Total: " $2 " | Usado: " $3 " | Livre: " $4}'
    echo ""
    
    # Disco
    echo "💿 DISCO:"
    df -h / | awk 'NR==2 {print "  Usado: " $3 " / " $2 " (" $5 ")"}'
    echo ""
    
    # Rede
    echo "🌐 REDE:"
    echo "  Conexões TCP ativas: $(ss -tuln | grep -c LISTEN)"
    echo ""
    
    # Processos
    echo "⚙️  TOP 3 PROCESSOS (CPU):"
    ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "  %s: %s%%\n", $11, $3}'
    echo ""
    
    echo "═══ Atualizando a cada ${INTERVAL}s ═══"
    sleep $INTERVAL
done
