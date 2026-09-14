# MEU-HERMES

Configuração personalizada do [Hermes Agent](https://github.com/NousResearch/hermes-agent) com plugins e skills.

## O que está incluído

- `config.yaml` - Configurações do Hermes
- `SOUL.md` - Personalidade do agente
- `skills/` - Skills instaladas e criadas
- `plugins/opencode/` - Plugin de integração com OpenCode

## Instalação Rápida

### Pré-requisitos

- Python 3.11+
- Node.js 18+
- Bun (opcional, para OMO)

### 1. Instalar Hermes

```bash
curl -fsSL https://hermes.ai/install.sh | bash
```

### 2. Clonar esta configuração

```bash
cd ~
git clone https://github.com/gabriellglrs/MEU-HERMES.git
cd MEU-HERMES
```

### 3. Copiar configurações

```bash
# Backup da configuração atual (se existir)
mv ~/.hermes/config.yaml ~/.hermes/config.yaml.bak 2>/dev/null

# Copiar nova configuração
cp config.yaml ~/.hermes/
cp SOUL.md ~/.hermes/

# Copiar skills
cp -r skills/* ~/.hermes/skills/

# Copiar plugin opencode
mkdir -p ~/.hermes/plugins
cp -r plugins/opencode ~/.hermes/plugins/
```

### 4. Configurar variáveis de ambiente

```bash
# Criar arquivo .env com suas chaves de API
nano ~/.hermes/.env
```

Adicione suas chaves:
```
OPENAI_API_KEY=sua-chave-aqui
ANTHROPIC_API_KEY=sua-chave-aqui
# Outras chaves conforme necessário
```

### 5. Instalar OpenCode + OMO (opcional)

```bash
# Instalar OpenCode
npm install -g opencode-ai

# Instalar Bun
curl -fsSL https://bun.sh/install | bash

# Instalar OMO (agentes multi-agente)
~/.bun/bin/bunx oh-my-openagent install

# Habilitar plugin opencode no Hermes
hermes plugins enable opencode
```

### 6. Reiniciar Hermes

```bash
hermes
```

## Backup da Memória (IMPORTANTE!)

Para não perder a memória e histórico do seu agente:

### Criar backup da memória

```bash
cd ~/MEU-HERMES
./backup-memory.sh
```

Isso cria:
- `memory-backup/sessions_*.jsonl` - Histórico de conversas (redacted)
- `memory-backup/SOUL.md` - Personalidade do agente
- `memory-backup/MEMORY.md` - Memórias de longo prazo
- `memory-backup/USER.md` - Perfil do usuário
- `memory-backup/config.yaml` - Configurações
- `memory-backup/skills/` - Skills criadas
- `memory-backup/metadata.json` - Informações do backup

### Enviar backup ao GitHub

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

## Atualizando

Após fazer alterações nas configurações:

```bash
cd ~/MEU-HERMES

# Copiar alterações para o Hermes
cp config.yaml ~/.hermes/
cp SOUL.md ~/.hermes/
cp -r skills/* ~/.hermes/skills/

# Criar backup da memória (opcional, mas recomendado)
./backup-memory.sh

# Commit e push
git add .
git commit -m "update: descrição da alteração"
git push
```

## Restaurando em outro computador

```bash
# Clonar repositório
git clone https://github.com/gabriellglrs/MEU-HERMES.git
cd MEU-HERMES

# Executar script de instalação
bash install.sh
```

## Estrutura

```
MEU-HERMES/
├── .gitignore          # Arquivos excluídos do versionamento
├── README.md           # Este arquivo
├── config.yaml         # Configurações do Hermes
├── SOUL.md             # Personalidade do agente
├── install.sh          # Script de instalação
├── skills/             # Skills instaladas
│   ├── autonomous-ai-agents/
│   ├── creative/
│   ├── devops/
│   └── ...
└── plugins/            # Plugins
    └── opencode/       # Plugin OpenCode
```

## Segurança

⚠️ **Arquivos NÃO versionados** (contêm dados sensíveis):

- `.env` - Chaves de API
- `auth.json` - Tokens de autenticação
- `state.db` - Banco de dados de sessões
- `sessions/` - Histórico de conversas
- `memories/` - Memórias do agente

Estes arquivos ficam apenas no seu computador local.

## Licença

MIT
