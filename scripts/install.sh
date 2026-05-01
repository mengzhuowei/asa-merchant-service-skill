#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="${1:-asa-merchant-service}"
SOURCE_PATH="${2:-}"
CODEX_HOME_INPUT="${3:-}"
FORCE_UPGRADE="${4:-false}"

if [[ -z "${SOURCE_PATH}" ]]; then
  SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  SOURCE_PATH="$(cd "${SOURCE_PATH}" && pwd)"
fi

if [[ -n "${CODEX_HOME_INPUT}" ]]; then
  CODEX_HOME_DIR="${CODEX_HOME_INPUT}"
elif [[ -n "${CODEX_HOME:-}" ]]; then
  CODEX_HOME_DIR="${CODEX_HOME}"
else
  CODEX_HOME_DIR="${HOME}/.codex"
fi

SKILL_ROOT="${CODEX_HOME_DIR}/skills"
TARGET_PATH="${SKILL_ROOT}/${SKILL_NAME}"
SKILL_ROOT_RESOLVED="$(mkdir -p "${SKILL_ROOT}" && cd "${SKILL_ROOT}" && pwd)"
TARGET_PATH_RESOLVED="${SKILL_ROOT_RESOLVED}/${SKILL_NAME}"

if [[ ! -f "${SOURCE_PATH}/SKILL.md" ]]; then
  echo "Invalid source path: SKILL.md not found in ${SOURCE_PATH}" >&2
  exit 1
fi

if [[ -d "${TARGET_PATH}" ]]; then
  if [[ "${FORCE_UPGRADE}" != "true" ]]; then
    echo "Skill already installed at: ${TARGET_PATH}"
    exit 0
  fi

  case "${TARGET_PATH_RESOLVED}" in
    "${SKILL_ROOT_RESOLVED}"/*) ;;
    *)
      echo "Refusing to remove path outside skill root: ${TARGET_PATH_RESOLVED}" >&2
      exit 1
      ;;
  esac
  rm -rf "${TARGET_PATH}"
fi

mkdir -p "${TARGET_PATH}"

shopt -s dotglob
for entry in "${SOURCE_PATH}"/*; do
  base="$(basename "${entry}")"
  if [[ "${base}" == ".git" || "${base}" == ".gitignore" ]]; then
    continue
  fi
  cp -R "${entry}" "${TARGET_PATH}/"
done
shopt -u dotglob

if [[ "${FORCE_UPGRADE}" == "true" ]]; then
  echo "Upgraded skill '${SKILL_NAME}' at: ${TARGET_PATH}"
else
  echo "Installed skill '${SKILL_NAME}' to: ${TARGET_PATH}"
fi
