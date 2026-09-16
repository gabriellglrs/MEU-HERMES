---
last_mapped_commit: 0efa1be56b39cf66a1d99c84de7d1a4732847da9
last_mapped_at: 2026-09-15
---
# Testing — MEU-HERMES

> Date: 2026-09-16
> Repo: Hermes AI-agent config backup (`config.yaml`, `SOUL.md`, `skills/`, `plugins/`, `scripts/`)
> Focus: quality (framework, structure, mocking, coverage)

## 1. Framework (Present but Scoped)

- **Primary: `pytest` (Python).** No root `pyproject.toml` / `pytest.ini` / `setup.cfg`; each skill owns its suite and is run from the skill dir, e.g. `pytest skills/productivity/xlsx/tests/ -q`, `pytest skills/brand/scripts/tests/ -q`.
- **Secondary: `node` smoke + regression via pytest `subprocess`.** Node scripts have no `package.json` / `jest` / `vitest`; the Python test shells out to `node` (see `skills/brand/scripts/tests/test_sync_brand_to_tokens.py` using `shutil.which("node")` + `subprocess.run([node, str(SCRIPT)], cwd=tmp_path)`).
- **No repo-wide runner, CI workflow, or coverage gate.** There is no `.github/workflows/`, no `tox.ini`, no `coverage` config; quality is enforced socially via skill docs `skills/test-driven-development/SKILL.md` (RED-GREEN-REFACTOR iron law) and `skills/systematic-debugging/SKILL.md` (Phase 4 requires a regression test before fix).
- **Manual / agent-run checks:** `scripts/security-check.sh`, `scripts/monitor-system.sh`, `scripts/cleanup-system.sh --dry-run`, plus Hermes `terminal` tool invocations documented in both skill files (`pytest tests/test_feature.py::test_name -v` then `pytest tests/ -q`).

## 2. Structure (Where Tests Live)

- Colocated per skill, not centralized:
  - `skills/productivity/xlsx/tests/test_xlsx_skill.py` (542 lines, 10 tests — largest suite; covers `skills/productivity/xlsx/scripts/xlsx_create.py`, `xlsx_read.py`, `xlsx_edit.py`, `xlsx_to_csv.py`, `csv_to_xlsx.py`, `xlsx_restructure.py`, `xlsx_recalc.py`).
  - `skills/brand/scripts/tests/test_sync_brand_to_tokens.py` (52 lines, 1 test — regression for `skills/brand/scripts/sync-brand-to-tokens.cjs` happy-path crash on bundled `skills/brand/templates/brand-guidelines-starter.md`).
  - `skills/ui-ux-pro-max/scripts/tests/test_core.py`, `test_data_contracts.py`, `test_style_taxonomy.py`, `test_catalog_refresh.py`, + 6 more freshness/resilience tests.
  - `skills/design-system/scripts/tests/test_validate_tokens.py`, `skills/ui-styling/scripts/tests/test_tailwind_config_gen.py`, `test_shadcn_add.py`, `skills/productivity/{docx,pdf,powerpoint}/tests/test_*.py`.
- **Fixtures pattern:** `tmp_path` + JSON spec files built inline (see `SPEC` / `RESTRUCTURE_SPEC` dicts in `skills/productivity/xlsx/tests/test_xlsx_skill.py`), copied starter templates (`shutil.copy(BRAND_STARTER, tmp_path / "docs" / "brand-guidelines.md")`), `openpyxl.load_workbook` assertions on cells/styles/merges/charts/validations.
- **No tests for:** `plugins/rtk-rewrite/__init__.py`, `plugins/opencode/__init__.py` (fail-open adapters, zero tests), `scripts/*.sh`, `install.sh`, `config.yaml` / `SOUL.md` (declarative), `skills/web/blocked-page-recovery/scripts/recover_page.py` (stdlib-only, untested).
- Mirror risk: `memory-backup/skills/productivity/xlsx/tests/test_xlsx_skill.py` duplicates the live suite — edit the live copy under `skills/`, not the backup.

## 3. Running Tests

