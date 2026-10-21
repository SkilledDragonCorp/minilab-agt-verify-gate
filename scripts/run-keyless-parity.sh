#!/usr/bin/env bash
# Keyless agent-os conformance — sibling installs copied from upstream ci.yml
# at 47abed7446d47e74cfa76d01a5913bb873ffcad9 (python-packages job steps:
# Install local sibling dependencies / Install OPA / Build native ACS SDK /
# Install agent-os). Final pytest matches the Conformance step verbatim.
#
# Uses a fresh venv so lab PyPI pin agent-governance-toolkit==4.1.0 cannot
# collide with the pin-tree editables (core 5.0.0).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIN_SHA="47abed7446d47e74cfa76d01a5913bb873ffcad9"
VENDOR="${ROOT}/vendor/agent-governance-toolkit"
PARITY_VENV="${ROOT}/vendor/.parity-venv"

bash "${ROOT}/scripts/fetch-upstream.sh"
cd "${VENDOR}"
test "$(git rev-parse HEAD)" = "${PIN_SHA}"

export DO_NOT_TRACK=1
export DISABLE_TELEMETRY=1

rm -rf "${PARITY_VENV}"
python3 -m venv "${PARITY_VENV}"
# shellcheck disable=SC1091
source "${PARITY_VENV}/bin/activate"
python -m pip install --upgrade pip setuptools wheel

# ── Install local sibling dependencies (upstream ci.yml, verbatim) ──────
pip install --no-cache-dir --no-deps -e agent-governance-python/agent-governance-toolkit-core
pip install --no-cache-dir --no-deps -e agent-governance-python/agent-governance-toolkit-integrations
pip install --no-cache-dir --no-deps -e agent-governance-python/agent-governance-toolkit-cli
pip install --no-cache-dir --no-deps -e agent-governance-python/agent-governance-toolkit-protocols
pip install --no-cache-dir "pydantic>=2.5.0,<3.0" "pyyaml>=6.0,<7.0"
pip install --no-cache-dir --no-deps -e agent-governance-python/agt-policies
pip install --no-cache-dir --no-deps -e agent-governance-python/agent-hypervisor

# ── Install OPA (ACS-backed Python policy runtime) ──────────────────────
# Upstream pins opa_linux_amd64_static @ v0.70.0. Local Darwin uses the
# matching platform binary; digest verified after download.
OPA_DIR="$(mktemp -d "${TMPDIR:-/tmp}/agt-opa.XXXXXX")"
OS="$(uname -s)"
ARCH="$(uname -m)"
case "${OS}-${ARCH}" in
  Linux-x86_64|Linux-amd64)
    OPA_ASSET="opa_linux_amd64_static"
    OPA_SHA256="00d114b94fdb1606a48cccdfc73c9ccdc62c38721150131ae578d5ff3df5c084"
    ;;
  Darwin-x86_64)
    OPA_ASSET="opa_darwin_amd64"
    OPA_SHA256="7827172827c6c7763fd36dd72052c318a6beb18f7b907c5e67d847bb557af1a1"
    ;;
  Darwin-arm64)
    OPA_ASSET="opa_darwin_arm64_static"
    OPA_SHA256="267608fe41dba91fb23e2a69a439cb2a39710b3a069a828c744bd99bb3f94508"
    ;;
  *)
    echo "Unsupported platform for OPA: ${OS}-${ARCH}" >&2
    exit 1
    ;;
esac
curl --proto '=https' --tlsv1.2 -fSLo "${OPA_DIR}/opa" \
  --retry 5 --retry-all-errors --retry-delay 5 --connect-timeout 20 \
  "https://openpolicyagent.org/downloads/v0.70.0/${OPA_ASSET}"
echo "${OPA_SHA256}  ${OPA_DIR}/opa" | sha256sum -c -
chmod +x "${OPA_DIR}/opa"
export ACS_OPA_PATH="${OPA_DIR}/opa"
export PATH="${OPA_DIR}:${PATH}"
"${OPA_DIR}/opa" version

# ── Build native ACS SDK (ACS-backed Python policy runtime) ─────────────
pip install --no-cache-dir maturin==1.8.7 # Scorecard: version-pinned
pip install --no-cache-dir --no-build-isolation ./policy-engine/sdk/python

# ── Install agent-os (upstream case agent-os → .[dev]) ──────────────────
(
  cd agent-governance-python/agent-os
  pip install --no-cache-dir -e ".[dev]"
)
CI_TEST_REQS="${VENDOR}/agent-governance-python/requirements/ci-test.txt"
if [[ -f "${CI_TEST_REQS}" ]]; then
  pip install --no-cache-dir --require-hashes -r "${CI_TEST_REQS}"
else
  echo "warning: ci-test.txt not found at ${CI_TEST_REQS} — skipping shared test deps" >&2
fi
pip install --no-cache-dir pytest-cov==7.1.0 # Scorecard: version-pinned

# ── Conformance (agent-os parity + adapter contract) — verbatim ─────────
cd agent-governance-python/agent-os
pytest tests/test_governance_parity.py \
       tests/test_adapter_mediation_contract.py \
       -v --tb=short
