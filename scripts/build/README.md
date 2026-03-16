# Build Scripts

This directory contains lightweight build and execution helpers for the bootstrap and stub phases.

- `run_python_tests.sh`: runs the software unit and contract tests using the standard library `unittest` runner.
- `run_sv_stub_tb.ps1`: compiles and runs the current wrapper stub testbench using the repo-local OSS CAD Suite tools.
- `run_sv_stub_tb.sh`: Bash-oriented counterpart for environments where Bash is available.

The scripts in this directory are intentionally minimal so the repository can run in constrained environments before full machine-level toolchains are installed.