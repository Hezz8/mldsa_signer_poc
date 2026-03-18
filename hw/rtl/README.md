# RTL Area

This directory contains project-owned RTL that sits behind the PS-visible AXI-Lite wrapper and the board-facing top-level scaffolds used for bring-up planning.

Current contents:

- `mldsa_engine_adapter.sv`: stable adapter layer between the wrapper contract and selectable engine implementations.
- `mldsa_osh_shim.sv`: project-owned shim that translates the adapter contract into the inspected ML-DSA-OSH sign-stream interface.
- `pqsig_top_stub_mode.sv`: board-facing STUB-mode top-level scaffold for the first real hardware image.
- `pqsig_top_mldsa_osh_mode.sv`: future-looking MLDSA_OSH-mode top-level scaffold for later board work.

Current adapter modes:

- `STUB`: deterministic fake signature path used for software and wrapper regression.
- `CORE_PLACEHOLDER`: deterministic seam-testing mode that keeps the adapter contract stable.
- `MLDSA_OSH`: real attachment path to the imported ML-DSA-OSH source when a suitable mixed-language simulation or synthesis flow is available.

The shim remains intentionally separate from the imported third-party source under `hw/ip/mldsa_osh/` so project-owned integration logic can evolve without modifying the vendored snapshot.