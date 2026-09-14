# Plugin OpenCode (MEU-HERMES)

Integração do [OpenCode CLI](https://opencode.ai) com o Hermes.

O uso real acontece via tool `terminal` + skill `opencode`
(`skills/autonomous-ai-agents/opencode/SKILL.md`). Este plugin só garante
que `hermes plugins enable opencode` funcione e avisa se o binário sumir.

## Pré-requisitos

```bash
npm i -g opencode-ai@latest
opencode auth login
opencode --version
```

## Habilitar

```bash
hermes plugins enable opencode
hermes plugins list
```
