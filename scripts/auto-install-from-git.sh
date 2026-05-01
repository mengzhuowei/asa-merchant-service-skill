#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-}"
REF="${2:-main}"
SKILL_NAME="${3:-asa-merchant-service}"
CODEX_HOME_INPUT="${4:-}"
FORCE_UPGRADE="${5:-false}"

if [[ -z "${REPO_URL}" ]]; then
  echo "Usage: $0 <repo_url> [ref] [skill_name] [codex_home]" >&2
  exit 1
fi

if [[ -n "${CODEX_HOME_INPUT}" ]]; then
  CODEX_HOME_DIR="${CODEX_HOME_INPUT}"
elif [[ -n "${CODEX_HOME:-}" ]]; then
  CODEX_HOME_DIR="${CODEX_HOME}"
else
  CODEX_HOME_DIR="${HOME}/.codex"
fi

TARGET_PATH="${CODEX_HOME_DIR}/skills/${SKILL_NAME}"
if [[ -d "${TARGET_PATH}" ]]; then
  if [[ "${FORCE_UPGRADE}" != "true" ]]; then
    echo "Skill already installed at: ${TARGET_PATH}"
    exit 0
  fi
  echo "Force upgrade enabled, will refresh: ${TARGET_PATH}"
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

git clone --depth 1 --branch "${REF}" "${REPO_URL}" "${TMP_DIR}" >/dev/null
bash "${TMP_DIR}/scripts/install.sh" "${SKILL_NAME}" "${TMP_DIR}" "${CODEX_HOME_DIR}" "${FORCE_UPGRADE}"
