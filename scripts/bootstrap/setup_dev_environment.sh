#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

PYTHON_BIN="python"

if [ ! -x ".venv/Scripts/python.exe" ] && [ ! -x ".venv/bin/python" ]; then
  echo "Creating repo-local virtual environment..."
  python -m venv .venv
fi

if [ -x ".venv/Scripts/python.exe" ]; then
  PYTHON_BIN=".venv/Scripts/python.exe"
elif [ -x ".venv/bin/python" ]; then
  PYTHON_BIN=".venv/bin/python"
fi

echo "Installing Python dependencies into $PYTHON_BIN..."
"$PYTHON_BIN" -m pip install pytest grpcio grpcio-tools protobuf

echo "Tool summary:"
"$PYTHON_BIN" --version
"$PYTHON_BIN" -m pip --version
"$PYTHON_BIN" -m pytest --version
"$PYTHON_BIN" -c "import grpc; print('grpcio', grpc.__version__)"
"$PYTHON_BIN" -c "from grpc_tools import protoc; print('grpcio-tools ok')"
"$PYTHON_BIN" -c "import google.protobuf; print('protobuf', google.protobuf.__version__)"

echo "Suggested next checks:"
echo "  $PYTHON_BIN -m unittest discover -s sw/tests -v"
echo "  $PYTHON_BIN tools/repo_sanity_check.py"
echo "  $PYTHON_BIN -m sw.daemon.main selftest"
echo "  $PYTHON_BIN -m sw.client.client --mode local"
