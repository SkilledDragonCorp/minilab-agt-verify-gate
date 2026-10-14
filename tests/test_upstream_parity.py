"""Run upstream agent-os conformance subset at the pin (keyless)."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "run-keyless-parity.sh"


def test_upstream_parity_exits_zero() -> None:
    assert SCRIPT.is_file(), f"missing {SCRIPT}"
    env = {**os.environ, "DO_NOT_TRACK": "1", "DISABLE_TELEMETRY": "1"}
    # Use the active uv/venv python's pip so editable installs land where pytest runs.
    result = subprocess.run(
        ["bash", str(SCRIPT)],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
        env=env,
        timeout=1800,
    )
    assert result.returncode == 0, (
        f"run-keyless-parity.sh failed (exit {result.returncode})\n"
        f"stdout:\n{result.stdout[-8000:]}\nstderr:\n{result.stderr[-8000:]}"
    )
