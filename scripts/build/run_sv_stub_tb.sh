#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OSS_CAD_ROOT="$ROOT_DIR/tools/third_party/oss-cad-suite/oss-cad-suite"
BUILD_DIR="$ROOT_DIR/build/sv_stub"

if [ ! -d "$OSS_CAD_ROOT" ]; then
  echo "Portable OSS CAD Suite not found at $OSS_CAD_ROOT" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"
export PATH="$OSS_CAD_ROOT/bin:$OSS_CAD_ROOT/lib:$PATH"

iverilog -g2012 -s tb_axi_lite_wrapper_stub -o "$BUILD_DIR/tb_axi_lite_wrapper_stub.vvp" \
  "$ROOT_DIR/hw/wrapper/wrapper_pkg.sv" \
  "$ROOT_DIR/hw/wrapper/axi_lite_wrapper_stub.sv" \
  "$ROOT_DIR/hw/tb/tb_axi_lite_wrapper_stub.sv"

vvp "$BUILD_DIR/tb_axi_lite_wrapper_stub.vvp"
