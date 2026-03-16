#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs"
BUILD_DIR="$DOCS_DIR/build"

mkdir -p "$BUILD_DIR"
cd "$DOCS_DIR"

if command -v latexmk >/dev/null 2>&1; then
  latexmk -pdf -interaction=nonstopmode -output-directory="$BUILD_DIR" main.tex
elif command -v pdflatex >/dev/null 2>&1; then
  pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" main.tex
  pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" main.tex
else
  echo "No LaTeX compiler found. Install latexmk or pdflatex to build the docs." >&2
  exit 1
fi

echo "Documentation build complete: $BUILD_DIR"
