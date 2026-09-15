# Auditoria e Planejamento — Time de Dev com IA

**Objetivo:** Documentar o que será feito, como funcionará e o que esperar  
**Status:** Aguardando aprovação  
**Data:** $(date +%Y-%m-%d)

---

## 1. O que vou fazer (resumo executivo)

Vou configurar no seu Ubuntu 22 LTS um sistema de desenvolvimento com IA onde:

- **Hermes** será seu gerente de projeto (já instalado ✅)
- **Linear** será o mural de tarefas (será conectado via MCP)
- **Orca** será o executor de código (será instalado)
- Uma **skill personalizada** ensinará o Hermes a orquestrar tudo

---

## 2. Fases de Execução

### Fase 1: Verificação do Sistema (5 min)
**O que:** Confirmar que o ambiente está pronto

| Verificação | Comando esperado |
|---|---|
| Ubuntu version | `lsb_release -a` → 22.04 LTS |
| Git | `git --version` |
| Curl | `curl --version` |
| Hermes | `hermes --version` |

**Risco:** Baixo — apenas leitura

---

### Fase 2: Instalação do Orca (10 min)
**O que:** Baixar e configurar o Orca no sistema

**Ações:**
1. Instalar dependências do sistema (libgtk, libnss3, etc.)
2. Baixar AppImage do Orca
3. Extrair para `/opt/orca/`
4. Verificar que `orca-ide` responde

**Comandos que vou executar:**
```bash
sudo apt-get install -y [dependências do Orca]
sudo curl -L [AppImage] -o /opt/orca/orca-linux.AppImage
sudo chmod +x /opt/orca/orca-linux.AppImage
cd /opt/orca && sudo ./orca-linux.AppImage --appimage-extract
```

**Risco:** Médio — precisa de sudo para instalar dependências e criar diretório em /opt  
**Impacto:** Apenas adiciona arquivos, não altera config existente

---

### Fase 3: Conexão Hermes ↔ Linear (5 min)
**O que:** Registrar o MCP do Linear no Hermes

**Ações:**
1. Executar `hermes mcp add linear` ou usar prompt
2. Verificar que as tools do Linear apareceram
3. Criar tarefa de teste

**Comandos que vou executar:**
```bash
hermes mcp add linear
# Ou via prompt no Hermes:
# "Conecta o meu Hermes no Linear..."
```

**Risco:** Baixo — usa integração oficial do Hermes  
**Dependência:** Precisa de API key do Linear (você gera em linear.app/settings)

---

### Fase 4: Instalação da Skill (3 min)
**O que:** Copiar a skill para o diretório correto

**Ações:**
1. Criar diretório `~/.config/hermes/skills/time-de-dev-ia/`
2. Copiar `SKILL-TIME-DEV-IA.md` → `SKILL.md`
3. Verificar que o Hermes reconhece a skill

**Comandos que vou executar:**
```bash
mkdir -p ~/.config/hermes/skills/time-de-dev-ia
cp /home/gabriel/time-dev-ia/SKILL-TIME-DEV-IA.md \
   ~/.config/hermes/skills/time-de-dev-ia/SKILL.md
```

**Risco:** Muito baixo — apenas cópia de arquivo

---

### Fase 5: Teste de Integração (10 min)
**O que:** Validar que tudo conecta

**Testes:**
| # | Teste | Esperado |
|---|---|---|
| 1 | `hermes --version` | Retorna versão |
| 2 | `hermes mcp list` | Linear aparece nas tools |
| 3 | Pedir ao Hermes criar tarefa no Linear | Tarefa criada com link |
| 4 | `orca-ide status --json` | Retorna status "ok" |
| 5 | Prompt de kickoff completo | Hermes cria tarefas e entrega comando Orca |

**Risco:** Baixo — apenas leitura e testes

---

## 3. O que NÃO vou fazer

| Ação | Motivo |
|---|---|
| ❌ Não vou mergear PRs | Decision é sua |
| ❌ Não vou deployar nada | Deploy é do dono |
| ❌ Não vou compartilhar API keys | Segredo nunca |
| ❌ Não vou alterar código existente | Só configuração |
| ❌ Não vou executar comandos destrutivos | Sem rm -rf, sem git push forçado |

---

