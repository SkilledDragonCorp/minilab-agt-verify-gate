#!/usr/bin/env bash
# Clone microsoft/agent-governance-toolkit at the pinned SHA (vendor is gitignored).
set -euo pipefail

PIN_SHA="47abed7446d47e74cfa76d01a5913bb873ffcad9"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR="${ROOT}/vendor/agent-governance-toolkit"

mkdir -p "${ROOT}/vendor"
if [[ -d "${VENDOR}/.git" ]]; then
  git -C "${VENDOR}" fetch --depth 1 origin "${PIN_SHA}"
  git -C "${VENDOR}" checkout --force "${PIN_SHA}"
else
  rm -rf "${VENDOR}"
  git clone --filter=blob:none https://github.com/microsoft/agent-governance-toolkit.git "${VENDOR}"
  git -C "${VENDOR}" checkout "${PIN_SHA}"
fi

test "$(git -C "${VENDOR}" rev-parse HEAD)" = "${PIN_SHA}"
echo "vendor/agent-governance-toolkit @ ${PIN_SHA}"
