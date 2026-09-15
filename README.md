# Time de Dev com IA

**Hermes + Linear + Orca = Seu time de desenvolvimento com IA**

---

## Resumo

Sistema de desenvolvimento com IA onde:
- **Hermes** = Gerente (divide tarefas, revisa)
- **Linear** = Mural de tarefas
- **Orca** = Executor (coda e abre PRs)

---

## Status da Instalação (2026-09-15)

| Ferramenta | Status | Notas |
|---|---|---|
| Hermes | ✅ v0.21.2 | Funcionando |
| Linear MCP | ✅ 66 tools | Conectado |
| Orca | ⚠️ | Issue com GPU NVIDIA no Linux |
| GitHub CLI | ✅ | Autenticado |
| Skill | ✅ | Instalada |

---

## Arquivos

| Arquivo | Descrição |
|---|---|
| `SKILL-TIME-DEV-IA.md` | Skill para Hermes |
| `INSTALACAO-E-CONFIGURACAO.md` | Guia completo de instalação |
| `AUDITORIA-E-PLANEJAMENTO.md` | Planejamento e auditoria |
| `config-hermes.yaml` | Configuração do Hermes |

---

## Instalação Rápida (Windows)

```powershell
# 1. Instalar Hermes
iex (irm https://hermes-agent.nousresearch.com/install.ps1)

# 2. Instalar Orca (baixar .exe)
# https://github.com/stablyai/orca/releases/latest/download/orca-windows-setup.exe

# 3. Configurar Linear no Hermes
hermes mcp add linear

# 4. Copiar skill
mkdir ~/AppData/Local/hermes/skills/time-de-dev-ia
cp SKILL-TIME-DEV-IA.md ~/AppData/Local/hermes/skills/time-de-dev-ia/SKILL.md
```

---

## Fluxo de Trabalho

```
Você → Hermes → Linear → Orca → GitHub PR → Review → Merge
```

1. Descreva o projeto no Hermes
2. Hermes cria tarefas no Linear
3. Hermes entrega comando Orca pronto
4. Orca coda e abre PR
5. Você revisa e mergear

---

## Links

- [Hermes Agent](https://hermes-agent.nousresearch.com)
- [Linear](https://linear.app)
- [Orca](https://onorca.dev/download)

---

*Configurado em: 2026-09-15*
