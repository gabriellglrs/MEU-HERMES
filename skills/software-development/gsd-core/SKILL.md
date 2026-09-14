---
name: gsd-core
description: "Usar GSD Core para desenvolvimento orientado a especificações com engenharia de contexto"
version: 1.0.0
author: Gabriel
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [development, context-engineering, spec-driven, opencode]
    related_skills: [opencode, opencode-driven-development, systematic-debugging]
    requires_tools: [terminal]
    config:
      - key: gsd-core.project_path
        description: "Caminho padrão para projetos GSD Core"
        default: "~/projects"
        prompt: "Diretório onde seus projetos GSD Core ficam"
---

# GSD Core - Engenharia de Contexto

Use [GSD Core](https://github.com/open-gsd/gsd-core) para desenvolvimento orientado a especificações com engenharia de contexto avançada.

## O que é o GSD Core?

GSD Core é um framework que resolve **context rot** — a degradação de qualidade que se acumula quando uma IA preenche sua janela de contexto. Ele executa todo o trabalho pesado de pesquisa, planejamento e execução em **subagentes com contexto limpo**, mantendo sua sessão principal enxuta.

### Ciclo de Fases

1. **Discuss** — Capturar decisões de implementação antes de qualquer planejamento
2. **Plan** — Pesquisar, decompor e verificar se o plano cabe em uma janela de contexto limpa
3. **Execute** — Executar planos em ondas paralelas; cada executor começa com contexto limpo
4. **Verify** — Percorrer o que foi construído; diagnosticar e corrigir antes de declarar conclusão
5. **Ship** — Criar o PR, arquivar a fase e repetir para a próxima

## Quando usar o GSD Core

- **Projetos grandes e complexos** — Quando o projeto tem muitas partes interdependentes
- **Contexto ficando grande** — Quando a sessão está ficando lenta ou perdendo qualidade
- **Qualidade consistente** — Quando precisa de resultados previsíveis e de alta qualidade
- **Teams** — Quando múltiplas pessoas trabalham no mesmo código
- **Código crítico** — Quando bugs têm alto custo (produção, segurança, etc.)

## Pré-requisitos

- OpenCode instalado e configurado
- GSD Core instalado: `npx @opengsd/gsd-core@latest --opencode --global`
- Git instalado

## Verificar instalação

```bash
# Verificar se GSD Core está instalado
ls -la ~/.config/opencode/skills/ | grep gsd

# Verificar versão
cat ~/.config/opencode/VERSION

# Verificar runtime
cat ~/.config/opencode/.gsd-runtime
```

## Comandos disponíveis

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

## Procedimento para usar com Hermes

### 1. Para novo projeto

```bash
# Navegar até o diretório do projeto
cd ~/projects

# Criar diretório do projeto
mkdir meu-novo-projeto
cd meu-novo-projeto

# Inicializar git
git init

# Iniciar GSD Core
opencode
# Dentro do OpenCode, digite:
/gsd-new-project
```

### 2. Para projeto existente

```bash
# Navegar até o repositório
cd ~/meu-repositorio

# Integrar com GSD Core
opencode
# Dentro do OpenCode, digite:
/gsd-onboard
```

### 3. Ciclo de trabalho

```bash
# 1. Discutir a fase
opencode
# /gsd-discuss-phase

# 2. Planejar
# O GSD Core cria um plano em STATE.md

# 3. Executar
# /gsd-execute-phase
# Trabalho é feito em subagentes com contexto limpo

# 4. Verificar
# /gsd-verify-phase

# 5. Entregar
# /gsd-complete-milestone
```

## Estrutura de arquivos GSD Core

```
meu-projeto/
├── STATE.md           # Estado atual do projeto
├── CONTEXT.md         # Contexto do projeto
├── .gsd/              # Diretório do GSD Core
│   └── phase/         # Fases em andamento
├── docs/              # Documentação
└── src/               # Código fonte
```

## Integração com Hermes

O Hermes pode usar o GSD Core automaticamente quando:

1. **Detectar projeto complexo** — Muitos arquivos, dependências
2. **Contexto grande** — Sessão ficando lenta
3. **Pedido explícito** — Usuário pede para usar GSD Core

### Exemplo de uso

```
Usuário: "Quero criar uma API REST completa com autenticação"

Hermes: "Vou usar o GSD Core para isso. É um projeto complexo que 
beneficia de engenharia de contexto."

# Hermes executa:
cd ~/projects
mkdir minha-api
cd minha-api
git init
opencode
# /gsd-new-project
```

## Dicas

- **Comece simples** — Use GSD Core para projetos médios primeiro
- **Documente** — O GSD Core funciona melhor com documentação clara
- **Verifique sempre** — Não pule a fase de verificação
- **Git limpo** — Mantenha commits pequenos e descritivos

## Solução de problemas

### GSD Core não encontrado

```bash
# Reinstalar
npx @opengsd/gsd-core@latest --opencode --global

# Verificar instalação
ls -la ~/.config/opencode/skills/ | grep gsd
```

### Comandos não aparecem

```bash
# Reiniciar OpenCode
# Os comandos /gsd-* devem aparecer
```

### Erro de contexto

```bash
# Limpar estado
rm -rf .gsd/
# Reintroduzir
/gsd-onboard
```

## Links úteis

- [Repositório oficial](https://github.com/open-gsd/gsd-core)
- [Documentação](https://github.com/open-gsd/gsd-core/tree/main/docs)
- [Discord da comunidade](https://discord.gg/mYgfVNfA2r)
- [Português](https://github.com/open-gsd/gsd-core/blob/main/README.pt-BR.md)
