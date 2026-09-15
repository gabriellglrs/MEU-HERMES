---
name: raptor
description: "Raptor security research via Kali backend: static analysis (Semgrep), SCA/SBOM, LLM vulnerability validation, exploit PoC and patch generation. Use when auditing code for vulnerabilities, triaging findings, or running offensive/defensive security research on authorized targets."
version: 1.0.0
author: gabriellucas
license: MIT
platforms: [windows]
metadata:
  hermes:
    tags: [security, pentest, code-audit, semgrep, sca, vulnerability, exploit, patch]
    category: cybersecurity
    related_skills: [cybersecurity, time-de-dev-ia]
    prerequisites:
      commands: [wsl]
---

# Raptor (via Kali backend)

Raptor is an autonomous offensive/defensive security research framework
installed in the **kali-linux** WSL distro (`~/raptor`). Hermes drives it
through the Kali shell — the Python execution layer runs standalone, no
Claude Code needed.

Upstream: https://github.com/gadievron/raptor (MIT; CodeQL itself is not
approved for commercial use — see note below).

## Environment

- Backend: `kali-linux` WSL, repo at `/home/gabriel/raptor`
- Tools present: `semgrep` 1.177 **in `~/raptor-tools` venv** (required —
  Raptor scrubs user-site from subprocess env by design, so the
  `pip install --user` semgrep at `~/.local/bin` is invisible to it),
  `gdb`, `radare2`, `afl++`, `coccinelle` (`spatch`), `z3-solver`
- NOT installed (optional): `codeql`, `joern`, `frida`, `rr`,
  BigQuery creds (oss-forensics)
- All commands below run through WSL. Always use this prefix
  (`<K>` below) — note `raptor-tools/bin` FIRST in PATH:
  `export PATH="$HOME/raptor-tools/bin:$HOME/.local/bin:$PATH"`

## When to Use

- User asks to audit/scan code for vulnerabilities
- User asks to triage Raptor/Semgrep findings, validate exploitability,
  generate PoC or secure patch
- User asks for SCA/dependency audit with SBOM
- User asks for threat model of a project

## When NOT to Use

- Target the user does not own or has no written authorization to test
  (third-party sites, apps, networks) — refuse and explain
- Quick secret/regex greps — plain `grep`/semgrep directly is cheaper

## Safety Rules (hard)

1. **Authorized targets only**: own repos, labs (DVWA, Juice Shop),
   CTFs, explicit client scope. Never scan/exploit third parties.
2. Stall cost: `agentic`/`analyze` call LLMs per finding — always pass
   `--max-cost-usd` (default cap in Raptor is $10/run).
3. Review every generated PoC/patch before running or applying.
4. Findings that matter go to Linear (skill `time-de-dev-ia` flow).

## Workflows

All `terminal(command=...)` calls use the WSL prefix. `<K>` below means:

```
wsl -d kali-linux -- bash -lc 'export PATH="$HOME/raptor-tools/bin:$HOME/.local/bin:$PATH"; <CMD>'
```

| Task | Command (`<CMD>`) |
|---|---|
| Health check | `python3 ~/raptor/raptor.py doctor` |
| Pre-flight (target type, tool gaps, cost) | `python3 ~/raptor/raptor.py describe --repo <PATH-IN-KALI>` |
| Static scan (Semgrep + custom rules, SARIF out) | `python3 ~/raptor/raptor.py scan --repo <PATH> [--codeql]` |
| Full pipeline (scan → validate A–F → PoC → patch) | `python3 ~/raptor/raptor.py agentic --repo <PATH> --max-cost-usd 5.00` |
| Validate existing SARIF (no rescan) | `python3 ~/raptor/raptor.py analyze --sarif <FILE>` |
| SCA + SBOM | `python3 ~/raptor/raptor.py sca --repo <PATH>` |
| Project workspace | `python3 ~/raptor/raptor.py project create <NAME> --target <PATH>` then `project findings` |

Notes:
- `<PATH>` must exist **inside Kali** (e.g. copy the repo to
  `~/targets/<name>` first, or clone it there).
- Windows paths are visible at `/mnt/c/...` — prefer copying into
  `~/targets/` to avoid slow cross-FS scans.
- LLM-backed modes (`agentic`, `analyze`, exploit/patch codegen) need
  provider keys (`ANTHROPIC_API_KEY` / `OPENAI_API_KEY` / `OLLAMA_HOST`
  in the Kali env). Scan/SCA/describe/doctor need none.
- CodeQL flag only works after installing the CodeQL CLI (not
  installed; see upstream releases).

## Findings → Linear

1. Run scan/sca, read `findings.json` / `report.md` in the run dir.
2. Deduplicate against open Linear issues (`gh`-style: via Linear MCP).
3. Create one task per confirmed/high-severity finding (title, severity,
   file:line, evidence snippet) — then dispatch fix work per
   `time-de-dev-ia`.

## Verification

```
wsl -d kali-linux -- bash -lc 'export PATH="$HOME/raptor-tools/bin:$HOME/.local/bin:$PATH"; python3 ~/raptor/raptor.py doctor'
```

Success: `0 failure(s)`. Remaining warnings (codeql/joern/frida/rr)
are optional modules, not errors.
