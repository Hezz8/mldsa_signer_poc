#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
THIRD_PARTY="$ROOT_DIR/tools/third_party"
DOWNLOADS="$THIRD_PARTY/downloads"
mkdir -p "$THIRD_PARTY" "$DOWNLOADS"

OSS_CAD_ASSET="$DOWNLOADS/oss-cad-suite-windows-x64-20260316.exe"
TECTONIC_ASSET="$DOWNLOADS/tectonic-0.15.0-x86_64-pc-windows-msvc.zip"
OSS_CAD_URL="https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-03-16/oss-cad-suite-windows-x64-20260316.exe"
TECTONIC_URL="https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.15.0/tectonic-0.15.0-x86_64-pc-windows-msvc.zip"

echo "This script documents the same user-space workflow used by the PowerShell setup."
echo "On Windows, prefer scripts/bootstrap/setup_user_space_tools.ps1 for actual setup."
echo "If a POSIX environment is available, download:"
echo "  $OSS_CAD_URL"
echo "  $TECTONIC_URL"
echo "and extract them under:"
echo "  $THIRD_PARTY/oss-cad-suite"
echo "  $THIRD_PARTY/tectonic"
