"""Pinned upstream ci.yml reference must match the reviewed sha256 digest."""

from __future__ import annotations

import hashlib
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = "29f15fddf7fe40cb1940ea0ac35503e92ae8e8341821e629deca6d2314fb91d7"
# Committed under docs/ so Actions never schedules the reference as a workflow.
# fetch-upstream-ci.sh materializes .github/workflows/…, verifies, then relocates here.
REFERENCE = ROOT / "docs" / "upstream-agt-ci.reference.yml"


def test_reference_ci_hash() -> None:
    if not REFERENCE.is_file():
        subprocess.run(
            ["bash", str(ROOT / "scripts" / "fetch-upstream-ci.sh")],
            check=True,
            cwd=ROOT,
        )
    digest = hashlib.sha256(REFERENCE.read_bytes()).hexdigest()
    assert digest == EXPECTED, f"got {digest}, expected {EXPECTED}"
    # 1482-line file at pin (verified 2026-10-13)
    lines = REFERENCE.read_text(encoding="utf-8").count("\n")
    assert lines == 1482, f"expected 1482 lines, got {lines}"
