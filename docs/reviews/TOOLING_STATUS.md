# Tooling Status

## Current Non-Admin Strategy

The repository supports a user-space tooling workflow that avoids administrator rights:

- Python dependencies live in `.venv`
- HDL tooling for the wrapper-level regression path is provisioned under `tools/third_party/oss-cad-suite/`
- LaTeX tooling is provisioned under `tools/third_party/tectonic/`

## What Works

- Python tests and local self-tests run from `.venv`
- `iverilog` and `vvp` run from the portable OSS CAD Suite bundle
- `tectonic` runs from a repo-local portable binary
- Windows-native scripts exist for docs and wrapper testbench execution
- the local wrapper testbench now covers `STUB`, `CORE_PLACEHOLDER`, and the documented `MLDSA_OSH` fallback behavior

## Current Caveats

- The imported ML-DSA-OSH sign path mixes Verilog and VHDL sources under `hw/ip/mldsa_osh/upstream/ref_combined/src`.
- The current portable toolchain does not provide `ghdl` or another mixed-language elaboration flow, so full local simulation of the real upstream sign path is not yet available in this environment.
- The portable LaTeX workflow depends on network access the first time `tectonic` downloads support bundles.
- The original `scripts/docs/build_docs.sh` remains useful in Bash-capable environments, but Windows users should prefer `scripts/docs/build_docs.ps1`.

## Recommended Commands

```powershell
.\scripts\bootstrap\setup_user_space_tools.ps1
.\scripts\build\run_sv_stub_tb.ps1
.\scripts\build\run_sv_mldsa_osh_tb.ps1
.\scripts\docs\build_docs.ps1
.\.venv\Scripts\python tools\environment_report.py
```