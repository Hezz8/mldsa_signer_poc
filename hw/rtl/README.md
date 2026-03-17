# RTL Area

This directory contains synthesizable modules that sit behind the PS-visible AXI-Lite wrapper.

Current contents:

- `mldsa_engine_adapter.sv`: stable adapter layer between the wrapper contract and a future ML-DSA core implementation.

Current adapter modes:

- `STUB`: reproduces the deterministic fake signature behavior used for software and wrapper contract validation.
- `CORE_PLACEHOLDER`: preserves the same adapter contract while standing in for a future ML-DSA-OSH-facing engine integration.

No cryptographic implementation is present yet.
