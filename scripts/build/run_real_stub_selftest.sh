#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ -x "$ROOT_DIR/.venv/bin/python" ]; then
  PYTHON_EXE="$ROOT_DIR/.venv/bin/python"
elif [ -x "$ROOT_DIR/.venv/Scripts/python.exe" ]; then
  PYTHON_EXE="$ROOT_DIR/.venv/Scripts/python.exe"
else
  echo "Repo-local Python not found under $ROOT_DIR/.venv" >&2
  exit 1
fi

if [ -z "${PQSIG_MMIO_BASE_ADDR:-}" ]; then
  echo "PQSIG_MMIO_BASE_ADDR must be set for the real STUB selftest" >&2
  exit 2
fi

ARGS=("-m" "sw.daemon.main" "selftest" "--backend" "real" "--mmio-base-addr" "$PQSIG_MMIO_BASE_ADDR")
if [ -n "${PQSIG_MMIO_REGION_SIZE:-}" ]; then
  ARGS+=("--mmio-region-size" "$PQSIG_MMIO_REGION_SIZE")
fi
if [ -n "${PQSIG_DEVMEM_PATH:-}" ]; then
  ARGS+=("--devmem-path" "$PQSIG_DEVMEM_PATH")
fi
if [ -n "${PQSIG_TIMEOUT_S:-}" ]; then
  ARGS+=("--timeout-s" "$PQSIG_TIMEOUT_S")
fi

echo "Running real STUB selftest with arguments: ${ARGS[*]}"
"$PYTHON_EXE" "${ARGS[@]}"