# Build Scripts

This directory contains lightweight build and execution helpers for the current bootstrap, imported-core integration, and board bring-up preparation phases.

- `run_python_tests.sh`: runs the software unit and contract tests using the standard library `unittest` runner.
- `run_sv_stub_tb.ps1`: compiles and runs the stable AXI-Lite wrapper testbench with the repo-local OSS CAD Suite tools. This covers `STUB`, `CORE_PLACEHOLDER`, and the honest `MLDSA_OSH` fallback behavior that is available in the current Verilog-only flow.
- `run_sv_stub_tb.sh`: Bash-oriented counterpart for the wrapper regression path.
- `run_sv_mldsa_osh_tb.ps1`: checks whether a mixed-language simulator path is available for the imported ML-DSA-OSH core and reports the current blocker honestly when it is not.
- `run_sv_mldsa_osh_tb.sh`: Bash-oriented counterpart for the mixed-language diagnostic.
- `run_real_mmio_probe.ps1`: invokes the new real-backend probe path for target-hardware register visibility checks.
- `run_real_mmio_probe.sh`: Bash-oriented counterpart for the real-backend probe path.

The new real-backend scripts do not assume hardware is present on the current machine. They are intended for first PS-to-PL register visibility checks on Zynq Linux once a wrapper base address and MMIO access path are available.