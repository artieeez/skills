#!/usr/bin/env bash
# Validate ADR coverage paths after an ADR was saved. Does not classify —
# the agent writes report.md. This script only checks layout and prints paths.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${ROOT}" ]]; then
  echo "error: not inside a git repository" >&2
  exit 1
fi

cd "${ROOT}"

ADR_DIR="docs/adr"
COVERAGE_DIR="${ADR_DIR}/.coverage"
BACKLOG="${ADR_DIR}/BACKLOG.md"

if [[ ! -d "${ADR_DIR}" ]]; then
  echo "error: ${ADR_DIR} missing — run init_coverage.sh first" >&2
  exit 1
fi

if [[ ! -f "${BACKLOG}" ]]; then
  echo "error: ${BACKLOG} missing — run init_coverage.sh first" >&2
  exit 1
fi

mkdir -p "${COVERAGE_DIR}"

echo "ok backlog=${BACKLOG}"
echo "ok coverage_dir=${COVERAGE_DIR}"
echo "adrs:"
find "${ADR_DIR}" -maxdepth 1 -type f -name '*.md' ! -name 'BACKLOG.md' | sort
