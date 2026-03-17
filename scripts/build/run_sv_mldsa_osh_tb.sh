#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OSS_CAD_ROOT="$ROOT_DIR/tools/third_party/oss-cad-suite/oss-cad-suite"

if [ -d "$OSS_CAD_ROOT" ]; then
  export PATH="$OSS_CAD_ROOT/bin:$OSS_CAD_ROOT/lib:$PATH"
fi

if ! command -v ghdl >/dev/null 2>&1; then
  echo "MLDSA-OSH real-core simulation is blocked in the current local flow." >&2
  echo "Reason: the imported upstream signing path under hw/ip/mldsa_osh/upstream/ref_combined/src mixes Verilog (*.v) and VHDL (*.vhd), but the current portable toolchain does not provide ghdl or another mixed-language elaboration flow." >&2
  echo "The stable wrapper testbench still covers STUB, CORE_PLACEHOLDER, and the honest MLDSA_OSH fallback path through scripts/build/run_sv_stub_tb.sh." >&2
  exit 1
fi

echo "ghdl is available, but a mixed-language MLDSA-OSH elaboration recipe is not yet automated in this repo script." >&2
echo "Use docs/architecture/MLDSA_OSH_Inspection_Notes.md and docs/architecture/MLDSA_OSH_Integration_Guide.tex as the integration baseline before adding a full mixed-language regression script." >&2
exit 1