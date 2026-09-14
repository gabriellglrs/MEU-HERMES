# MEU-HERMES

Configuração personalizada do [Hermes Agent](https://github.com/NousResearch/hermes-agent) com [OpenCode](https://opencode.ai/) integrado.

## O que está incluído

- `config.yaml` - Configurações otimizadas do Hermes
- `SOUL.md` - Personalidade completa (cybersegurança, programação, Linux)
- `skills/cybersecurity/` - 2,077 skills de cybersegurança
- `skills/software-development/gsd-core/` - Skill do GSD Core
- `scripts/` - Scripts de automação diária
- `cron-jobs/` - Configurações de automação
- `plugins/opencode/` - Plugin de integração com OpenCode
- `memory-backup/` - Backup da memória do agente

---

## 🚀 Instalação Completa

### Pré-requisitos

| Programa | Versão Mínima | Como verificar |
|----------|---------------|----------------|
| Python | 3.11+ | `python --version` |
| Node.js | 18+ | `node --version` |
| npm | 9+ | `npm --version` |
| Git | 2.0+ | `git --version` |

### Passo 1: Instalar Hermes Agent

```bash
# Instalar Hermes
curl -fsSL https://hermes.ai/install.sh | bash

# Verificar instalação
hermes --version
```

### Passo 2: Clonar esta configuração

```bash
cd ~
git clone https://github.com/gabriellglrs/MEU-HERMES.git
cd MEU-HERMES
```

### Passo 3: Executar instalação automática

```bash
# Instalar tudo automaticamente
./install.sh
```

Ou manualmente:

```bash
# Copiar configurações
cp config.yaml ~/.hermes/
cp SOUL.md ~/.hermes/

# Copiar skills de cybersegurança
cp -r skills/* ~/.hermes/skills/

# Copiar scripts de automação
mkdir -p ~/.hermes/scripts
cp scripts/* ~/.hermes/scripts/
chmod +x ~/.hermes/scripts/*.sh

# Copiar cron jobs
mkdir -p ~/.hermes/cron-jobs
cp cron-jobs/* ~/.hermes/cron-jobs/

# Copiar plugin opencode
mkdir -p ~/.hermes/plugins
cp -r plugins/opencode ~/.hermes/plugins/
```

### Passo 4: Configurar chaves de API

```bash
# Criar arquivo .env
nano ~/.hermes/.env
```

Adicione suas chaves:

```env
# OpenAI (ChatGPT)
OPENAI_API_KEY=sk-xxx

# Anthropic (Claude)
ANTHROPIC_API_KEY=sk-ant-xxx

# Google (Gemini)
GOOGLE_API_KEY=xxx

# OpenRouter (acesso a vários modelos)
OPENROUTER_API_KEY=sk-or-xxx

# Outras chaves conforme necessário
```

### Passo 5: Instalar OpenCode

```bash
# Instalar OpenCode CLI
npm install -g opencode-ai

# Verificar instalação
opencode --version

# Configurar autenticação (escolha um provedor)
opencode auth login
```

### Passo 6: Instalar Bun + OMO (agentes multi-agente)

```bash
# Instalar Bun runtime
curl -fsSL https://bun.sh/install | bash

# Recarregar terminal
source ~/.zshrc  # ou source ~/.bashrc

# Instalar OMO (oh-my-openagent)
~/.bun/bin/bunx oh-my-openagent install

# Verificar agentes disponíveis
opencode agent list
```

### Passo 7: Habilitar plugin OpenCode no Hermes

```bash
# Habilitar plugin
hermes plugins enable opencode

# Verificar plugins instalados
hermes plugins list
```

### Passo 8: Instalar Cron Jobs (Opcional)

```bash
# Instalar automações
crontab cron-jobs/hermes-crontab

# Verificar se foi instalado
crontab -l
```

### Passo 9: Reiniciar Hermes

```bash
# Iniciar Hermes
hermes
```

---

## 🛡️ Cybersegurança

### Ecossistema Completo

O MEU-HERMES inclui o **hermes-cybersec-lab** com:

- **2,077 skills** de cybersegurança
- **131+ ferramentas** de segurança
- **28 frameworks** (MITRE ATT&CK, OWASP, etc.)

### Domínios Cobertos

| Domínio | Skills |
|---------|--------|
| Malware Analysis & Reverse Engineering | 34 |
| Forensics & DFIR | 22 |
| Exploitation & Post-Exploitation | 40 |
| Threat Intelligence | 32 |
| Vulnerability Management | 22 |
| Cloud Security | 18 |
| Web Application Security | 30 |
| API Security | 22 |
| OSINT & Reconnaissance | 20 |

### Ferramentas Incluídas

- **Rede:** nmap, masscan, tcpdump, tshark, naabu, amass, subfinder
- **Exploitation:** metasploit, sqlmap, impacket, crackmapexec
- **Malware:** radare2, gdb, ghidra, yara, oletools
- **Web:** zaproxy, nikto, ffuf, dirsearch
- **Cloud:** scoutsuite, prowler, kube-hunter

### Exemplos de Uso

```
"Escaneie minha rede local e identifique dispositivos"
"Analise este malware: /tmp/samples/malware.exe"
"Pesquise CVEs recentes de SQL injection"
"Crie um relatório de vulnerabilidades"
```

---

## 💻 Programação

### Skills de Desenvolvimento

- **opencode-driven-development** - Delegar código ao opencode
- **systematic-debugging** - Debug sistemático
- **test-driven-development** - TDD
- **github** - Gestão de repos
- **codebase-inspection** - Inspeção de código
- **requesting-code-review** - Reviews

### Integração OpenCode

```bash
# Tarefa simples (fire-and-forget)
opencode(action="run", prompt="Criar script de backup")

# Tarefa complexa (multi-turn)
opencode(action="session", prompt="Implementar sistema de login")

# Usar agentes específicos
opencode(action="run", prompt="...", agent="hephaestus")
opencode(action="run", prompt="...", agent="prometheus")
```

### Exemplos de Uso

```
"Revise este script Python para vulnerabilidades"
"Implemente autenticação OAuth no meu projeto"
"Delegue para opencode: criar API REST em Go"
```

---

## 🛠️ GSD Core (Engenharia de Contexto)

O MEU-HERMES inclui suporte ao **GSD Core** para desenvolvimento orientado a especificações com engenharia de contexto avançada.

### O que é?

GSD Core é um framework que resolve **context rot** — a degradação de qualidade que se acumula quando a IA preenche sua janela de contexto. Ele executa trabalho pesado em subagentes com contexto limpo.

### Ciclo de Fases

1. **Discuss** — Capturar decisões antes do planejamento
2. **Plan** — Pesquisa e verifica se o plano cabe no contexto
3. **Execute** — Roda planos em paralelo com contexto limpo
4. **Verify** — Verifica o que foi construído
5. **Ship** — Cria PR e arquiva a fase

### Instalação

```bash
# O GSD Core já está instalado globalmente para OpenCode
# Para verificar:
ls -la ~/.config/opencode/skills/ | grep gsd

# Para reinstalar se necessário:
npx @opengsd/gsd-core@latest --opencode --global
```

### Comandos disponíveis

| Comando | Função |
|---------|--------|
| `/gsd-new-project` | Iniciar novo projeto greenfield |
| `/gsd-onboard` | Integrar repositório existente |
| `/gsd-health` | Verificar saúde do projeto |
| `/gsd-config` | Configurar GSD Core |
| `/gsd-discuss-phase` | Iniciar discussão de uma fase |
| `/gsd-execute-phase` | Executar uma fase |
| `/gsd-verify-phase` | Verificar uma fase concluída |
| `/gsd-complete-milestone` | Completar um milestone |

### Quando usar

- **Projetos grandes e complexos** — Muitas partes interdependentes
- **Contexto ficando grande** — Sessão ficando lenta
- **Qualidade consistente** — Resultados previsíveis
- **Teams** — Múltiplas pessoas no mesmo código
- **Código crítico** — Bugs com alto custo

### Exemplo de uso

```bash
# Para novo projeto
cd ~/projects
mkdir minha-api
cd minha-api
git init
opencode
# Dentro do OpenCode: /gsd-new-project

# Para projeto existente
cd ~/meu-repositorio
opencode
# Dentro do OpenCode: /gsd-onboard
```

### Estrutura de arquivos

```
meu-projeto/
├── STATE.md           # Estado atual do projeto
├── CONTEXT.md         # Contexto do projeto
├── .gsd/              # Diretório do GSD Core
│   └── phase/         # Fases em andamento
├── docs/              # Documentação
└── src/               # Código fonte
```

---

## 🖥️ Automação Linux

### Scripts Disponíveis

| Script | Função |
|--------|--------|
| `daily-briefing.sh` | Briefing matinal completo |
| `monitor-system.sh` | Monitoramento em tempo real |
| `backup-configs.sh` | Backup de configurações |
| `cleanup-system.sh` | Limpeza do sistema |
| `security-check.sh` | Verificação de segurança |

### Uso dos Scripts

```bash
# Briefing matinal
~/.hermes/scripts/daily-briefing.sh

# Monitoramento em tempo real
~/.hermes/scripts/monitor-system.sh 5

# Backup de configurações
~/.hermes/scripts/backup-configs.sh ~/backups/

# Limpeza do sistema
~/.hermes/scripts/cleanup-system.sh

# Verificação de segurança
~/.hermes/scripts/security-check.sh
```

### Cron Jobs Automáticos

| Horário | Tarefa |
|---------|--------|
| 08:00 diário | Briefing matinal |
| a cada 30min | Monitoramento de serviços |
| 02:00 diário | Backup de configurações |
| 03:00 domingo | Limpeza do sistema |
| 06:00 diário | Verificação de segurança |
| 04:00 terça | Atualização do sistema |
| 22:00 diário | Backup do repositório |

### Exemplos de Uso

```
"Execute o briefing matinal"
"Monitore o sistema em tempo real"
"Faça backup das configurações"
"Limpe o sistema"
"Verifique a segurança do sistema"
```

---

## 📚 Pesquisa & Estudos

### Web Search

O Hermes possui web search integrado para pesquisas:

```
"Pesquise últimos CVEs de SQL injection"
"Encontre papers recentes sobre IA em cybersegurança"
"Busque documentação sobre Docker security"
```

### Skills de Pesquisa

- **arxiv** - Buscar papers acadêmicos
- **grounded-citations** - Citações fundamentadas
- **llm-wiki** - Consulta wiki
- **research** - Pesquisa geral

---

## 🧠 Como Usar o OpenCode

### Tarefas Simples (fire-and-forget)

No Hermes, use a ferramenta `opencode`:

```
opencode(action="run", prompt="Criar um script de backup", directory="/home/user")
```

### Tarefas Complexas (multi-turn)

```
opencode(action="session", prompt="Implementar sistema de login", directory="/projeto")
```

### Usar agentes específicos

| Agente | Melhor Para | Como usar |
|--------|-------------|-----------|
| *(default)* | Maioria das tarefas | `opencode(action="run", prompt="...")` |
| `hephaestus` | Implementação profunda | `opencode(action="run", prompt="...", agent="hephaestus")` |
| `prometheus` | Planejamento estratégico | `opencode(action="run", prompt="...", agent="prometheus")` |
| `oracle` | Decisões de arquitetura | `opencode(action="run", prompt="...", agent="oracle")` |
| `atlas` | Execução com checklist | `opencode(action="run", prompt="...", agent="atlas")` |

### Ativar todos os agentes (ultrawork)

Inclua `ultrawork` ou `ulw` no prompt:

```
opencode(action="run", prompt="ulw Criar API REST completa para gerenciamento de tarefas")
```

### Comandos úteis do OpenCode

```bash
# Listar sessões anteriores
opencode session list

# Verificar uso de tokens
opencode stats

# Continuar última sessão
opencode -c

# Continuar sessão específica
opencode -c <session-id>
```

---

## 🔧 Comandos Úteis do Hermes

### Gerenciamento de plugins

```bash
# Listar plugins
hermes plugins list

# Habilitar plugin
hermes plugins enable <nome>

# Desabilitar plugin
hermes plugins disable <nome>
```

### Gerenciamento de skills

```bash
# Listar skills instaladas
hermes skills list

# Instalar skill do hub
hermes skills install <nome>

# Buscar skills
hermes skills search <termo>
```

### Backup e restauração

```bash
# Criar backup completo
hermes backup -o ~/hermes-backup.zip

# Criar backup rápido (só configuração)
hermes backup --quick -l "meu-backup"

# Exportar sessões
hermes sessions export --format jsonl sessions.jsonl

# Importar sessões
hermes sessions import sessions.jsonl
```

### MCP (Model Context Protocol)

```bash
# Adicionar servidor MCP
hermes mcp add github --preset github

# Listar servidores MCP
hermes mcp list

# Testar servidor MCP
hermes mcp test github
```

### Configuração

```bash
# Ver configuração atual
hermes config show

# Editar configuração
hermes config edit

# Verificar status do sistema
hermes status
```

---

## 📦 Backup da Memória

### Criar backup

```bash
cd ~/MEU-HERMES
./backup-memory.sh
```

Isso cria:
- `memory-backup/sessions_*.jsonl` - Histórico de conversas
- `memory-backup/SOUL.md` - Personalidade do agente
- `memory-backup/MEMORY.md` - Memórias de longo prazo
- `memory-backup/USER.md` - Perfil do usuário
- `memory-backup/config.yaml` - Configurações
- `memory-backup/skills/` - Skills criadas

### Enviar ao GitHub

```bash
cd ~/MEU-HERMES
git add memory-backup/
git commit -m "backup: memória $(date +%Y-%m-%d)"
git push
```

### Restaurar em outro computador

```bash
cd ~/MEU-HERMES
./restore-memory.sh
```

---

## 🔄 Atualizando

### Após fazer alterações no Hermes

```bash
cd ~/MEU-HERMES

# Copiar alterações para o repositório
cp ~/.hermes/config.yaml .
cp ~/.hermes/SOUL.md .

# Criar backup da memória
./backup-memory.sh

# Enviar ao GitHub
git add .
git commit -m "update: descrição da alteração"
git push
```

### Após atualizar o Hermes

```bash
# Atualizar Hermes
hermes update

# Verificar versão
hermes --version

# Reconfigurar se necessário
hermes config edit
```

---

## 🛠️ Solução de Problemas

### OpenCode não é encontrado

```bash
# Verificar se está instalado
which opencode

# Reinstalar
npm install -g opencode-ai

# Verificar PATH
echo $PATH
```

### Plugin opencode não aparece

```bash
# Verificar se está habilitado
hermes plugins list | grep opencode

# Habilitar novamente
hermes plugins enable opencode

# Reiniciar Hermes
hermes
```

### Erros de autenticação

```bash
# Verificar chaves configuradas
cat ~/.hermes/.env

# Reconfigurar OpenCode
opencode auth login

# Verificar provedores disponíveis
opencode auth list
```

### Hermes não inicia

```bash
# Verificar logs
hermes logs

# Executar diagnóstico
hermes doctor

# Reinstalar se necessário
curl -fsSL https://hermes.ai/install.sh | bash
```

### Scripts não executam

```bash
# Verificar permissões
ls -la ~/.hermes/scripts/

# Dar permissão de execução
chmod +x ~/.hermes/scripts/*.sh
```

---

## 📁 Estrutura do Repositório

```
MEU-HERMES/
├── .gitignore              # Arquivos excluídos do versionamento
├── README.md               # Este arquivo
├── config.yaml             # Configurações otimizadas do Hermes
├── SOUL.md                 # Personalidade completa do agente
├── install.sh              # Script de instalação rápida
├── backup-memory.sh        # Script de backup da memória
├── restore-memory.sh       # Script de restauração
├── skills/                 # Skills instaladas
│   └── cybersecurity/      # 2,077 skills de cybersegurança
├── scripts/                # Scripts de automação
│   ├── daily-briefing.sh   # Briefing matinal
│   ├── monitor-system.sh   # Monitoramento
│   ├── backup-configs.sh   # Backup de configs
│   ├── cleanup-system.sh   # Limpeza do sistema
│   ├── security-check.sh   # Verificação de segurança
│   └── README.md           # Documentação dos scripts
├── cron-jobs/              # Configurações de automação
│   └── hermes-crontab      # Cron jobs automáticos
├── memory-backup/          # Backup da memória
│   ├── SOUL.md
│   ├── config.yaml
│   ├── sessions_*.jsonl
│   ├── skills/
│   └── metadata.json
└── plugins/                # Plugins
    └── opencode/           # Plugin OpenCode
```

---

## 🔒 Segurança

### ⚠️ Arquivos NÃO versionados (dados sensíveis):

| Arquivo | Conteúdo |
|---------|----------|
| `.env` | Chaves de API |
| `auth.json` | Tokens de autenticação |
| `state.db` | Banco de dados de sessões |
| `sessions/` | Histórico de conversas |
| `memories/` | Memórias do agente |

### ✅ Seguro para versionar:

| Arquivo | Conteúdo |
|---------|----------|
| `config.yaml` | Configurações (sem chaves) |
| `SOUL.md` | Personalidade do agente |
| `skills/` | Skills instaladas |
| `plugins/` | Plugins instalados |
| `scripts/` | Scripts de automação |
| `cron-jobs/` | Configurações de automação |
| `memory-backup/` | Backup da memória |

---

## 🌐 Links Úteis

- [Hermes Agent - Documentação](https://hermes.ai/docs)
- [Hermes Agent - GitHub](https://github.com/NousResearch/hermes-agent)
- [OpenCode - Site](https://opencode.ai)
- [OpenCode - GitHub](https://github.com/sst/opencode)
- [oh-my-openagent (OMO)](https://github.com/code-yeongyu/oh-my-openagent)
- [hermes-cybersec-lab](https://github.com/handnewb/hermes-cybersec-lab)
- [Hermes Discord](https://discord.gg/hermes)
- [OpenCode Discord](https://discord.gg/opencode)

---

## 📝 Licença

MIT
