# AXI-Lite Wrapper

This directory contains the PS-visible AXI-Lite contract boundary for the appliance.

Current contents:

- `wrapper_pkg.sv`: shared register offsets, control and status bits, widths, engine mode constants, and ML-DSA-OSH sizing constants.
- `axi_lite_wrapper.sv`: stable AXI-Lite wrapper top that presents the register map to software and instantiates the engine adapter.
- `TODO.md`: forward-looking wrapper implementation tasks.

Current behavior:

- software writes a 64-byte digest into the documented digest window
- a `start` write transitions the wrapper into `busy`
- the wrapper delegates signing behavior to `mldsa_engine_adapter`
- `STUB` mode returns `STUBSIG || digest || zero padding` after a deterministic two-cycle latency
- `CORE_PLACEHOLDER` mode returns `COREPH || digest || zero padding` after a deterministic four-cycle latency
- `MLDSA_OSH` mode attaches to the imported upstream sign path through a project-owned shim while preserving the same wrapper-visible control and status contract

The register layout remains stable at the base offsets established in earlier phases. The `SIG_DATA` window is now sized to hold the largest supported mode result so the real ML-DSA-87 signature can be surfaced without introducing a new software-visible contract.