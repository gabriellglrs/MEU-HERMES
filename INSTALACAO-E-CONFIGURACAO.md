# Instalação e Configuração — Time de Dev com IA

**Plataforma:** Ubuntu 22 LTS / Windows  
**Status:** ✅ CONCLUÍDO (com ressalva GPU no Linux)

---

## Pré-requisitos do Sistema

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl xz-utils build-essential
```

---

## 1. Instalação do Hermes Agent

### Comando
```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

### O que o instalador faz automaticamente
| Etapa | Descrição |
|---|---|
| 1 | Detecta SO e shell |
| 2 | Instala `uv` (gerenciador de pacotes Python) |
| 3 | Instala Python 3.11+ via `uv` |
| 4 | Instala Node.js |
| 5 | Clona repositório em `~/.hermes/hermes-agent/` |
| 6 | Cria virtualenv e instala dependências |
| 7 | Cria symlink `hermes` em `~/.local/bin/` |
| 8 | Atualiza `~/.bashrc` com PATH |

### Pós-instalação
```bash
source ~/.bashrc
hermes --version
hermes setup
```

### Configuração do `hermes setup`
O wizard pergunta:
- **LLM Provider:** OpenRouter, Anthropic, OpenAI, Ollama (local), etc.
- **API Key:** chave do provider escolhido
- **Modelo:** deve suportar pelo menos 64k tokens de contexto
- **Ferramentas:** terminal, arquivos, web search, memória
- **Perfil:** nome do perfil (útil se rodar múltiplos)

---

## 2. Configuração da Integração Hermes ↔ Linear

### Método 1: Via prompt no Hermes (recomendado)
```
Conecta o meu Hermes no Linear. Primeiro, registra o MCP do Linear no Hermes
e confirma que as tools apareceram. Depois cria um time chamado "Projetos" e
um projeto chamado "Loja — Checkout". Cria uma tarefa de teste chamada
"Verificar conexão" com prioridade alta. Me mostra o link da tarefa e o
resultado de cada passo.
```

### Método 2: Via comando
```bash
hermes mcp add linear
```

