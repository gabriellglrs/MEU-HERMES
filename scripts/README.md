# Scripts de Automação - MEU-HERMES

Scripts para automação de tarefas diárias no Linux.

## Scripts Disponíveis

### 1. daily-briefing.sh
**Briefing matinal completo do sistema**

```bash
./scripts/daily-briefing.sh
```

**Informações coletadas:**
- Status do sistema (hostname, kernel, uptime)
- Uso de recursos (CPU, memória, disco)
- Status de serviços críticos
- Updates disponíveis
- Logs de erro (últimas 24h)
- Conexões de rede
- Top processos
- Alertas de segurança

---

### 2. monitor-system.sh
**Monitoramento em tempo real**

```bash
./scripts/monitor-system.sh [intervalo_em_segundos]
```

**Exemplo:**
```bash
./scripts/monitor-system.sh 10  # Atualiza a cada 10 segundos
```

**Informações:**
- CPU em tempo real
- Memória
- Disco
- Rede
- Top processos

---

### 3. backup-configs.sh
**Backup de configurações importantes**

```bash
./scripts/backup-configs.sh [diretório_destino]
```

**Exemplo:**
```bash
./scripts/backup-configs.sh ~/backups/configs/
```

**O que faz backup:**
- Configurações do sistema (nginx, ssh, docker)
- Configurações do Hermes
- Configurações do Docker
- Crontab
- Lista de pacotes instalados

---

### 4. cleanup-system.sh
**Limpeza do sistema**

```bash
./scripts/cleanup-system.sh [--dry-run]
```

**Exemplo:**
```bash
./scripts/cleanup-system.sh --dry-run  # Mostra o que seria limpo
./scripts/cleanup-system.sh            # Executa a limpeza
```

**O que limpa:**
- Cache do apt
- Logs antigos
- Cache do Docker
- Cache do npm
- Cache do pip
- Arquivos temporários
- Pacotes órfãos

---

### 5. security-check.sh
**Verificação de segurança**

```bash
./scripts/security-check.sh
```

**O que verifica:**
- Atualizações de segurança pendentes
- Portas abertas
- Tentativas de login falhas
- Status de serviços críticos
- Permissões de arquivos sensíveis
- Status do firewall
- Versão do kernel
- Processos suspeitos

---

## Instalação dos Cron Jobs

Para instalar as automações automáticas:

```bash
# Copiar crontab
crontab cron-jobs/hermes-crontab

# Verificar se foi instalado
crontab -l
```

---

## Logs

Os logs são salvos em `~/.hermes/logs/`:

- `daily-briefing-YYYYMMDD.log` - Briefing matinal
- `monitor.log` - Monitoramento
- `backup.log` - Backup de configurações
- `cleanup.log` - Limpeza do sistema
- `security.log` - Verificação de segurança
- `update.log` - Atualizações do sistema
- `git-backup.log` - Backup do repositório
- `error-count.log` - Contagem de erros

---

## Uso com Hermes

Os scripts podem ser executados pelo Hermes:

```
"Execute o briefing matinal"
"Monitore o sistema em tempo real"
"Faça backup das configurações"
"Limpe o sistema"
"Verifique a segurança do sistema"
```

---

## Permissões

Todos os scripts já têm permissão de execução. Se precisar:

```bash
chmod +x scripts/*.sh
```
