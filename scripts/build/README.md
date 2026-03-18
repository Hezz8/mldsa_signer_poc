# Build Scripts

This directory contains lightweight build and execution helpers for the current bootstrap, imported-core integration, and board bring-up phases.

- `run_python_tests.sh`: runs the software unit and contract tests.
- `run_sv_stub_tb.ps1`: runs the stable wrapper regression testbench.
- `run_sv_stub_tb.sh`: Bash counterpart for the wrapper regression path.
- `run_sv_mldsa_osh_tb.ps1`: reports the current mixed-language blocker for full local MLDSA_OSH simulation.
- `run_sv_mldsa_osh_tb.sh`: Bash counterpart for the mixed-language diagnostic.
- `run_real_mmio_probe.ps1`: runs the safe real-backend probe path and requires an MMIO base address.
- `run_real_mmio_probe.sh`: Bash counterpart for the real-backend probe path.
- `run_real_stub_selftest.ps1`: runs the explicit real-backend STUB selftest and requires an MMIO base address.
- `run_real_stub_selftest.sh`: Bash counterpart for the real-backend STUB selftest.

The first real board execution should always use the STUB-mode probe and STUB selftest before any MLDSA_OSH-mode board work.