# MMIO Layer Area

This directory now contains the first software source of truth for the register interface.

Key files:

- `register_map.py`: register offsets, control and status masks, and documented stub signature behavior
- `backend.py`: backend abstraction for future real MMIO access
- `fake_backend.py`: deterministic fake register implementation used for local execution and tests
- `device.py`: high-level device API used by the daemon

The fake backend is intentionally designed to be replaced later by a real Zynq Linux MMIO backend without changing the service-layer contract.
