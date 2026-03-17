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

ARGS=("-m" "sw.daemon.main" "probe-mmio" "--backend" "real")
if [ -n "${PQSIG_MMIO_BASE_ADDR:-}" ]; then
  ARGS+=("--mmio-base-addr" "$PQSIG_MMIO_BASE_ADDR")
fi
if [ -n "${PQSIG_MMIO_REGION_SIZE:-}" ]; then
  ARGS+=("--mmio-region-size" "$PQSIG_MMIO_REGION_SIZE")
fi
if [ -n "${PQSIG_DEVMEM_PATH:-}" ]; then
  ARGS+=("--devmem-path" "$PQSIG_DEVMEM_PATH")
fi
if [ "${1:-}" = "--clear-status" ]; then
  ARGS+=("--clear-status")
fi

echo "Running real MMIO probe with arguments: ${ARGS[*]}"
"$PYTHON_EXE" "${ARGS[@]}"