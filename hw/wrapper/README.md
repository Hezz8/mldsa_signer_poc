# AXI-Lite Wrapper

This directory contains the PS-visible AXI-Lite contract boundary for the appliance.

Current contents:

- `wrapper_pkg.sv`: shared register offsets, control and status bits, widths, and engine mode constants.
- `axi_lite_wrapper.sv`: stable AXI-Lite wrapper top that presents the register map to software and instantiates the engine adapter.
- `TODO.md`: forward-looking wrapper implementation tasks.

Current behavior remains intentionally non-cryptographic:

- software writes a 64-byte digest into the documented digest window
- a `start` write transitions the wrapper into `busy`
- the wrapper delegates signing behavior to `mldsa_engine_adapter`
- `STUB` mode returns `STUBSIG || digest || zero padding` after a deterministic two-cycle latency
- `CORE_PLACEHOLDER` mode returns `COREPH || digest || zero padding` after a deterministic four-cycle latency
- no ML-DSA datapath or external crypto core is present

The wrapper contract is now intended to remain stable while future ML-DSA-OSH integration occurs behind the adapter boundary.
