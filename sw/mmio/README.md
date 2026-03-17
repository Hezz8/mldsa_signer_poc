# MMIO Layer Area

This directory contains the software source of truth for the wrapper register interface and backend access paths.

Key files:

- `register_map.py`: register offsets, control and status masks, signature-window sizing, and helper decoders
- `backend.py`: backend abstraction for MMIO access
- `fake_backend.py`: deterministic fake register implementation used for local execution and tests
- `real_backend.py`: PoC user-space MMIO backend intended for Linux on Zynq using a `/dev/mem`-style mapping path
- `device.py`: high-level device API used by the daemon
- `probe.py`: safe register-visibility probe helper

The fake backend remains the default development path. The real backend is intentionally isolated so target-hardware bring-up can start without changing the service-layer contract.