### O que precisa para funcionar
- Conta ativa no [linear.app](https://linear.app)
- API key do Linear (gerada em Settings → Account → Security)
- O Hermes registra o MCP (Model Context Protocol) e passa a enxergar seus boards

### Configuração manual (se necessário)
| Campo | Valor |
|---|---|
| Endpoint | `https://api.linear.app/graphql` |
| Auth | Bearer token (API key do Linear) |

---

## 3. Instalação do Orca

### Método 1: AppImage (recomendado para desktop)
```bash
# Criar diretório
sudo mkdir -p /opt/orca

# Baixar AppImage
sudo curl -L https://github.com/stablyai/orca/releases/latest/download/orca-linux.AppImage \
  -o /opt/orca/orca-linux.AppImage

# Tornar executável
sudo chmod +x /opt/orca/orca-linux.AppImage

# Extrair (sem FUSE, mais estável)
cd /opt/orca
sudo ./orca-linux.AppImage --appimage-extract
sudo chmod -R a+rX /opt/orca/squashfs-root
```

### Executar Orca
```bash
# Desktop
/opt/orca/squashfs-root/AppRun

# Headless (servidor VPS)
/opt/orca/squashfs-root/AppRun serve --port 6768
```

### Método 2: .deb (se disponível)
```bash
# Baixar .deb do release
wget https://github.com/stablyai/orca/releases/latest/download/orca-linux.deb
sudo dpkg -i orca-linux.deb
```

### Pré-requisitos do Orca (Ubuntu 22 LTS)
```bash
sudo apt-get install -y \
  curl file jq xvfb zlib1g-dev ca-certificates git \
  libgtk-3-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 libgbm1 libasound2 \
  libxtst6 libcups2 libdrm2 libxkbcommon0 libpango-1.0-0 libcairo2 libatspi2.0-0 \
  libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libxrender1 libx11-xcb1 \
  libxcb-dri3-0 libxss1 libfuse2
```

### CLI do Orca
No Linux o comando é `orca-ide` (evita conflito com GNOME Orca screen reader):
```bash
# Verificar status
orca-ide status --json

# Verificar worktrees
orca-ide worktree ps --json
```

---

## 4. Integração Linear ↔ Orca

### Método 1: Via prompt no Hermes
```
Conecta o Linear no Orca. Confere se o app do Orca está rodando e registra o
meu repositório principal nele. Se o Orca tiver integração com o Linear,
ativa ela. Me diz o que foi feito e o que falta pra eu fazer na mão.
```

### Método 2: Manual (2 cliques)
1. Abra o Orca → Configurações → Integrações
2. Procure Linear → **Conectar**
3. Autorize na janela OAuth

---

## 5. Instalação da Skill "Time de Dev com IA"

### Copiar skill para o diretório correto
```bash
mkdir -p ~/.config/hermes/skills/time-de-dev-ia
cp /home/gabriel/time-dev-ia/SKILL-TIME-DEV-IA.md \
   ~/.config/hermes/skills/time-de-dev-ia/SKILL.md
```

### O que a skill ensina ao Hermes
| Capacidade | Descrição |
|---|---|
| Os 3 papéis | Você = dono · Hermes = gerente · Linear = mural · Orca = braço |
| Fluxo padrão | tarefa → Linear → Orca → PR → review → merge → fechar task |
| Prompt em 5 blocos | TAREFA, CONTEXTO, FRONTEIRAS, REGRAS, ENTREGA |
| Regras de ouro | paralelismo por arquivo, deploy do dono, segredos nunca |

---

## 6. Fluxo de Trabalho Completo

```
┌─────────────────────────────────────────────────────────────┐
│                        SEU COMPUTADOR                        │
│                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐               │
│  │  VOCÊ     │───▶│  HERMES  │───▶│  LINEAR  │               │
│  │  (dono)   │◀───│ (gerente)│◀───│ (mural)  │               │
│  └──────────┘    └────┬─────┘    └──────────┘               │
│                       │                                      │
│                       │ entrega comando                      │
│                       ▼                                      │
│                  ┌──────────┐                                │
│                  │  ORCA    │                                │
│                  │ (braço)  │                                │
│                  └────┬─────┘                                │
│                       │                                      │
│                       │ cria branch + PR                     │
│                       ▼                                      │
│                  ┌──────────┐                                │
│                  │  GITHUB  │                                │
│                  │   (PR)   │                                │
│                  └────┬─────┘                                │
│                       │                                      │
│                       │ você revisa                          │
│                       ▼                                      │
│                  ┌──────────┐                                │
│                  │  MERGE   │───▶ fecha tarefa no Linear     │
│                  └──────────┘                                │
└─────────────────────────────────────────────────────────────┘
```

### Passo a passo do ciclo
| # | Quem | O que faz | Comando/Ação |
|---|---|---|---|
| 1 | Você | Descreve o que quer | Prompt de kickoff no Hermes |
| 2 | Hermes | Cria tarefas no Linear | Via MCP automático |
| 3 | Hermes | Entrega comando Orca pronto | `orca worktree create --repo ...` |
| 4 | Orca | Coda, testa e abre PR | Executa agente com prompt |
| 5 | Você | Revisa o PR | `gh pr view <n>` e `gh pr diff <n>` |
| 6 | Você | Verifica checks | `gh pr checks <n> --watch` |
| 7 | Você | Merges | `gh pr merge <n> --squash --delete-branch` |
| 8 | Linear | Fecha tarefa | Via MCP automático |

---

## 7. Comandos de Verificação (pós-instalação)

```bash
# Verificar Hermes
hermes --version
hermes doctor

# Verificar Linear (via Hermes)
hermes mcp list

# Verificar Orca
orca-ide status --json

# Verificar GitHub CLI (para PRs)
gh --version
gh auth status

# Verificar skill instalada
ls -la ~/.config/hermes/skills/time-de-dev-ia/
```

---

## 8. Estrutura de Diretórios Final

```
~/
├── .hermes/
│   ├── hermes-agent/        # código fonte + venv
│   ├── config.yaml          # configuração principal
│   ├── .env                 # API keys
│   ├── memories/            # memória do agente
│   └── skills/              # skills instaladas
│       └── time-de-dev-ia/
│           └── SKILL.md
├── .local/bin/
│   └── hermes               # CLI wrapper
├── .config/hermes/
│   └── skills/
│       └── time-de-dev-ia/
│           └── SKILL.md
└── time-dev-ia/             # seus documentos
    ├── README.md
    ├── readme 2.md
    ├── SKILL-TIME-DEV-IA.md
    └── INSTALACAO-E-CONFIGURACAO.md  ← este arquivo
```

---

## 9. Checklist de Instalação

| # | Item | Status |
|---|---|---|
| 1 | `git` instalado | ✅ v2.34.1 |
| 2 | `curl` instalado | ✅ v7.81.0 |
| 3 | `xz-utils` instalado | ✅ v5.2.5 |
| 4 | `build-essential` instalado | ✅ v12.9 |
| 5 | Hermes instalado (`hermes --version`) | ✅ v0.21.2 |
| 6 | Hermes configurado (`hermes setup`) | ✅ Configurado |
| 7 | Linear conectado (MCP registrado) | ✅ 66 tools |
| 8 | Linear: tarefa de teste criada | ✅ GAB-5 |
| 9 | Orca instalado (`orca-ide status`) | ✅ AppImage |
| 10 | Orca conectado ao Linear | ⬜ Pendente (GPU issue) |
| 11 | Skill instalada em `~/.config/hermes/skills/` | ✅ Instalada |
| 12 | GitHub CLI autenticado (`gh auth status`) | ✅ gabriellglrs |
| 13 | Teste de fluxo completo (task → PR → merge) | ⬜ Pendente |

---

## 10. Nota: Problema GPU no Linux

O Orca tem issue com GPU no Ubuntu 22 LTS quando a placa é NVIDIA antiga (GT 740).
O processo abre mas fecha em seguida devido ao crash do GPU process.

**Solução:** Usar no Windows (sem esse problema) ou instalar drivers NVIDIA proprietary.

---

*Documento gerado em: 2026-09-15*  
*Autor: assistente via opencode*
