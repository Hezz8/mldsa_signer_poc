# Build Scripts

This directory contains lightweight build and execution helpers for the current bootstrap, adapter, and imported-core integration phases.

- `run_python_tests.sh`: runs the software unit and contract tests using the standard library `unittest` runner.
- `run_sv_stub_tb.ps1`: compiles and runs the stable AXI-Lite wrapper testbench with the repo-local OSS CAD Suite tools. This covers `STUB`, `CORE_PLACEHOLDER`, and the honest `MLDSA_OSH` fallback behavior that is available in the current Verilog-only flow.
- `run_sv_stub_tb.sh`: Bash-oriented counterpart for environments where Bash is available.
- `run_sv_mldsa_osh_tb.ps1`: checks whether a mixed-language simulator path is available for the imported ML-DSA-OSH core and reports the current blocker honestly when it is not.
- `run_sv_mldsa_osh_tb.sh`: Bash-oriented counterpart for the mixed-language diagnostic.

The scripts remain intentionally practical. They preserve a working local regression path for the stable wrapper contract while making it explicit that full local simulation of the imported ML-DSA-OSH sign path still needs mixed-language tooling.