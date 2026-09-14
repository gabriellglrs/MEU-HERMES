# MEU-HERMES

Configuração personalizada do [Hermes Agent](https://github.com/NousResearch/hermes-agent) com [OpenCode](https://opencode.ai/) integrado.

## O que está incluído

- `config.yaml` - Configurações do Hermes
- `SOUL.md` - Personalidade do agente
- `skills/` - Skills instaladas e criadas
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

### Passo 3: Restaurar configuração e memória

```bash
# Restaurar tudo (configuração + memória + skills)
./restore-memory.sh
```

Ou manualmente:

```bash
# Copiar configurações
cp config.yaml ~/.hermes/
cp SOUL.md ~/.hermes/

# Copiar skills
cp -r skills/* ~/.hermes/skills/

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

### Passo 8: Reiniciar Hermes

```bash
# Iniciar Hermes
hermes
```

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

---

## 📁 Estrutura do Repositório

```
MEU-HERMES/
├── .gitignore              # Arquivos excluídos do versionamento
├── README.md               # Este arquivo
├── config.yaml             # Configurações do Hermes
├── SOUL.md                 # Personalidade do agente
├── install.sh              # Script de instalação rápida
├── backup-memory.sh        # Script de backup da memória
├── restore-memory.sh       # Script de restauração
├── memory-backup/          # Backup da memória
│   ├── SOUL.md
│   ├── config.yaml
│   ├── sessions_*.jsonl
│   ├── skills/
│   └── metadata.json
├── skills/                 # Skills instaladas
│   ├── autonomous-ai-agents/
│   ├── creative/
│   ├── devops/
│   ├── email/
│   ├── media/
│   ├── productivity/
│   ├── research/
│   ├── software-development/
│   └── web/
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
| `memory-backup/` | Backup da memória |

---

## 🌐 Links Úteis

- [Hermes Agent - Documentação](https://hermes.ai/docs)
- [Hermes Agent - GitHub](https://github.com/NousResearch/hermes-agent)
- [OpenCode - Site](https://opencode.ai)
- [OpenCode - GitHub](https://github.com/sst/opencode)
- [oh-my-openagent (OMO)](https://github.com/code-yeongyu/oh-my-openagent)
- [Hermes Discord](https://discord.gg/hermes)
- [OpenCode Discord](https://discord.gg/opencode)

---

## 📝 Licença

MIT
