#!/usr/bin/env bash
# Fetch the pinned upstream ci.yml as a byte-identical reference.
# After hash verify, relocate under docs/ so GitHub Actions never schedules it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

mkdir -p .github/workflows docs

curl -fsSL \
  "https://raw.githubusercontent.com/microsoft/agent-governance-toolkit/47abed7446d47e74cfa76d01a5913bb873ffcad9/.github/workflows/ci.yml" \
  -o .github/workflows/upstream-agt-ci.reference.yml
echo "29f15fddf7fe40cb1940ea0ac35503e92ae8e8341821e629deca6d2314fb91d7  .github/workflows/upstream-agt-ci.reference.yml" | sha256sum -c -

# Keep the hashed original byte-identical under docs/ (not a runnable workflow).
cp .github/workflows/upstream-agt-ci.reference.yml docs/upstream-agt-ci.reference.yml
rm .github/workflows/upstream-agt-ci.reference.yml
echo "OK: docs/upstream-agt-ci.reference.yml (byte-identical; not scheduled)"