## 4. Como vai funcionar o dia a dia

### Exemplo prático: Criar uma feature

```
Você: "Quero adicionar tela de login no app"

Hermes (gerente):
├── Cria no Linear: "Tela de Login" (prioridade alta)
├── Cria no Linear: "Autenticação JWT" (prioridade alta)
├── Cria no Linear: "Testes de Login" (prioridade média)
└── Entrega pra você:
    ├── orca worktree create --repo meu-app --name tela-login --prompt "..."
    ├── orca worktree create --repo meu-app --name auth-jwt --prompt "..."
    └── orca worktree create --repo meu-app --name testes-login --prompt "..."

Você:
├── Executa os comandos no Orca (um por vez ou paralelo)
├── Revisa os PRs que surgirem
├── Aprova e mergear
└── Fecha as tarefas no Linear
```

### Fluxo visual

```
SEU INPUT ──▶ HERMES ──▶ LINEAR ──▶ ORCA ──▶ GITHUB ──▶ VOCÊ
   │             │           │         │         │         │
   │             │           │         │         │         │
   ▼             ▼           ▼         ▼         ▼         ▼
 descrever    criar      registrar  codar     abrir    revisar
 feature     tarefas     tasks      + testar   PR      + merge
```

---

## 5. Estrutura que será criada

```
~/.hermes/hermes-agent/          # Hermes (já existe)
~/.config/hermes/skills/
  └── time-de-dev-ia/
      └── SKILL.md               # Skill que ensina o fluxo
/opt/orca/                        # Orca (será criado)
  └── squashfs-root/              # AppImage extraído
```

---

## 6. Comandos que o Hermes vai gerenciar

### Criar tarefa (via MCP Linear)
O Hermes faz automaticamente — você só descreve o que quer.

### Disparar agente (entregue pelo Hermes)
```bash
orca worktree create \
  --repo name:seu-repo \
  --name nome-da-task \
  --base-branch main \
  --agent claude \
  --prompt "TAREFA: ... CONTEXTO: ... FRONTEIRAS: ... REGRAS: ... ENTREGA: ..." \
  --activate
```

### Revisar PR
```bash
gh pr list --head <branch-do-agente>
gh pr view <n>
gh pr diff <n>
gh pr checks <n> --watch
```

### Merge
```bash
gh pr merge <n> --squash --delete-branch
```

---

## 7. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Orca conflita com GNOME Orca | Baixa | Médio | CLI renomeado para `orca-ide` |
| Linear API key expirada | Baixa | Baixo | Regenerar em linear.app |
| Hermes não encontra skill | Média | Baixo | Verificar PATH e diretório |
| AppImage sem FUSE | Média | Baixo | Usar `--appimage-extract` |
| Orca headless sem Xvfb | Baixa | Médio | Instalar Xvfb antes |

---

## 8. Critérios de Sucesso

| # | Critério | Como verificar |
|---|---|---|
| 1 | Hermes responde | `hermes --version` retorna versão |
| 2 | Linear conectado | `hermes mcp list` mostra linear |
| 3 | Tarefa criada no Linear | Link da tarefa acessível |
| 4 | Orca instalado | `orca-ide status --json` retorna ok |
| 5 | Skill carregada | Hermes usa o prompt de 5 blocos |
| 6 | PR criado pelo Orca | `gh pr list` mostra PR do agente |
| 7 | Ciclo completo funciona | Task → PR → Merge → Task fechada |

---

## 9. Próximos passos (após aprovação)

1. **Você aprova este planejamento**
2. **Executo Fase 1** (verificação)
3. **Pergunto sobre API key do Linear** (se ainda não tiver)
4. **Executo Fases 2-4** (instalação)
5. **Executo Fase 5** (testes)
6. **Mostro resultado final**

---

## 10. Perguntas antes de começar

1. Você já tem conta no Linear? (se não, vou explicar como criar)
2. Tem API key do Linear? (se não, gera em linear.app/settings/account/security)
3. Quer usar o Hermes com qual LLM? (OpenRouter, Anthropic, OpenAI, Ollama local?)
4. Tem GitHub CLI (`gh`) instalado e autenticado? (necessário para PRs)

---

*Documento de planejamento — aguardando aprovação para executar*
