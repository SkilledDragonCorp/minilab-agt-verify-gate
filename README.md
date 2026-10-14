# minilab-agt-verify-gate

**Built by SkilledDragon LLC — architecture-led software engineering · [skilleddragon.com](https://skilleddragon.com)**

Keyless governance gate for [Microsoft Agent Governance Toolkit](https://github.com/microsoft/agent-governance-toolkit): install the pinned CLI, prove `agt doctor`, keep a byte-identical upstream CI reference (sha256-checked), and re-run the upstream agent-os conformance subset at a pinned SHA.

| Piece | Purpose |
| --- | --- |
| `agent-governance-toolkit[full]==4.1.0` | PyPI pin (uv.lock) for `agt` CLI |
| `docs/upstream-agt-ci.reference.yml` | Full upstream `ci.yml` @ pin (1482 lines; not scheduled) |
| `scripts/run-keyless-parity.sh` | Sibling installs + OPA + ACS SDK + agent-os parity pytest |
| `.claude/skills/agt-verify-gate/` | Doctor / verify / refuse-on-weak-evidence skill |

Upstream pin: [microsoft/agent-governance-toolkit](https://github.com/microsoft/agent-governance-toolkit) @ `47abed7446d47e74cfa76d01a5913bb873ffcad9` (MIT) · PyPI `4.1.0`.

Reference digest: `29f15fddf7fe40cb1940ea0ac35503e92ae8e8341821e629deca6d2314fb91d7`.

## What we built and why

Banks are tightening the puerta on outside AI agents (JPMorgan / Jamie Dimon earnings-call claims reported by CNBC, Oct 13 2026 — treat as bank claims, not independent proof). Payoff for builders: install AGT, prove the toolkit is healthy without keys, and pin the same agent-os parity tests upstream CI runs.

## What we tested

| Check | Expected |
| --- | --- |
| `agt doctor` | exit 0 |
| Reference CI sha256 | `29f15fdd…91d7` (1482 lines) |
| `test_governance_parity.py` + `test_adapter_mediation_contract.py` | exit 0 at pin |

## Setup

Requires Python `>=3.11`, [uv](https://docs.astral.sh/uv/), Rust (for the native ACS SDK build), and network access to fetch OPA + upstream.

```bash
git clone https://github.com/SkilledDragonCorp/minilab-agt-verify-gate.git
cd minilab-agt-verify-gate
cp .env.example .env
uv sync --frozen --group dev
```

## Tutorial

### 1. Install and doctor

```bash
uv sync --frozen --group dev
uv run agt doctor
```

Documented upstream extras (also works outside uv):

```bash
pip install "agent-governance-toolkit[full]==4.1.0"
agt doctor
```

Optional evidence (documented; not required for this lab’s keyless CI):

```bash
agt verify --evidence ./agt-evidence.json --strict
```

### 2. Refresh the upstream CI reference

```bash
bash scripts/fetch-upstream-ci.sh
```

Writes `.github/workflows/upstream-agt-ci.reference.yml`, verifies the pinned sha256, then relocates the byte-identical file to `docs/` so GitHub Actions never schedules it.

### 3. Keyless agent-os parity

Installs siblings **exactly** as upstream CI (`Install local sibling dependencies`, `Install OPA`, `Build native ACS SDK`, `Install agent-os` with `pip install --no-cache-dir -e ".[dev]"`), then:

```bash
bash scripts/run-keyless-parity.sh
```

### 4. Lab tests

```bash
uv run pytest -q
```

## API keys

**None** for the keyless path. Optional Azure IDs only for Azure-integrated AGT features (out of scope).

## Using these skills in Claude Code and Cursor

Skills live only under `.claude/skills/<name>/SKILL.md` (Claude Code and Cursor both read this path). Do not create `.cursor/skills` or `.agents/skills` mirrors — CI fails if they exist.

- `.claude/skills/agt-verify-gate/SKILL.md` — run AGT doctor/verify and fail CI when governance evidence is weak.

## License

MIT · Contact: hello@skilleddragon.com
