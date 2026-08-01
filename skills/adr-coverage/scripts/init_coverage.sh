#!/usr/bin/env bash
# Initialize ADR coverage paths in the current git repository.
# Creates docs/adr/BACKLOG.md (tracked), docs/adr/.coverage/ (gitignored),
# and appends gitignore rules. Does not commit or open a PR — the agent does that.
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
GITIGNORE=".gitignore"

mkdir -p "${COVERAGE_DIR}"

if [[ ! -f "${BACKLOG}" ]]; then
  cat > "${BACKLOG}" <<'EOF'
# ADR backlog

Open architecture decisions that need an ADR (or RFC first). Managed by the `adr-coverage` skill. ADRs themselves are written with `create-adr`.

| ID | Title | Status | Priority | Sources | ADR | Notes |
| --- | --- | --- | --- | --- | --- | --- |
EOF
  echo "created ${BACKLOG}"
else
  echo "exists ${BACKLOG}"
fi

# Ensure .coverage stays empty of tracked files; keep a local placeholder out of git via gitignore
if [[ ! -f "${COVERAGE_DIR}/.gitkeep_local" ]]; then
  echo "ADR coverage cache — do not commit" > "${COVERAGE_DIR}/.gitkeep_local"
fi

IGNORE_BLOCK=$(cat <<'EOF'

# ADR coverage cache (adr-coverage skill) — report is local-only
docs/adr/.coverage/
EOF
)

if [[ -f "${GITIGNORE}" ]] && grep -q 'docs/adr/\.coverage/' "${GITIGNORE}"; then
  echo "gitignore already lists docs/adr/.coverage/"
else
  if [[ ! -f "${GITIGNORE}" ]]; then
    printf '%s\n' "${IGNORE_BLOCK}" | sed '/^$/d' > "${GITIGNORE}"
  else
    printf '%s\n' "${IGNORE_BLOCK}" >> "${GITIGNORE}"
  fi
  echo "updated ${GITIGNORE}"
fi

echo
echo "Next (agent): create branch chore/adr-coverage-init, commit ${GITIGNORE} + ${BACKLOG}, open PR."
echo "Do not stage ${COVERAGE_DIR}"