- Per-skill (from repo root `C:\\DEV\\MEU-HERMES`):
  - `pytest skills/productivity/xlsx/tests/test_xlsx_skill.py -v` (requires `openpyxl`, `pytest`; skips LibreOffice branch if `soffice` missing — see `test_recalc_reports_json_both_ways` with `pytest.skip("LibreOffice not installed...")`).
  - `pytest skills/brand/scripts/tests/test_sync_brand_to_tokens.py -v` (requires `node`; skips if absent via `pytest.skip("node not available")`).
  - `pytest skills/ui-ux-pro-max/scripts/tests/ -q` / `pytest skills/productivity/docx/tests/ skills/productivity/pdf/tests/ skills/productivity/powerpoint/tests/ -q`.
- Single-test focus (mandated by TDD skill): `pytest skills/productivity/xlsx/tests/test_xlsx_skill.py::test_create_features_roundtrip -v`.
- Node ad-hoc: `node skills/brand/scripts/sync-brand-to-tokens.cjs --dry-run`, `node skills/brand/scripts/validate-asset.cjs <asset-path> --json`.
- Shell dry-runs: `scripts/cleanup-system.sh --dry-run`, `scripts/backup-configs.sh ~/backups/configs/`.

## 4. Mocking & Isolation

- **Policy: real code over mocks.** `skills/test-driven-development/SKILL.md` explicitly bans `MagicMock`-style behavior tests (`Bad test: mock.side_effect = ...`); mocks allowed only when truly unavoidable (network/hardware).
- **Subprocess-as-integration:** helpers run as `subprocess.run([sys.executable, str(SCRIPTS / script), ...], env={LC_ALL=C, LANG=C})` to prove locale-independent UTF-8 I/O — no monkeypatching of I/O (see `run()` helper in `skills/productivity/xlsx/tests/test_xlsx_skill.py`).
- **Environment hiding:** absent-dependency branches tested by scrubbing `PATH` (`env = dict(os.environ, PATH=str(tmp_path))` for missing `soffice` in `test_recalc_reports_json_both_ways`) and `shutil.which()` guards with `pytest.skip`.
- **No `unittest.mock`, `pytest-mock`, `responses`, or `nock` anywhere** in the repo; network is avoided entirely (`No network access` docstring in `test_xlsx_skill.py`).

## 5. Coverage (Absent — No Gate)

- **No coverage tool configured** (`pytest-cov`, `c8`, `nyc`, `codecov.yml` all absent); no `--cov` flags, no thresholds, no badges.
- Effective coverage is uneven: `xlsx` helpers are deeply covered (roundtrip, CSV non-ASCII `Zürich/Фамилия`, restructure insert/delete rows+cols, tables/names/hyperlinks/notes/protection, recalc both branches); `brand` sync has exactly one regression test; plugins + shell automation have zero.
- Verification checklist is procedural, not numeric — `skills/test-driven-development/SKILL.md` requires before-done: every new function has a test, each test watched to fail first, full suite green with pristine output (`pytest tests/ -q` with no errors/warnings).
- Gaps to close if a gate is ever added: unit tests for `plugins/rtk-rewrite/__init__.py` return-code matrix (`{0,3}` rewrite vs `{1,2}` passthrough vs warn), `skills/brand/scripts/validate-asset.cjs` naming/size/format matrix, `scripts/*.sh` via `shellcheck` + `bats` (currently neither is wired).

## 6. Conventions for New Tests

- Place under `<skill>/scripts/tests/test_*.py` or `<skill>/tests/test_*.py`; name `test_<behavior>_<scenario>` (`test_restructure_insert_rows_shifts_everything`, `test_csv_roundtrip_nonascii`, `test_sync_parses_bundled_starter_template`).
- Follow TDD per `skills/test-driven-development/SKILL.md`: write failing test → `pytest <file>::<test> -v` (RED) → minimal fix → same command (GREEN) → full skill suite `-q` → refactor. Pair with `skills/systematic-debugging/SKILL.md` Phase 1 tight loop for bugs.
- Use `tmp_path`, explicit `encoding="utf-8"`, `LC_ALL=C` env, `json.loads(proc.stdout)` assertions; skip gracefully when optional binaries (`node`, `soffice`) are missing rather than failing.
