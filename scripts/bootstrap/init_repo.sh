#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

mkdir -p docs/build

if [ ! -d .git ]; then
  git init
  echo "Initialized a new git repository in $ROOT_DIR"
else
  echo "Git repository already present"
fi

echo "Bootstrap directories verified"
