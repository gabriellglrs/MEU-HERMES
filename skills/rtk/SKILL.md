---
name: rtk
description: "RTK (Rust Token Killer): reduz 60-90% do consumo de tokens comprimindo saída de comandos. Ativar quando o usuário quiser economizar tokens ou limpar contexto."
version: 0.48.0
author: rtk-ai
license: Apache-2.0
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [tokens, optimization, cost-reduction, cli, compression, efficiency]
    category: optimization
    related_skills: [systematic-debugging]
    prerequisites:
      commands: [rtk]
---

# RTK - Rust Token Killer

Proxy CLI que reduz **60-90% do consumo de tokens** comprimindo a saída de comandos antes que o LLM leia.

## ATIVAÇÃO

Esta skill é carregada sob demanda. Use quando:
- O usuário pedir para **economizar tokens**
- O usuário pedir para **limpar contexto** de comandos
- O usuário mencionar **RTK**, **token killer**, ou **compressão de saída**
- Sessão estiver ficando **grande/lenta** por saídas verbosas

## Quando NÃO usar

- Comandos simples com pouca saída
- Quando o usuário precisa da saída completa (debug detalhado)
- Comandos que o RTK não suporta

## Comandos Suportados

### Git (redução ~80%)
```bash
rtk git status      # Status compacto (15 linhas → 1)
rtk git diff        # Diff condensado
rtk git log         # One-line commits
rtk git add         # → "ok"
rtk git commit -m   # → "ok abc1234"
rtk git push        # → "ok main"
rtk git pull        # → "ok 3 files +10 -2"
```

### Testes (redução ~90%)
```bash
rtk cargo test      # Apenas falhas
rtk npm test        # Apenas falhas
rtk pytest          # Apenas falhas
rtk go test         # Apenas falhas
rtk jest            # Apenas falhas
rtk vitest          # Apenas falhas
```

### Build & Lint (redução ~80%)
```bash
rtk cargo build     # Erros apenas
rtk ruff check      # Agrupado por regra
rtk eslint          # Agrupado por regra
rtk tsc             # Erros por arquivo
```

### Arquivos (redução ~70%)
```bash
rtk ls              # Tree compacto com contagem
rtk find "*.rs"     # Resultados compactos
rtk grep "pattern"  # Resultados agrupados
```

### Containers (redução ~70%)
```bash
rtk docker ps       # Lista compacta
rtk docker logs     # Logs deduplicados
rtk kubectl pods    # Pods compactos
```

### Analytics
```bash
rtk gain            # Dashboard de economia
rtk gain --graph    # Gráfico ASCII (30 dias)
rtk discover        # Encontrar oportunidades perdidas
```

## Como Usar no Hermes

### Opção 1: Usar rtk diretamente
```bash
# Em vez de: git status
rtk git status

# Em vez de: cargo test
rtk cargo test

# Em vez de: docker ps
rtk docker ps
```

### Opção 2: Ativar hook global (auto-rewrite)
```bash
rtk init -g --agent hermes
# Reiniciar Hermes após ativar
```

### Opção 3: Rewriting manual sob demanda
```bash
# RTK pode reescrever qualquer comando
rtk rewrite git status
# Output: rtk git status
```

## Exemplos de Uso

### Economizar tokens em git
```bash
# SEM RTK (15 linhas):
git push
# Enumerating objects: 5, done.
# Counting objects: 100% (5/5), done.
# Delta compression using up to 8 threads
# ...

# COM RTK (1 linha):
rtk git push
# ok main
```

### Economizar tokens em testes
```bash
# SEM RTK (200+ linhas):
cargo test
# running 15 tests
# test utils::test_parse ... ok
# test utils::test_format ... ok
# ... (150 linhas de testes passando)
# test utils::test_edge_case ... FAILED
# ...

# COM RTK (~20 linhas):
rtk cargo test
# FAILED: 2/15 tests
#   test_edge_case: assertion failed
#   test_overflow: panic at utils.rs:18
```

### Ver economia acumulada
```bash
rtk gain
# Total commands: 1,247
# Estimated tokens saved: 89,432
# Reduction: 73%
```

## Flags Globais

| Flag | Efeito |
|------|--------|
| `-u` | Ultra-compact (ícones ASCII, formato inline) |
| `-v` | Mais verboso (-v, -vv, -vvv) |

## Configuração

Arquivo: `~/.config/rtk/config.toml`

```toml
[hooks]
exclude_commands = ["curl", "playwright"]  # Pular rewrite para estes

[retriever]
mode = "sqlite"  # Recall de saída completa em caso de falha
```

## Recall (saída completa)

Quando um comando falha, RTK salva a saída completa:
```
FAILED: 2/15 tests
[full output: rtk recall 3f9c2a81d4e7]
```

## Solução de Problemas

### RTK não encontrado
```bash
# Verificar PATH
rtk --version

# Se não encontrar, reinstalar
winget install rtk-ai.rtk
```

### Hook não funciona
```bash
# Verificar hook
rtk init --show

# Reinstalar hook
rtk init -g --agent hermes
```

### Saída muito truncada
```bash
# Usar flag verbose
rtk -v git status

# Ou desabilitar para comando específico
git status  # Sem rtk prefix
```

## Referência

- [Documentação](https://www.rtk-ai.app/guide)
- [GitHub](https://github.com/rtk-ai/rtk)
- [Comandos suportados](https://www.rtk-ai.app/guide/supported-commands)
