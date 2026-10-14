# Security Policy

**Built by [SkilledDragon LLC](https://skilleddragon.com)**

This is a **SkilledDragon educational minilab**, not a production product. We do **not** maintain these repos on a regular schedule and we do **not** operate a vulnerability response program for them.

## Contact

General questions: **hello@skilleddragon.com**  
Do not use a dedicated security mailbox for this repo — none exists.

## If you find an issue

- Prefer reporting **upstream** when the issue is in [microsoft/agent-governance-toolkit](https://github.com/microsoft/agent-governance-toolkit) or the PyPI package `agent-governance-toolkit`.
- For something specific to this minilab’s scripts or CI, you may email hello@skilleddragon.com. There is **no SLA**, and we may not patch or reply quickly.

## Supported versions

Only the commit currently on `main` is considered current for this educational lab.

## Secret handling

- Never commit `.env`, API keys, or tokens.
- The keyless path needs **no** API keys (`agt doctor`, agent-os parity pytest).
- Optional Azure IDs for Azure-integrated AGT features are out of scope for this lab.

## Tooling pins

| Control | Pin |
| --- | --- |
| Upstream | `microsoft/agent-governance-toolkit` @ `47abed7446d47e74cfa76d01a5913bb873ffcad9` (MIT) |
| PyPI | `agent-governance-toolkit[full]==4.1.0` |
| Upstream CI reference sha256 | `29f15fddf7fe40cb1940ea0ac35503e92ae8e8341821e629deca6d2314fb91d7` (1482 lines) |
| gitleaks | `v8.30.1` (pre-commit hook + CI binary with SHA256 verify) |
| osv-scanner | `v2.7.0` + `osv-scanner.toml` (ignore PYSEC-2026-3552/3553/3554) |
| Dependency audit | `uv run pip-audit` (same ignores — AGT 4.1.0 caps cryptography&lt;49) |

## Upstream license

`agent-governance-toolkit` is MIT. This lab ships MIT as well.

Use at your own risk. Pin versions, review the code, and treat this as sample material.
