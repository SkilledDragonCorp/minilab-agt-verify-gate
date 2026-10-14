"""Keyless: `agt doctor` must exit 0 (documented install path)."""

from __future__ import annotations

import os
import shutil
import subprocess


def test_agt_doctor_exits_zero() -> None:
    agt = shutil.which("agt")
    assert agt is not None, "agt not on PATH — run: uv sync --frozen --group dev"
    env = {**os.environ, "DO_NOT_TRACK": "1", "DISABLE_TELEMETRY": "1"}
    result = subprocess.run(
        [agt, "doctor"],
        capture_output=True,
        text=True,
        check=False,
        env=env,
    )
    assert result.returncode == 0, (
        f"agt doctor failed (exit {result.returncode})\n"
        f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
    )
