# MEU-HERMES

Configuração personalizada do [Hermes Agent](https://github.com/NousResearch/hermes-agent) com [OpenCode](https://opencode.ai/) integrado.

## O que está incluído

- `config.yaml` - Configurações otimizadas do Hermes
- `SOUL.md` - Personalidade completa (cybersegurança, programação, Linux)
- `skills/cybersecurity/` - 2,077 skills de cybersegurança
- `skills/nousresearch/` - 14 skills do ecossistema NousResearch
- `skills/obra/` - Skills de workflow (using-superpowers)
- `skills/software-development/gsd-core/` - Skill do GSD Core
- `skills/rtk/` - RTK Token Killer (economia de tokens)
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
| Rust | latest | `rustc --version` (para RTK) |

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

# Copiar skills
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

# Honcho (memória cross-session)
HONCHO_API_KEY=xxx

# 1Password (gerenciamento de secrets)
OP_SERVICE_ACCOUNT_TOKEN=xxx

# Microsoft Graph (Teams meetings)
MSGRAPH_TENANT_ID=xxx
MSGRAPH_CLIENT_ID=xxx
MSGRAPH_CLIENT_SECRET=xxx

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

### Passo 8: Instalar RTK (opcional - economia de tokens)

```bash
# Windows
winget install rtk-ai.rtk

# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

# Verificar
rtk --version

# Ativar hook global (opcional)
rtk init -g --agent hermes
```

### Passo 9: Configurar Honcho (memória)

```bash
# Configurar Honcho
hermes memory setup honcho
# Escolher "cloud" ou "local" e seguir o wizard
```

### Passo 10: Instalar Cron Jobs (Opcional)

```bash
# Instalar automações
crontab cron-jobs/hermes-crontab

# Verificar se foi instalado
crontab -l
```

### Passo 11: Reiniciar Hermes

```bash
# Iniciar Hermes
hermes
```

---

## 🧠 Skills Instaladas

### Visão Geral

| Categoria | Skills | Descrição |
|-----------|--------|-----------|
| **Cybersecurity Lab** | 2,077 | Análise de malware, forense, pentesting, ameaças |
| **NousResearch** | 14 | Workflow, debug, APIs, memória, email, vídeo |
| **Obra** | 1 | Ativação sob demanda de skills |
| **Software Development** | 1 | Engenharia de contexto (GSD Core) |
| **RTK** | 1 | Economia de tokens (60-90%) |
| **Total** | **2,094** | |

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
| AI/LLM Security | 20 |
| API Security | 10 |
| Cloud Security Advanced | 8 |
| CVE 2015-2017 | 30 |
| CVE 2018-2020 | 30 |
| CVE 2021-2023 | 30 |
| CVE 2024-2025 | 30 |
| CVE Driven 2026 | 15 |
| Incident Response | 8 |
| Mobile Security | 20 |
| OSINT | 20 |
| OT/ICS/SCADA | 25 |
| Threat Hunting | 8 |
| Web App Security | 16 |

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

## 🔧 Skills NousResearch (Novas)

### 🧠 Honcho - Memória Cross-Session

O Honcho permite que o Hermes **lembre de você entre conversas**.

**O que faz:**
- Aprende quem você é ao longo das sessões
- Mantém preferências e padrões
- Cada profile do Hermes tem sua própria identidade
- Observação bidirecional (usuário e AI)

**Ativação:**
```bash
hermes memory setup honcho
```

**Exemplo:**
```
Sessão 1: "Prefiro código em Go" → Honcho salva
Sessão 2: "Qual linguagem usar?" → Hermes já sabe que você prefere Go
```

---

### 🔐 1Password - Gerenciamento de Secrets

Gerenciamento seguro de senhas e chaves via CLI.

**Comandos:**
```bash
op read "op://Vault/Item/field"    # Ler secret
op inject -i config.tpl.yml       # Injetar em template
op run -- sh -c '$DB_PASSWORD'    # Rodar com secrets
```

---

### 📚 LLM Wiki - Knowledge Base

Sistema de wiki interligado baseado no padrão do Karpathy.

**O que faz:**
- Constrói base de conhecimento persistente em markdown
- Cross-references automáticas
- Deteção de contradições
- Compatível com Obsidian

**Uso:**
```
"Crie uma wiki sobre machine learning"
"Adicione este artigo à wiki"
"Consulte a wiki sobre transformers"
```

---

### 🔍 REST/GraphQL Debug

Debug de APIs REST e GraphQL com diagnóstico em camadas.

**Fluxo:**
1. Conectividade → 2. TLS → 3. Auth → 4. Request → 5. Response → 6. Semântica

**Comandos:**
```bash
rtk curl -v https://api.example.com/users
rtk git status  # (com RTK ativo)
```

---

### 📧 Himalaya - Email CLI

Gerenciamento de email via terminal (IMAP/SMTP).

**Comandos:**
```bash
himalaya envelope list           # Listar emails
himalaya message read 42         # Ler email
himalaya template send           # Enviar email
```

**Configuração:**
```bash
himalaya account configure
```

---

### ✅ Requesting Code Review

Verificação pré-commit com scan de segurança e auto-fix.

**Pipeline:**
1. Get diff → 2. Security scan → 3. Tests/lint → 4. Self-review → 5. Reviewer subagent → 6. Auto-fix

**Uso:**
```
"Revise este código antes de commitar"
"Verifique segurança do PR"
```

---

### 🤖 Codex - Delegação de Código

Delegar tarefas de código para o OpenAI Codex CLI.

**Comandos:**
```bash
codex exec "Add dark mode toggle"
codex exec --full-auto "Refactor auth module"
```

---

### 📹 Teams Meeting Pipeline

Pipeline de resumos de reuniões do Microsoft Teams.

**Comandos:**
```bash
hermes teams-pipeline list               # Reuniões recentes
hermes teams-pipeline show <job-id>      # Detalhes
hermes teams-pipeline run <job-id>       # Re-processar
hermes teams-pipeline validate           # Verificar config
```

---

### ⚡ RTK - Rust Token Killer

Reduz **60-90% do consumo de tokens** comprimindo saída de comandos.

**Comandos principais:**
```bash
rtk git status      # Compacto (15 linhas → 1)
rtk cargo test      # Só falhas
rtk docker ps       # Resumido
rtk gain            # Dashboard de economia
rtk discover        # Encontrar oportunidades
```

**Economia atual:** 33.5% (869 comandos analisados)

---

### 🔍 Systematic Debugging

Debug sistemático em 4 fases:
1. **Causa Raiz** → 2. **Padrão** → 3. **Hipótese** → 4. **Implementação**

**Regra de ouro:** NENHUM fix sem investigação de causa raiz primeiro.

---

### 📋 Kanban Orchestrator/Worker

Sistema multi-agente para decomposição e execução de tarefas.

**Padrões:**
- Fan-out + fan-in (pesquisa → síntese)
- Pipeline com gates (planner → implementer → reviewer)
- Human-in-the-loop

---

### 🎬 Spike

Protótipos descartáveis para validar ideias antes de construir.

**Ciclo:**
```
decompose → research → build → verdict
```

---

### 📺 YouTube Content

Transforma transcrições YouTube em resumos, threads, blog posts.

**Uso:**
```
"Resuma este vídeo: https://youtube.com/watch?v=..."
"Crie um thread sobre este vídeo"
```

---

## 💻 Programação

### Skills de Desenvolvimento

- **gsd-core** - Engenharia de contexto para projetos complexos
- **systematic-debugging** - Debug sistemático em 4 fases
- **requesting-code-review** - Verificação pré-commit
- **codex** - Delegação de código ao OpenAI Codex
- **rest-graphql-debug** - Debug de APIs

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

---

## 🛠️ GSD Core (Engenharia de Contexto)

O MEU-HERMES inclui suporte ao **GSD Core** para desenvolvimento orientado a especificações.

### Ciclo de Fases

1. **Discuss** — Capturar decisões antes do planejamento
2. **Plan** — Pesquisa e verifica se o plano cabe no contexto
3. **Execute** — Roda planos em paralelo com contexto limpo
4. **Verify** — Verifica o que foi construído
5. **Ship** — Cria PR e arquiva a fase

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

---

## 📚 Pesquisa & Estudos

### Web Search

```
"Pesquise últimos CVEs de SQL injection"
"Encontre papers recentes sobre IA em cybersegurança"
"Busque documentação sobre Docker security"
```

### Skills de Pesquisa

- **llm-wiki** - Knowledge base interligada
- **youtube-content** - Resumos de vídeos
- **arxiv** - Papers acadêmicos

---

## 🧠 Como Usar o OpenCode

### Tarefas Simples (fire-and-forget)

```
opencode(action="run", prompt="Criar um script de backup", directory="/home/user")
```

### Tarefas Complexas (multi-turn)

```
opencode(action="session", prompt="Implementar sistema de login", directory="/projeto")
```

### Agentes Disponíveis

| Agente | Melhor Para |
|--------|-------------|
| *(default)* | Maioria das tarefas |
| `hephaestus` | Implementação profunda |
| `prometheus` | Planejamento estratégico |
| `oracle` | Decisões de arquitetura |
| `atlas` | Execução com checklist |

---

## 🔧 Comandos Úteis do Hermes

### Gerenciamento de Skills

```bash
# Listar skills instaladas
hermes skills list

# Instalar skill do hub
hermes skills install <nome>

# Buscar skills
hermes skills search <termo>
```

### Gerenciamento de Memória

```bash
# Configurar Honcho
hermes memory setup honcho

# Verificar status
hermes honcho status

# Sincronizar profiles
hermes honcho sync
```

### RTK (Economia de Tokens)

```bash
# Ver economia
rtk gain

# Descobrir oportunidades
rtk discover

# Comandos comprimidos
rtk git status
rtk cargo test
rtk docker ps
```

### Backup e Restauração

```bash
# Criar backup completo
hermes backup -o ~/hermes-backup.zip

# Criar backup rápido
hermes backup --quick -l "meu-backup"
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
cp -r ~/.hermes/skills/* skills/

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

### RTK não encontrado

```bash
# Verificar PATH
rtk --version

# Reinstalar
winget install rtk-ai.rtk  # Windows
```

### Honcho não funciona

```bash
# Verificar status
hermes honcho status

# Reconfigurar
hermes memory setup honcho
```

### OpenCode não é encontrado

```bash
# Verificar se está instalado
which opencode

# Reinstalar
npm install -g opencode-ai
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
├── honcho.json             # Configuração do Honcho (memória cross-session)
├── rtk-config.toml         # Configuração do RTK (economia de tokens)
├── install.sh              # Script de instalação rápida
├── backup-memory.sh        # Script de backup da memória
├── restore-memory.sh       # Script de restauração
├── skills/                 # Skills instaladas
│   ├── cybersecurity/      # 2,077 skills de cybersegurança
│   ├── nousresearch/       # 14 skills NousResearch
│   ├── obra/               # Skills de workflow
│   ├── software-development/  # GSD Core
│   └── rtk/                # RTK Token Killer
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
| `honcho.json` | Configuração do Honcho (API key incluída) |
| `rtk-config.toml` | Configuração do RTK |
| `skills/` | Skills instaladas |
| `plugins/` | Plugins instalados |
| `scripts/` | Scripts de automação |
| `cron-jobs/` | Configurações de automação |
| `memory-backup/` | Backup da memória |

---

## 🌐 Links Úteis

### Hermes Agent
- [Documentação](https://hermes.ai/docs)
- [GitHub](https://github.com/NousResearch/hermes-agent)
- [Discord](https://discord.gg/hermes)
- [Skills Hub](https://agentskill.sh/for/hermes)

### Ferramentas
- [OpenCode](https://opencode.ai)
- [GSD Core](https://github.com/open-gsd/gsd-core)
- [RTK](https://github.com/rtk-ai/rtk)
- [Honcho](https://docs.honcho.dev)
- [Himalaya](https://github.com/pimalaya/himalaya)

### Ecossistema
- [oh-my-openagent (OMO)](https://github.com/code-yeongyu/oh-my-openagent)
- [hermes-cybersec-lab](https://github.com/handnewb/hermes-cybersec-lab)
- [NousResearch](https://nousresearch.com)

---

## 📊 Estatísticas

| Métrica | Valor |
|---------|-------|
| Total de skills | 2,094 |
| Skills de segurança | 2,077 |
| Skills de workflow | 16 |
| Economia RTK | 33.5% |
| Comandos analisados | 869 |

---

## 📝 Licença

MIT
