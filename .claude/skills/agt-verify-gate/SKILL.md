---
name: agt-verify-gate
description: run AGT doctor/verify and fail CI when governance evidence is weak.
---

# AGT verify gate

Keyless governance gate using Microsoft Agent Governance Toolkit (PyPI `agent-governance-toolkit[full]==4.1.0`).

## Doctor (health)

```bash
pip install "agent-governance-toolkit[full]==4.1.0"
agt doctor
```

Exit `0` required. Non-zero → refuse to ship.

## Verify (optional evidence)

Documented upstream:

```bash
agt verify --evidence ./agt-evidence.json --strict
```

Fail CI on weak evidence when you adopt this path.

## Keyless upstream conformance

At pin `47abed7446d47e74cfa76d01a5913bb873ffcad9`, after sibling installs matching upstream CI:

```bash
bash scripts/run-keyless-parity.sh
```

That runs, verbatim:

```bash
cd agent-governance-python/agent-os
pytest tests/test_governance_parity.py \
       tests/test_adapter_mediation_contract.py \
       -v --tb=short
```

## Habit

1. `agt doctor` green.
2. Reference CI sha256 green (`docs/upstream-agt-ci.reference.yml`).
3. Agent-os parity pytest green at the pin.
4. Refuse merge when any of the above fails.
